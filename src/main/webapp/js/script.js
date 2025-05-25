document.addEventListener('DOMContentLoaded', () => {

    /* ---------- alternar visibilidade da senha ---------- */
    document.querySelectorAll('.toggle-password').forEach(icon => {
        const pwdInput = icon.closest('.input-group').querySelector('input[type="password"],input[type="text"]');

        icon.addEventListener('click', () => {
            const isPwd   = pwdInput.type === 'password';
            pwdInput.type = isPwd ? 'text' : 'password';
            icon.classList.toggle('bi-eye',       isPwd);
            icon.classList.toggle('bi-eye-slash', !isPwd);
        });
    });

    /* ---------- validação de cada formulário ---------- */
    document.querySelectorAll('form').forEach(form => {

        form.addEventListener('submit', ev => {
            let valid = true;

            /* -------- e-mail -------- */
            const email = form.querySelector('input[type="email"]');
            if (email) {
                const ok = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value);
                email.classList.toggle('is-invalid', !ok);
                valid &&= ok;
            }

            /* -------- senhas -------- */
            const pwds      = form.querySelectorAll('input[type="password"]');
            let   firstPwd  = '';
            pwds.forEach((pwd, idx) => {
                const ok = pwd.value.length >= 8;
                pwd.classList.toggle('is-invalid', !ok);
                valid &&= ok;
                if (idx === 0) firstPwd = pwd.value;
            });

            const pwdConfirm = form.querySelector('input[placeholder="Confirme sua senha"]');
            if (pwdConfirm) {
                const ok = pwdConfirm.value === firstPwd && pwdConfirm.value.length >= 8;
                pwdConfirm.classList.toggle('is-invalid', !ok);
                valid &&= ok;
            }

            /* -------- nome completo (cadastro) -------- */
            const fullName = form.querySelector('input[placeholder="Nome completo"]');
            if (fullName) {
                const ok = fullName.value.trim() !== '';
                fullName.classList.toggle('is-invalid', !ok);
                valid &&= ok;
            }

            /* -------- decide se bloqueia o submit -------- */
            if (!valid) {
                ev.preventDefault();          // bloqueia envio se houver erros
                return;
            }
       });
    });
});
