<%@ page contentType="text/html; charset=UTF-8" language="java"
         isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>Kofin • Dashboard</title>

  <!-- bootstrap 5 -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.css">
  <style>
    .h-scroll    { overflow-x: auto; white-space: nowrap; }
    .card-block  { min-width: 220px; height: 120px; }
    .card-plus   { width: 80px;  height:120px; }
    .tx-block    { max-height: 420px; overflow-y: auto; }
  </style>
</head>
<body class="bg-dark text-light">

<div class="container py-4">

  <!-- título / logout -->
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h2>Dashboard</h2>
    <a class="btn btn-sm btn-outline-light" href="${pageContext.request.contextPath}/logout">Sair</a>
  </div>

  <!-- ====== PARTE SUPERIOR ================================================= -->
  <div class="row g-3">

    <!-- cartões --------------------------------------------------------------------->
    <div class="col-md-6">
      <div class="bg-secondary rounded p-3 h-scroll d-flex gap-3">

        <!-- lista de cartões -->
        <c:forEach items="${cards}" var="c">
          <div class="bg-dark rounded card-block p-3 position-relative">
            <small class="text-muted">${c.flag}</small>
            <h5 class="mt-2">${c.type}</h5>
            <span class="fw-semibold">${c.number}</span>
            <small class="d-block">Val: ${c.validity}</small>

            <!-- ações -->
            <div class="position-absolute top-0 end-0 m-1">
              <button class="btn btn-sm btn-outline-light" data-bs-toggle="modal"
                      data-bs-target="#editCardModal" data-id="${c.id}">
                ✎
              </button>
              <form class="d-inline" method="post" action="${pageContext.request.contextPath}/card">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="id" value="${c.id}">
                <button type="submit" class="btn btn-sm btn-outline-danger">🗑</button>
              </form>
            </div>
          </div>
        </c:forEach>

        <!-- botão + -->
        <button class="btn btn-outline-light card-plus rounded d-flex justify-content-center align-items-center"
                data-bs-toggle="modal" data-bs-target="#newCardModal">
          +
        </button>
      </div>
    </div>

    <!-- total mês -->
    <div class="col-md-2">
      <div class="bg-secondary rounded text-center p-3 h-100">
        <h6>Total do mês</h6>
        <h4>R$ ${totalMonth}</h4>
      </div>
    </div>

    <!-- total geral -->
    <div class="col-md-2">
      <div class="bg-secondary rounded text-center p-3 h-100">
        <h6>Total geral</h6>
        <h4>R$ ${totalAll}</h4>
      </div>
    </div>

    <!-- saldo (exemplo) -->
    <div class="col-md-2">
      <div class="bg-secondary rounded text-center p-3 h-100">
        <h6>Saldo</h6>
        <h4>R$ ${totalAll - totalMonth}</h4>
      </div>
    </div>
  </div><!-- /parte superior -->

  <!-- ====== LISTA DE TRANSAÇÕES ============================================ -->
  <div class="row mt-4 g-3">

    <!-- INCOME -->
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

    <!-- EXPENSE -->
    <div class="col-md-4">
      <h5 class="mb-2">Saídas
        <button class="btn btn-sm btn-outline-light float-end"
                data-bs-toggle="modal" data-bs-target="#newTxModal"
                data-type="EXPENSE">+</button>
      </h5>
      <div class="bg-secondary rounded p-3 tx-block">
        <c:forEach items="${txExpense}" var="t">
          <!-- mesmo template -->
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

    <!-- INVESTMENT -->
    <div class="col-md-4">
      <h5 class="mb-2">Investimentos
        <button class="btn btn-sm btn-outline-light float-end"
                data-bs-toggle="modal" data-bs-target="#newTxModal"
                data-type="INVESTMENT">+</button>
      </h5>
      <div class="bg-secondary rounded p-3 tx-block">
        <c:forEach items="${txInvestment}" var="t">
          <!-- mesmo template -->
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

  </div><!-- /lista transações -->

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
