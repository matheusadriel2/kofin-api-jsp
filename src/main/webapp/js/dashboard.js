// toggle mobile tap
document.querySelectorAll('.card-item').forEach(card => {
    card.addEventListener('click', e => {
        if (e.target.closest('.card-actions')) return;
        card.classList.toggle('show-actions');
    });
});

document.querySelectorAll('.h-scroll').forEach(el => {
    el.addEventListener('wheel', function(e) {
        // só age em scroll vertical do mouse
        if (e.deltaY === 0) return;
        e.preventDefault();              // impede scroll vertical da página
        this.scrollLeft += e.deltaY;     // aplica movimento horizontal
    }, { passive: false });
});

// hint de scroll
const wrap   = document.querySelector('.cards-wrap');
const hint   = document.getElementById('scrollHint');
const scroll = wrap.querySelector('.h-scroll');
function showHint(){
    hint.classList.add('show-hint');
    clearTimeout(hint._timer);
    hint._timer = setTimeout(() => hint.classList.remove('show-hint'), 800);
}
scroll.addEventListener('pointerdown', showHint);
scroll.addEventListener('wheel',       showHint);

// popular campos do modal de edição
document.addEventListener('shown.bs.modal', function(ev) {
    if (ev.target.id === 'editCardModal') {
        const btn = ev.relatedTarget; // botão que disparou

        // pega dataset
        const { id, name, last4, type, validity, flag } = btn.dataset;

        // preenche hidden id
        document.getElementById('editCardId').value = id;

        // preenche os inputs
        document.getElementById('editCardName').value     = name;
        document.getElementById('editCardLast4').value    = last4;
        document.getElementById('editCardType').value     = type;
        document.getElementById('editCardFlag').value     = flag;

        // input type=month recebe "YYYY-MM"
        let monthVal = validity;
        // caso venha "YYYY-MM-01", corta para "YYYY-MM"
        if (monthVal.length === 10 && monthVal.endsWith('-01')) {
            monthVal = monthVal.slice(0,7);
        }
        document.getElementById('editCardValidity').value = monthVal;
    }

    if (ev.target.id === 'newTxModal') {
        const btn = ev.relatedTarget;
        document.getElementById('newTxType').value = btn.dataset.type;
    }
    if (ev.target.id === 'editTxModal') {
        const btn = ev.relatedTarget;
        document.getElementById('editTxId').value = btn.dataset.id;
        document.getElementById('editTxCardId').value = btn.dataset.cardid || "";
    }
});

/* -------- limpa formulários quando o modal é fechado ---------- */
['newTxModal','editTxModal'].forEach(id=>{
    const m = document.getElementById(id);
    m.addEventListener('hidden.bs.modal', ()=> m.querySelector('form').reset());
});

/* -------- mostra/esconde select de cartão --------------------- */
function toggleCardSelect(selectEl, wrapEl){
    wrapEl.classList.toggle('d-none', selectEl.value !== 'CARD');
}
document.getElementById('newPayMethod' ).addEventListener('change', e=>
    toggleCardSelect(e.target, document.getElementById('newCardSelectWrap')));

document.getElementById('editPayMethod').addEventListener('change', e=>
    toggleCardSelect(e.target, document.getElementById('editCardSelectWrap')));

/* ------- mostra botões (tap em mobile) ------- */
document.querySelectorAll('.tx-item').forEach(it=>{
    it.addEventListener('click',e=>{
        if(e.target.closest('.tx-actions')) return;
        it.classList.toggle('show-actions');
    });
});

/* ------- select cartão on/off ------- */
function toggleCard(sel,wrap){wrap.classList.toggle('d-none',sel.value!=='CARD');}
document.getElementById('newPayMethod').onchange = e=>toggleCard(e.target,document.getElementById('newCardSelectWrap'));
document.getElementById('editPayMethod').onchange= e=>toggleCard(e.target,document.getElementById('editCardSelectWrap'));

/* ------- popula modais ------- */
document.addEventListener('shown.bs.modal',ev=>{
    /* NOVA */
    if(ev.target.id==='newTxModal'){
        const btn=ev.relatedTarget;
        const type=btn.dataset.type;
        document.getElementById('newTxType').value      = type;
        document.getElementById('newTxTypeLabel').value = type;
        document.getElementById('newTxDate').value = new Date().toISOString().slice(0,16);
    }
    /* EDITAR */
    if(ev.target.id==='editTxModal'){
        const btn=ev.relatedTarget;
        const type=btn.dataset.type;
        document.getElementById('editTxId').value   = btn.dataset.id;
        document.getElementById('editTxType').value = type;
        document.getElementById('editTxTypeLabel').value = type;
        document.getElementById('editTxCardId').value = btn.dataset.cardid || '';
    }
});

/* ------- limpa formulários ao fechar ------- */
['newTxModal','editTxModal'].forEach(id=>{
    document.getElementById(id).addEventListener('hidden.bs.modal',e=>e.target.querySelector('form').reset());
});

/* =====================  RECIBO  ===================== */
document
    .querySelectorAll('[data-action="view-receipt"]')
    .forEach(btn=>{
        btn.addEventListener('click', e=>{
            e.stopPropagation();                     // não interfere no toggle
            const tx = btn.closest('.tx-item');
            fillReceipt(tx.dataset);                 // preenche tabela do modal
            bootstrap
                .Modal
                .getOrCreateInstance('#viewTxModal')
                .show();
        });
    });

/* abrir / fechar ícones flutuantes ------------------- */
document.querySelectorAll('.tx-item').forEach(it=>{
    it.addEventListener('click', e=>{
        if (e.target.closest('.tx-actions')) return; // se clicou num ícone, ignora
        it.classList.toggle('show-actions');         // só alterna visibilidade
    });
});


function fillReceipt(d){
    rc_name.textContent = d.name || '-';
    rc_cat .textContent = d.cat  || '-';
    rc_type.textContent = d.type;
    rc_val .textContent = 'R$ ' + Number(d.val).toFixed(2);
    rc_pm  .textContent = d.pm;
    rc_date.textContent = d.date.replace('T',' ').slice(0,16);
}

/* tap em mobile → mostra/oculta ícones flutuantes */
document.querySelectorAll('.tx-item').forEach(it=>{
    it.addEventListener('touchstart',()=>it.classList.toggle('show-actions'),{passive:true});
});

/* ---------- EDITAR transação: preenche todos os campos ---------- */
document.querySelectorAll('[data-bs-target="#editTxModal"]').forEach(btn=>{
    btn.addEventListener('click', () => {

        /* dataset vindo de tx-item ------------------------------------------------ */
        const it   = btn.closest('.tx-item');
        const data = it.dataset;

        /* campos invisíveis ------------------------------------------------------ */
        editTxId.value        = data.id;
        editTxType.value      = data.type;
        editTxTypeLabel.value = data.type;

        /* campos de texto -------------------------------------------------------- */
        editTxName.value      = data.name;
        editTxCategory.value  = data.cat;
        editTxValue.value     = Number(data.val).toFixed(2);

        /* método de pagamento + cartão opcional ---------------------------------- */
        editPayMethod.value   = data.pm;
        toggleCardSelect(editPayMethod, editCardSelectWrap);
        editTxCardId.value    = data.card || '';

        /* data e hora  ----------------------------------------------------------- */
        editTxDate.value = data.date.slice(0,16);   // yyyy-MM-ddTHH:mm

        /* transferência? --------------------------------------------------------- */
        editTxTransfer.checked = data.transfer === 'true';

        /* agendamento (vem null -> default imediata) ----------------------------- */
        editTxScheduled.value = data.scheduled || 'NONSCHEDULED';
    });
});

/* ---------- DELETE via ícone 🗑: confirmação opcional ----------------------- */
document.querySelectorAll('.tx-actions form').forEach(f=>{
    f.addEventListener('submit', e=>{
        if(!confirm('Excluir esta transação?')) e.preventDefault();
    });
});

/* 1 listener para cada .tx-item ---------- */
document.querySelectorAll('.tx-item').forEach(item=>{
    item.addEventListener('click',e=>{
        /* se clicou dentro dos botões, não faz toggle */
        if(e.target.closest('.tx-actions')) return;
        item.classList.toggle('show-actions');   // mostra/oculta ícones
    });
});

document.querySelectorAll('.tx-block').forEach(block => {
    const wrapper = block.closest('.tx-col');
    let hintTimer;

    function showHint() {
        wrapper.classList.add('show-scroll-hint');
        clearTimeout(hintTimer);
        hintTimer = setTimeout(() => wrapper.classList.remove('show-scroll-hint'), 700);
    }

    block.addEventListener('scroll', () => {
        // se já está no topo OU no fim, nada
        if (block.scrollTop === 0 ||
            block.scrollTop + block.clientHeight >= block.scrollHeight) {
            wrapper.classList.remove('show-scroll-hint');
        } else {
            showHint();
        }
    });

    // opcional: ao resize recalcula (não obrigatório aqui)
    window.addEventListener('resize', () => {
        // poderia ajustar dimensões se quisesse
    });
});

document.addEventListener('DOMContentLoaded', () => {
    const sidebar   = document.querySelector('#sidebar');
    const offcanvas = document.querySelector('#offcanvasNav .offcanvas-body');
    const ul = sidebar.querySelector('ul').cloneNode(true);
    const hr = sidebar.querySelector('hr').cloneNode(true);
    hr.classList.remove('d-none', 'd-lg-block');

    const liDivider = document.createElement('li');
    liDivider.innerHTML = '<hr class="border-secondary my-1 w-100">';
    ul.appendChild(liDivider);

    const logoutLi = document.createElement('li');
    logoutLi.className = 'nav-item mt-auto';

    const logoutA = sidebar.querySelector('a.logout-link').cloneNode(true);
    logoutA.classList.add('nav-link');
    logoutLi.appendChild(logoutA);
    ul.appendChild(logoutLi);

    offcanvas.appendChild(ul);
});

// Modal de visualização de transação
const viewModal = document.getElementById('viewTxModal');
viewModal.addEventListener('show.bs.modal', ev => {
    const data = ev.relatedTarget.closest('.tx-item').dataset;
    document.getElementById('tx-name').textContent = data.name || '-';
    document.getElementById('tx-cat').textContent  = data.cat  || '-';
    document.getElementById('tx-type').textContent = data.type;
    document.getElementById('tx-val').textContent  = 'R$ ' + Number(data.val).toFixed(2);
    document.getElementById('tx-pm').textContent   = data.pm;
    document.getElementById('tx-date').textContent = data.date.replace('T',' ').slice(0,16);
});

const editModal = document.getElementById('editCardModal');
editModal.addEventListener('show.bs.modal', e => {
    const btn = e.relatedTarget;
    editModal.querySelector('#editCardId')      .value = btn.dataset.id;
    editModal.querySelector('#editCardName')    .value = btn.dataset.name;
    editModal.querySelector('#editCardLast4')   .value = btn.dataset.last4;
    editModal.querySelector('#editCardType')    .value = btn.dataset.type;
    editModal.querySelector('#editCardValidity').value = btn.dataset.validity;
    editModal.querySelector('#editCardFlag')    .value = btn.dataset.flag;
});