<%@ page contentType="text/html; charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8"/>
  <title>Kofin • Dashboard</title>

  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.css"/>

  <style>
    /* ---------- cartões (carrossel) ---------- */
    .h-scroll{overflow-x:auto;white-space:nowrap;scrollbar-width:none;-ms-overflow-style:none;}
    .h-scroll::-webkit-scrollbar{display:none;}
    .card-block{min-width:220px;height:120px;}    /* ↓ um pouco menor */
    .card-plus {width:90px;height:120px;}
    .arrow-right{position:absolute;right:0;top:50%;transform:translateY(-50%);
      padding:.3rem .45rem;background:#6c757d;border-radius:.25rem;cursor:pointer;}

    /* ---------- transações ---------- */
    .tx-block{max-height:420px;overflow-y:auto;}

    /* ---------- linha Cartões + Resumo ---------- */
    .cards-summary {display:flex;flex-wrap:wrap;gap:1rem;align-items:stretch;}   /* mesma altura */
    .cards-col    {flex:3 1 40%;min-width:300px;display:flex;flex-direction:column;}
    .summary-col  {flex:4 1 57%;min-width:300px;display:flex;flex-direction:column;}

    .cards-wrapper   {flex:1;}               /* preenche toda a altura da coluna */
    .summary-wrapper {flex:1;display:flex;flex-direction:column;}

    /* blocos internos do resumo esticam igual */
    .summary-grid      {flex:1;display:flex;gap:1rem;}
    .summary-grid>div  {flex:1;display:flex;flex-direction:column;
      justify-content:center;align-items:center;}

    /* sempre a mesma altura visual entre colunas */
    @media (max-width: 991.98px){           /* Bootstrap lg-breakpoint */
      .cards-summary{flex-direction:column;}/* empilha em telas pequenas */
    }
  </style>
</head>
<body class="bg-dark text-light">

<div class="container py-4">

  <!-- título & logout -->
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h2>Dashboard</h2>
    <a class="btn btn-sm btn-outline-light" href="${pageContext.request.contextPath}/logout">Sair</a>
  </div>

  <!-- ============ CARTÕES (3/7) + RESUMO (4/7) ============ -->
  <div class="cards-summary mb-5">

    <!-- ------------- Cartões ------------- -->
    <div class="cards-col">
      <h5 class="mb-2">💳 Cartões</h5>

      <div class="cards-wrapper bg-secondary rounded p-3 position-relative h-scroll d-flex gap-3">

        <span class="arrow-right">➜</span>

        <c:forEach items="${cards}" var="c">
          <div class="bg-dark rounded card-block p-3 position-relative">
            <h6 class="mb-1">${c.name}</h6>
            <strong>**** ${c.last4}</strong>
            <small class="d-block">${c.type}</small>
            <small class="d-block">Val: ${c.validity}</small>
            <span class="position-absolute top-0 start-0 translate-middle p-1">${c.flag}</span>

            <!-- ações -->
            <div class="position-absolute top-0 end-0 m-1">
              <button class="btn btn-sm btn-outline-light"
                      data-bs-toggle="modal" data-bs-target="#editCardModal"
                      data-id="${c.id}" data-name="${c.name}" data-last4="${c.last4}"
                      data-type="${c.type}" data-validity="${c.validity}" data-flag="${c.flag}">✎</button>
              <form class="d-inline" method="post" action="${pageContext.request.contextPath}/card">
                <input type="hidden" name="action" value="delete"/>
                <input type="hidden" name="id" value="${c.id}"/>
                <button type="submit" class="btn btn-sm btn-outline-danger">🗑</button>
              </form>
            </div>
          </div>
        </c:forEach>

        <!-- botão + -->
        <button class="btn btn-outline-light card-plus rounded d-flex justify-content-center align-items-center"
                data-bs-toggle="modal" data-bs-target="#newCardModal">+</button>
      </div><!-- /cards-wrapper -->
    </div><!-- /cards-col -->

    <!-- ------------- Resumo ------------- -->
    <div class="summary-col">
      <div class="summary-wrapper">
        <h5 class="mb-2">📊 Resumo</h5>

        <div class="summary-grid">

          <div class="bg-success bg-opacity-25 rounded p-3">
            <h6 class="text-success-emphasis mb-1">Entradas (mês)</h6>
            <h4 class="text-success">R$ ${incomeMonth}</h4>
            <small>Total: R$ ${incomeTotal}</small>
          </div>

          <div class="bg-danger bg-opacity-25 rounded p-3">
            <h6 class="text-danger-emphasis mb-1">Saídas (mês)</h6>
            <h4 class="text-danger">R$ ${expenseMonth}</h4>
            <small>Total: R$ ${expenseTotal}</small>
          </div>

          <div class="bg-secondary bg-opacity-25 rounded p-3">
            <h6 class="mb-1">Saldo</h6>
            <h4>R$ ${saldoTotal}</h4>
            <small>Mês: R$ ${saldoMes}</small>
          </div>

        </div><!-- /summary-grid -->
      </div><!-- /summary-wrapper -->
    </div><!-- /summary-col -->

  </div><!-- /cards-summary -->

  <!-- ================= LISTA DE TRANSAÇÕES ================= -->
  <div class="row g-3">

    <!-- ENTRADAS -->
    <div class="col-md-4">
      <h5 class="mb-2">Entradas
        <button class="btn btn-sm btn-outline-light float-end"
                data-bs-toggle="modal" data-bs-target="#newTxModal"
                data-type="INCOME">+</button>
      </h5>
      <div class="bg-secondary rounded p-3 tx-block">
        <c:forEach items="${txIncome}" var="t">
          <div class="d-flex justify-content-between align-items-center border-bottom py-2">
            <div>
              <strong>R$ ${t.value}</strong>
              <small class="d-block">${t.payMethod}</small>
            </div>
            <div>
              <button class="btn btn-sm btn-outline-light" data-bs-toggle="modal"
                      data-bs-target="#editTxModal" data-id="${t.id}">✎</button>
              <form class="d-inline" method="post" action="${pageContext.request.contextPath}/transaction">
                <input type="hidden" name="action" value="delete"/>
                <input type="hidden" name="id" value="${t.id}"/>
                <input type="hidden" name="type" value="INCOME"/>
                <button type="submit" class="btn btn-sm btn-outline-danger">🗑</button>
              </form>
            </div>
          </div>
        </c:forEach>
      </div>
    </div>

    <!-- SAÍDAS -->
    <div class="col-md-4">
      <h5 class="mb-2">Saídas
        <button class="btn btn-sm btn-outline-light float-end"
                data-bs-toggle="modal" data-bs-target="#newTxModal"
                data-type="EXPENSE">+</button>
      </h5>
      <div class="bg-secondary rounded p-3 tx-block">
        <c:forEach items="${txExpense}" var="t">
          <div class="d-flex justify-content-between align-items-center border-bottom py-2">
            <div>
              <strong>R$ ${t.value}</strong>
              <small class="d-block">${t.payMethod}</small>
            </div>
            <div>
              <button class="btn btn-sm btn-outline-light" data-bs-toggle="modal"
                      data-bs-target="#editTxModal" data-id="${t.id}">✎</button>
              <form class="d-inline" method="post" action="${pageContext.request.contextPath}/transaction">
                <input type="hidden" name="action" value="delete"/>
                <input type="hidden" name="id" value="${t.id}"/>
                <input type="hidden" name="type" value="EXPENSE"/>
                <button type="submit" class="btn btn-sm btn-outline-danger">🗑</button>
              </form>
            </div>
          </div>
        </c:forEach>
      </div>
    </div>

    <!-- INVESTIMENTOS -->
    <div class="col-md-4">
      <h5 class="mb-2">Investimentos
        <button class="btn btn-sm btn-outline-light float-end"
                data-bs-toggle="modal" data-bs-target="#newTxModal"
                data-type="INVESTMENT">+</button>
      </h5>
      <div class="bg-secondary rounded p-3 tx-block">
        <c:forEach items="${txInvestment}" var="t">
          <div class="d-flex justify-content-between align-items-center border-bottom py-2">
            <div>
              <strong>R$ ${t.value}</strong>
              <small class="d-block">${t.payMethod}</small>
            </div>
            <div>
              <button class="btn btn-sm btn-outline-light" data-bs-toggle="modal"
                      data-bs-target="#editTxModal" data-id="${t.id}">✎</button>
              <form class="d-inline" method="post" action="${pageContext.request.contextPath}/transaction">
                <input type="hidden" name="action" value="delete"/>
                <input type="hidden" name="id" value="${t.id}"/>
                <input type="hidden" name="type" value="INVESTMENT"/>
                <button type="submit" class="btn btn-sm btn-outline-danger">🗑</button>
              </form>
            </div>
          </div>
        </c:forEach>
      </div>
    </div>

  </div><!-- /row transações -->

</div><!-- /container -->

<!-- =================== MODAIS (formulários) ================================ -->
<!-- exemplo simples de criação de cartão  --->
<div class="modal fade" id="newCardModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <form class="modal-content" method="post" action="${pageContext.request.contextPath}/card">
      <input type="hidden" name="action" value="create">
      <div class="modal-header bg-secondary text-light">
        <h5 class="modal-title">Novo cartão</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="mb-3">
          <label class="form-label">Tipo</label>
          <select name="type" class="form-select">
            <option>DEBIT</option>
            <option>CREDIT</option>
          </select>
        </div>
        <div class="mb-3">
          <label class="form-label">Validade</label>
          <input type="date" name="validity" class="form-control" required>
        </div>
        <div class="mb-3">
          <label class="form-label">Bandeira</label>
          <input type="text" name="flag" class="form-control" required>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-primary">Salvar</button>
      </div>
    </form>
  </div>
</div>

<!-- =========================================
     Modal: editar cartão
=============================================-->
<div class="modal fade" id="editCardModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <form class="modal-content" method="post" action="${pageContext.request.contextPath}/card">
      <input type="hidden" name="action" value="update">
      <input type="hidden" name="id" id="editCardId">
      <div class="modal-header bg-secondary text-light">
        <h5 class="modal-title">Editar cartão</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="mb-3">
          <label class="form-label">Tipo</label>
          <select name="type" id="editCardType" class="form-select">
            <option>DEBIT</option>
            <option>CREDIT</option>
          </select>
        </div>
        <div class="mb-3">
          <label class="form-label">Validade</label>
          <input type="date" name="validity" id="editCardValidity" class="form-control" required>
        </div>
        <div class="mb-3">
          <label class="form-label">Bandeira</label>
          <input type="text" name="flag" id="editCardFlag" class="form-control" required>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-primary">Salvar</button>
      </div>
    </form>
  </div>
</div>

<!-- =========================================
     Modal: nova transação
=============================================-->
<div class="modal fade" id="newTxModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <form class="modal-content" method="post" action="${pageContext.request.contextPath}/transaction">
      <input type="hidden" name="action" value="create">
      <input type="hidden" name="type" id="newTxType">
      <div class="modal-header bg-secondary text-light">
        <h5 class="modal-title">Nova transação</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="mb-3">
          <label class="form-label">Valor (R$)</label>
          <input type="number" step="0.01" name="value" class="form-control" required>
        </div>
        <div class="mb-3">
          <label class="form-label">Forma de pagamento</label>
          <select name="payMethod" class="form-select">
            <option>CASH</option>
            <option>CARD</option>
            <option>PIX</option>
            <option>BANK</option>
          </select>
        </div>
        <div class="mb-3">
          <label class="form-label">Data</label>
          <input type="datetime-local" name="date" class="form-control">
        </div>

        <div class="form-check mb-2">
          <input class="form-check-input" type="checkbox" value="S" name="transfer" id="newTxTransfer">
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

<!-- =========================================
     Modal: editar transação
=============================================-->
<div class="modal fade" id="editTxModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <form class="modal-content" method="post" action="${pageContext.request.contextPath}/transaction">
      <input type="hidden" name="action" value="update">
      <input type="hidden" name="id"  id="editTxId">
      <input type="hidden" name="type" id="editTxType">
      <div class="modal-header bg-secondary text-light">
        <h5 class="modal-title">Editar transação</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">

        <div class="mb-3">
          <label class="form-label">Valor (R$)</label>
          <input type="number" step="0.01" name="value" id="editTxValue" class="form-control" required>
        </div>

        <div class="mb-3">
          <label class="form-label">Forma de pagamento</label>
          <select name="payMethod" id="editTxPayMethod" class="form-select">
            <option>CASH</option>
            <option>CARD</option>
            <option>PIX</option>
            <option>BANK</option>
          </select>
        </div>

        <div class="mb-3">
          <label class="form-label">Data</label>
          <input type="datetime-local" name="date" id="editTxDate" class="form-control">
        </div>

        <div class="form-check mb-2">
          <input class="form-check-input" type="checkbox" value="S" name="transfer" id="editTxTransfer">
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

<!-- =========================================================
     Pequeno JS para preencher modais de edição
===========================================================-->
<script>
  document.addEventListener('shown.bs.modal', function (ev) {

    /* -------- cartão -------- */
    if (ev.target.id === 'editCardModal') {
      const btn  = ev.relatedTarget;              // botão ✎ que abriu
      const id   = btn.getAttribute('data-id');
      // Os campos seriam preenchidos via Ajax – ou com dataset já disponível.
      // Exemplo simples:
      document.getElementById('editCardId').value = id;
      // …preencha type, validity, flag (você pode buscar via dataset ou ajax)…
    }

    /* -------- transação (novo) -------- */
    if (ev.target.id === 'newTxModal') {
      const btn  = ev.relatedTarget;
      const type = btn.getAttribute('data-type');
      document.getElementById('newTxType').value = type;
    }

    /* -------- transação (edição) ------ */
    if (ev.target.id === 'editTxModal') {
      const btn  = ev.relatedTarget;
      const id   = btn.getAttribute('data-id');
      document.getElementById('editTxId').value = id;
      // Também seria necessário popular os demais campos via Ajax
    }
  });
</script>

<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</body>
</html>
