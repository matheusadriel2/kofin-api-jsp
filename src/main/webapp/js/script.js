document.addEventListener('DOMContentLoaded', function() {
    const togglePasswordIcons = document.querySelectorAll('.toggle-password');

    togglePasswordIcons.forEach(icon => {
        const passwordInput = icon.closest('.input-group').querySelector('input');

        icon.addEventListener('click', (e) => {
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);
            icon.classList.toggle('bi-eye');
            icon.classList.toggle('bi-eye-slash');
        });
    });

    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        const inputs = form.querySelectorAll('input:not([type="checkbox"])');
        inputs.forEach(input => {
            const parentElement = input.closest('.form-control')?.parentElement || 
                                  input.closest('.input-group') || 
                                  input.parentElement;
            
            parentElement.style.position = 'relative';
        });

        form.addEventListener('submit', function(e) {
            e.preventDefault();

            const emailInput = form.querySelector('input[type="email"], input[type="text"][placeholder="E-mail"]');
            const passwordInputs = form.querySelectorAll('input[type="password"]');
            const fullNameInput = form.querySelector('input[placeholder="Nome completo"]');
            const confirmPasswordInput = form.querySelector('input[placeholder="Confirme sua senha"]');

            let isValid = true;

            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(emailInput.value)) {
                emailInput.classList.add('is-invalid');
                isValid = false;
            } else {
                emailInput.classList.remove('is-invalid');
            }

            let passwordValue = '';
            passwordInputs.forEach((passwordInput, index) => {
                if (passwordInput.value.length < 8) {
                    passwordInput.classList.add('is-invalid');
                    isValid = false;
                } else {
                    passwordInput.classList.remove('is-invalid');
                }
                
                if (index === 0) passwordValue = passwordInput.value;
            });

            if (confirmPasswordInput) {
                if (confirmPasswordInput.value !== passwordValue || confirmPasswordInput.value.length < 8) {
                    confirmPasswordInput.classList.add('is-invalid');
                    isValid = false;
                } else {
                    confirmPasswordInput.classList.remove('is-invalid');
                }
            }

            if (fullNameInput && fullNameInput.value.trim() === '') {
                fullNameInput.classList.add('is-invalid');
                isValid = false;
            } else if (fullNameInput) {
                fullNameInput.classList.remove('is-invalid');
            }

            if (isValid) {
                const alertDiv = document.createElement('div');
                alertDiv.classList.add('alert', 'alert-success', 'position-fixed', 'top-0', 'end-0', 'm-3', 'alert-dismissible', 'fade', 'show');
                alertDiv.setAttribute('role', 'alert');
                alertDiv.innerHTML = `
                    Operação realizada com sucesso! 😁
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                `;
                
                document.body.appendChild(alertDiv);

                setTimeout(() => {
                    const bsAlert = new bootstrap.Alert(alertDiv);
                    bsAlert.close();
                }, 3000);
            }
        });
    });
});