<%@ page contentType="text/html; charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core"      %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8"/>
  <title>Kofin • Dashboard</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/bootstrap.css"/>

  <style>
    .tx-item:hover .tx-actions,
    .tx-item.show-actions .tx-actions{opacity:1}
    .tx-block{
      max-height:calc(100vh - 420px); /* ocupa resto da página com folga */
      min-height:260px;
      overflow-y:auto;
    }
    .tx-block:empty::before{
      content:"Sem transações ainda";
      display:block;text-align:center;
      margin-top:3rem;color:#adb5bd;
    }

    .cards-wrap  {position:relative;padding:1rem;background:#6c757d;border-radius:.5rem;}
    .h-scroll {
      overflow-x: auto;
      white-space: nowrap;
      padding-right: calc(1rem + 50px); /* espaço pro + */
    }
    .h-scroll::-webkit-scrollbar{display:none;}

    .card-item   {
      min-width:200px; height:105px; margin-right:1rem;
      background:#212529; border-radius:.5rem; padding:.75rem;
      position:relative;
    }
    .last4       { font-size:.70rem; }

    .card-actions {
      position:absolute; top:4px; right:4px;
      opacity:0; pointer-events:none; transition:opacity .15s;
    }
    .card-item:hover .card-actions,
    .card-item.show-actions .card-actions{
      opacity:1; pointer-events:auto;
    }

    .add-card-btn {
      position:absolute;
      right:1rem;
      top:50%; transform:translateY(-50%);
      width:50px; height:105px; border-radius:.5rem;
      background:#0d6efd; color:#fff; font-size:2rem;
      display:flex; align-items:center; justify-content:center;
      cursor: pointer;            /* mostra mãozinha */
      pointer-events: auto;       /* garante que seja clicável */
      z-index: 2;                 /* fica sempre por cima */
    }

    /* resumo */
    .summary-wrap {
      background:#6c757d; border-radius:.5rem; padding:1rem;
      display:flex; flex:1; flex-direction:column;
    }
    .summary-wrap .summary-grid { flex:1; display:flex; gap:1rem; }
    .summary-wrap .summary-grid > div {
      flex:1; display:flex; align-items:center; justify-content:center;
      background:#212529; border-radius:.5rem; padding:.75rem; text-align:center;
    }

    /* ============ BARRA de SCROLL (hint) ============ */
    .scroll-hint{position:absolute;right:calc(55px + 1rem); /* ao lado do + */
      top:50%;transform:translateY(-50%);
      width:6px;height:42px;border-radius:3px;
      background:#6c757d;opacity:0;transition:opacity .2s;pointer-events:none;}
    .show-hint  {opacity:.9;}

    /* ============ LISTA de TRANSAÇÕES ============ */
    .tx-block{max-height:420px;overflow-y:auto;}
  </style>
</head>
<body class="bg-dark text-light">
<div class="container py-4">

  <!-- header -->
  <div class="d-flex justify-content-between mb-4">
    <h2>Dashboard</h2>
    <a class="btn btn-sm btn-outline-light" href="${pageContext.request.contextPath}/logout">Sair</a>
  </div>

  <!-- =================== ROW: CARTÕES + RESUMO =================== -->
  <div class="row gy-4 mb-5">

    <!-- =============== BLOCO: CARTÕES ================= -->
    <div class="col-12 col-lg-5">
      <h5 class="mb-2">Cartões</h5>
      <h6 class="mb-3">Gerencia todos os seus cartoes aqui...</h6>

      <div class="bg-secondary rounded p-3 cards-wrap">

        <!-- carrossel ------------------------------------------------- -->
        <div class="h-scroll d-flex">

          <c:forEach items="${cards}" var="c">
            <div class="card-item">

              <!-- apelido do cartão (reticências se longo) -->
              <h6 class="mb-1 card-name">
                <c:choose>
                  <c:when test="${fn:length(c.name) > 17}">
                    ${fn:substring(c.name,0,17)}&hellip;
                  </c:when>
                  <c:otherwise>${c.name}</c:otherwise>
                </c:choose>
              </h6>

              <strong class="last4 d-block">**** ${c.last4}</strong>
              <small class="d-block">${c.type}</small>

              <small class="d-flex justify-content-between">
            <span>
              Val:
              ${fn:substring(c.validity,5,7)}/${fn:substring(c.validity,2,4)}
            </span>

                <!-- imagem só se houver bandeira -->
                <c:if test="${not empty c.flag}">
                  <img src="${pageContext.request.contextPath}/img/flags/${c.flag.img}"
                       alt="${c.flag}" width="26" height="18"/>
                </c:if>
              </small>

              <!-- botões de ação ------------------------------------- -->
              <div class="card-actions">
                <button class="btn btn-sm btn-outline-light me-1"
                        data-bs-toggle="modal" data-bs-target="#editCardModal"
                        data-id="${c.id}" data-name="${c.name}" data-last4="${c.last4}"
                        data-type="${c.type}" data-validity="${c.validity}"
                        data-flag="${c.flag}">✎</button>

                <form class="d-inline" method="post"
                      action="${pageContext.request.contextPath}/card"
                      onclick="event.stopPropagation()">
                  <input type="hidden" name="action" value="delete"/>
                  <input type="hidden" name="id"     value="${c.id}"/>
                  <button type="submit" class="btn btn-sm btn-outline-danger">🗑</button>
                </form>
              </div>
            </div>
          </c:forEach>

        </div><!-- /h-scroll -->

        <!-- botão + para novo cartão -->
        <button class="add-card-btn"
                data-bs-toggle="modal" data-bs-target="#newCardModal">+</button>

        <!-- barra‐dica de scroll -->
        <div class="scroll-hint" id="scrollHint"></div>
      </div>
    </div><!-- /Cartões -->

    <!-- Resumo ------------------------------------------------------ -->
    <div class="col-12 col-lg-7 d-flex flex-column">
      <h5 class="mb-2">Resumo</h5>
      <h6 class="mb-3">Confira suas entradas e despesas semanais...</h6>

      <!-- row-cols-* controla colunas; 1 nos xs, 3 a partir de sm -->
      <div class="row row-cols-1 row-cols-sm-3 g-3 flex-grow-1">

        <div class="col d-flex">
          <div class="bg-success bg-opacity-25 rounded p-3 w-100 text-center d-flex flex-column justify-content-center">
            <h6 class="text-success-emphasis">Entradas (mês)</h6>
            <h4 class="text-success">R$ ${incomeMonth}</h4>
            <small>Total: R$ ${incomeTotal}</small>
          </div>
        </div>

        <div class="col d-flex">
          <div class="bg-danger bg-opacity-25 rounded p-3 w-100 text-center d-flex flex-column justify-content-center">
            <h6 class="text-danger-emphasis">Saídas (mês)</h6>
            <h4 class="text-danger">R$ ${expenseMonth}</h4>
            <small>Total: R$ ${expenseTotal}</small>
          </div>
        </div>

        <div class="col d-flex">
          <div class="bg-secondary bg-opacity-25 rounded p-3 w-100 text-center d-flex flex-column justify-content-center">
            <h6>Saldo</h6>
            <h4>R$ ${saldoTotal}</h4>
            <small>Mês: R$ ${saldoMes}</small>
          </div>
        </div>

      </div><!-- /row resumo -->
    </div><!-- /resumo -->

  </div><!-- /row Cartões + Resumo -->

  <!-- ================= BLOCO: TRANSAÇÕES ================= -->
  <div class="col-12">

    <h5 class="mb-2">Transações</h5>

    <!-- filtros (multi-critério) ------------------------------------------------ -->
    <div class="d-flex flex-wrap gap-3 align-items-end mb-3">

      <h6 class="mb-0 me-auto">Movimentos recentes</h6>

      <form class="row row-cols-auto g-2 align-items-end"
            method="get"
            action="${pageContext.request.contextPath}/dashboard">

        <!-- cartão -->
        <div class="col">
          <label class="form-label mb-0 small">Cartão</label>
          <select name="card" class="form-select form-select-sm">
            <option value="">Todos</option>
            <c:forEach items="${cards}" var="cd">
              <option value="${cd.id}" ${cd.id == selectedCard ? "selected" : ""}>
                  ${cd.name}
              </option>
            </c:forEach>
          </select>
        </div>

        <!-- categoria -->
        <div class="col">
          <label class="form-label mb-0 small">Categoria</label>
          <input type="text" name="cat" class="form-control form-control-sm"
                 placeholder="ex: mercado"
                 value="${param.cat}"/>
        </div>

        <!-- nome (search) -->
        <div class="col">
          <label class="form-label mb-0 small">Nome</label>
          <input type="text" name="q" class="form-control form-control-sm"
                 placeholder="buscar..."
                 value="${param.q}"/>
        </div>

        <!-- método -->
        <div class="col">
          <label class="form-label mb-0 small">Método</label>
          <select name="pm" class="form-select form-select-sm">
            <option value="">Todos</option>
            <c:forEach var="m" items="${['CASH','CARD','PIX','BANK']}">
              <option ${m==param.pm?'selected':''}>${m}</option>
            </c:forEach>
          </select>
        </div>

        <!-- valor min / max -->
        <div class="col">
          <label class="form-label mb-0 small">Valor R$ (de-até)</label>
          <div class="input-group input-group-sm">
            <input type="number" step="0.01" name="vmin" class="form-control"
                   placeholder="min" value="${param.vmin}"/>
            <input type="number" step="0.01" name="vmax" class="form-control"
                   placeholder="máx" value="${param.vmax}"/>
          </div>
        </div>

        <div class="col">
          <button class="btn btn-sm btn-outline-light">Filtrar</button>
        </div>
      </form>
    </div>

    <!-- colunas -------------------------------------------------------------- -->
    <div class="bg-secondary rounded p-3">
      <div class="row g-3">

        <!-- Entradas -->
        <jsp:include page="/WEB-INF/views/fragments/txColumn.jsp">
          <jsp:param name="title"    value="Entradas"/>
          <jsp:param name="listName" value="txIncome"/>
          <jsp:param name="type"     value="INCOME"/>
        </jsp:include>

        <!-- Saídas -->
        <jsp:include page="/WEB-INF/views/fragments/txColumn.jsp">
          <jsp:param name="title"    value="Saídas"/>
          <jsp:param name="listName" value="txExpense"/>
          <jsp:param name="type"     value="EXPENSE"/>
        </jsp:include>

        <!-- Investimentos -->
        <jsp:include page="/WEB-INF/views/fragments/txColumn.jsp">
          <jsp:param name="title"    value="Investimentos"/>
          <jsp:param name="listName" value="txInvestment"/>
          <jsp:param name="type"     value="INVESTMENT"/>
        </jsp:include>


      </div>
    </div><!-- /bg-secondary -->

  </div><!-- /col-12 -->

</div>


<!-- ================== MODAIS (formulários) =============================== -->
<!-- Modal: criação de cartão  -->
<div class="modal fade" id="newCardModal" tabindex="-1">
  <div class="modal-dialog">
    <form class="modal-content" method="post" action="${pageContext.request.contextPath}/card">
      <input type="hidden" name="action" value="create"/>

      <div class="modal-header bg-secondary text-light">
        <h5 class="modal-title">Adicionar cartão</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">
        <!-- nome -->
        <div class="mb-3">
          <label class="form-label">Nome do cartão</label>
          <input type="text" name="name" class="form-control" required/>
        </div>

        <!-- últimos 4 -->
        <div class="mb-3">
          <label class="form-label">Últimos 4 dígitos</label>
          <input type="text" name="last4" class="form-control"
                 maxlength="4" pattern="\d{4}" title="Insira exatamente 4 números"/>
          <small class="text-muted">Obrigatório 4 dígitos numéricos.</small>
        </div>

        <!-- tipo -->
        <div class="mb-3">
          <label class="form-label">Tipo</label>
          <select name="type" class="form-select">
            <option value="DEBIT">Débito</option>
            <option value="CREDIT">Crédito</option>
          </select>
        </div>

        <!-- validade -->
        <div class="mb-3">
          <label class="form-label">Validade (MM/AAAA)</label>
          <input type="month" name="validity" class="form-control" required/>
        </div>

        <!-- bandeira -->
        <div class="mb-3">
          <label class="form-label">Bandeira</label>
          <select name="flag" class="form-select">
            <option value="Visa">Visa</option>
            <option value="Mastercard">Mastercard</option>
            <option value="Elo">Elo</option>
            <option value="Amex">Amex</option>
          </select>
        </div>
      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-primary">Salvar</button>
      </div>
    </form>
  </div>
</div>


<!-- Modal: editar cartão -->
<div class="modal fade" id="editCardModal" tabindex="-1">
  <div class="modal-dialog">
    <form class="modal-content" method="post" action="${pageContext.request.contextPath}/card">
      <input type="hidden" name="action" value="update"/>
      <input type="hidden" name="id" id="editCardId"/>

      <div class="modal-header bg-secondary text-light">
        <h5 class="modal-title">Editar cartão</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">
        <!-- nome -->
        <div class="mb-3">
          <label class="form-label">Nome do cartão</label>
          <input type="text" name="name" id="editCardName" class="form-control" required/>
        </div>

        <!-- last4 -->
        <div class="mb-3">
          <label class="form-label">Últimos 4 dígitos</label>
          <input type="text" name="last4" id="editCardLast4" class="form-control"
                 maxlength="4" pattern="\d{4}" title="Insira exatamente 4 números"/>
        </div>

        <!-- tipo -->
        <div class="mb-3">
          <label class="form-label">Tipo</label>
          <select name="type" id="editCardType" class="form-select">
            <option value="DEBIT">Débito</option>
            <option value="CREDIT">Crédito</option>
          </select>
        </div>

        <!-- validade -->
        <div class="mb-3">
          <label class="form-label">Validade</label>
          <input type="month" name="validity" id="editCardValidity" class="form-control" required/>
        </div>

        <!-- bandeira -->
        <div class="mb-3">
          <label class="form-label">Bandeira</label>
          <select name="flag" id="editCardFlag" class="form-select">
            <option value="Visa">Visa</option>
            <option value="Mastercard">Mastercard</option>
            <option value="Elo">Elo</option>
            <option value="Amex">Amex</option>
          </select>
        </div>
      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-primary">Salvar</button>
      </div>
    </form>
  </div>
</div>

<!-- ========== MODAL: NOVA TRANSAÇÃO ========== -->
<div class="modal fade" id="newTxModal" tabindex="-1">
  <div class="modal-dialog">
    <form class="modal-content" method="post" action="${pageContext.request.contextPath}/transaction">
      <input type="hidden" name="action" value="create"/>
      <input type="hidden" name="type"   id="newTxType"/>

      <div class="modal-header bg-secondary text-light">
        <h5 class="modal-title">Nova transação</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">

        <!-- tipo (somente leitura) -->
        <div class="mb-3">
          <label class="form-label">Tipo</label>
          <input type="text" class="form-control" id="newTxTypeLabel" disabled/>
        </div>

        <div class="mb-3">
          <label class="form-label">Nome</label>
          <input type="text" name="txName" class="form-control"/>
        </div>

        <div class="mb-3">
          <label class="form-label">Categoria</label>
          <input type="text" name="category" class="form-control"/>
        </div>

        <div class="mb-3">
          <label class="form-label">Valor (R$)</label>
          <input type="number" step="0.01" name="value" class="form-control" required/>
        </div>

        <div class="mb-3">
          <label class="form-label">Forma de pagamento</label>
          <select name="payMethod" id="newPayMethod" class="form-select">
            <option>CASH</option><option>CARD</option><option>PIX</option><option>BANK</option>
          </select>
        </div>

        <div class="mb-3 d-none" id="newCardSelectWrap">
          <label class="form-label">Cartão (opcional)</label>
          <select name="cardId" class="form-select">
            <option value="">-- Sem cartão --</option>
            <c:forEach items="${cards}" var="cd">
              <option value="${cd.id}">${cd.name}</option>
            </c:forEach>
          </select>
        </div>

        <div class="mb-3">
          <label class="form-label">Data</label>
          <input type="datetime-local" name="date" id="newTxDate" class="form-control"/>
        </div>

        <div class="form-check mb-2">
          <input class="form-check-input" type="checkbox" value="S" name="transfer" id="newTxTransfer"/>
          <label class="form-check-label" for="newTxTransfer">Transferência</label>
        </div>

        <div class="mb-3">
          <label class="form-label">Agendamento</label>
          <select name="scheduled" class="form-select">
            <option value="NONSCHEDULED">Imediato</option>
            <option value="SCHEDULED">Agendado</option>
          </select>
        </div>

      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-primary">Salvar</button>
      </div>
    </form>
  </div>
</div>


<!-- ========== MODAL: EDITAR TRANSAÇÃO ========== -->
<div class="modal fade" id="editTxModal" tabindex="-1">
  <div class="modal-dialog">
    <form class="modal-content" method="post" action="${pageContext.request.contextPath}/transaction">
      <input type="hidden" name="action" value="update"/>
      <input type="hidden" name="id"     id="editTxId"/>
      <input type="hidden" name="type"   id="editTxType"/>

      <div class="modal-header bg-secondary text-light">
        <h5 class="modal-title">Editar transação</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">

        <!-- tipo (somente leitura) -->
        <div class="mb-3">
          <label class="form-label">Tipo</label>
          <input type="text" id="editTxTypeLabel" class="form-control" disabled/>
        </div>

        <div class="mb-3">
          <label class="form-label">Nome</label>
          <input type="text" name="txName" id="editTxName" class="form-control"/>
        </div>

        <div class="mb-3">
          <label class="form-label">Categoria</label>
          <input type="text" name="category" id="editTxCategory" class="form-control"/>
        </div>

        <div class="mb-3">
          <label class="form-label">Valor (R$)</label>
          <input type="number" step="0.01" name="value" id="editTxValue" class="form-control" required/>
        </div>

        <div class="mb-3">
          <label class="form-label">Forma de pagamento</label>
          <select name="payMethod" id="editPayMethod" class="form-select">
            <option>CASH</option><option>CARD</option><option>PIX</option><option>BANK</option>
          </select>
        </div>

        <div class="mb-3 d-none" id="editCardSelectWrap">
          <label class="form-label">Cartão (opcional)</label>
          <select name="cardId" id="editTxCardId" class="form-select">
            <option value="">-- Sem cartão --</option>
            <c:forEach items="${cards}" var="cd">
              <option value="${cd.id}">${cd.name}</option>
            </c:forEach>
          </select>
        </div>

        <div class="mb-3">
          <label class="form-label">Data</label>
          <input type="datetime-local" name="date" id="editTxDate" class="form-control"/>
        </div>

        <div class="form-check mb-2">
          <input class="form-check-input" type="checkbox" value="S" name="transfer" id="editTxTransfer"/>
          <label class="form-check-label" for="editTxTransfer">Transferência</label>
        </div>

        <div class="mb-3">
          <label class="form-label">Agendamento</label>
          <select name="scheduled" id="editTxScheduled" class="form-select">
            <option value="NONSCHEDULED">Imediato</option>
            <option value="SCHEDULED">Agendado</option>
          </select>
        </div>

      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-primary">Salvar</button>
      </div>
    </form>
  </div>
</div>

<!-- ========== MODAL: RECIBO ========== -->
<div class="modal fade" id="viewTxModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-sm">
    <div class="modal-content">

      <div class="modal-header bg-secondary text-light">
        <h5 class="modal-title">Recibo</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">
        <table class="table table-sm text-light mb-0">
          <tbody>
          <tr><th>Nome</th>      <td id="rc-name"></td></tr>
          <tr><th>Categoria</th> <td id="rc-cat"></td></tr>
          <tr><th>Tipo</th>      <td id="rc-type"></td></tr>
          <tr><th>Valor</th>     <td id="rc-val"></td></tr>
          <tr><th>Método</th>    <td id="rc-pm"></td></tr>
          <tr><th>Data</th>      <td id="rc-date"></td></tr>
          </tbody>
        </table>
      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Fechar</button>
      </div>
    </div>
  </div>
</div>

<script>
  // toggle mobile tap
  document.querySelectorAll('.card-item').forEach(card => {
    card.addEventListener('click', e => {
      if (e.target.closest('.card-actions')) return;
      card.classList.toggle('show-actions');
    });
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
  document.querySelectorAll('.tx-item').forEach(it=>{
    it.addEventListener('click',e=>{
      if (e.target.closest('.tx-actions')) return;        // ignora clique nos botões
      fillReceipt(it.dataset);                            // preenche dados
      bootstrap.Modal.getOrCreateInstance('#viewTxModal').show();
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
</script>


<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
