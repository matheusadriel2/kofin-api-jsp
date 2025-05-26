<%@ page contentType="text/html; charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core"      %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>kofin · Dashboard</title>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/bootstrap.css"/>
  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/dashboard.css"/>
  <link rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

  <style>
    html, body { font-family: 'Roboto', sans-serif; }
  </style>
</head>
<body class="bg-light text-dark d-flex">

<!-- SIDEBAR -->
<nav id="sidebar" class="sidebar flex-column flex-shrink-0">
  <a href="${pageContext.request.contextPath}/dashboard"
     class="brand text-decoration-none text-dark d-flex align-items-center justify-content-center py-3">

    <img src="${pageContext.request.contextPath}/assets/logo-black.svg"
         alt="Kofin"
         class="sidebar-logo-expanded"
         style="width:75%;height:75%;padding:1rem;" />

    <div class="sidebar-logo-circle"
         style="
           width:1.5rem;
           height:1.5rem;
           background:#EDCE78;
           border-radius:50%;
         "></div>
  </a>

  <ul class="nav nav-pills flex-column mb-auto w-100">
    <li class="nav-item">
      <a class="nav-link active" href="${pageContext.request.contextPath}/dashboard">
        <i class="bi bi-speedometer2 me-lg-2"></i>
        <span class="link-text">Dashboard</span>
      </a>
    </li>

    <li>
      <a class="nav-link" href="#">
        <i class="bi bi-wallet2 me-lg-2"></i>
        <span class="link-text">Carteira</span>
      </a>
    </li>

    <li>
      <a class="nav-link" href="#">
        <i class="bi bi-bar-chart-line me-lg-2"></i>
        <span class="link-text">Relatórios</span>
      </a>
    </li>

    <li>
      <a class="nav-link" href="#">
        <i class="bi bi-gear me-lg-2"></i>
        <span class="link-text">Configurações</span>
      </a>
    </li>
  </ul>

  <hr class="d-none d-lg-block border-secondary my-1">

  <a href="${pageContext.request.contextPath}/logout"
     class="nav-link text-dark logout-link mb-3 mt-lg-auto">
    <i class="bi bi-box-arrow-right me-lg-2"></i>
    <span class="link-text">Sair</span>
  </a>
</nav>

<!-- Off-canvas para tablet/móvel -->
<div class="offcanvas offcanvas-start text-dark" tabindex="-1" id="offcanvasNav">
  <div class="offcanvas-header">
    <a href="${pageContext.request.contextPath}/dashboard"
       class="brand text-decoration-none text-dark d-flex align-items-center justify-content-center py-3">
      <!-- ícone ou imagem pequena   -->
      <img src="${pageContext.request.contextPath}/assets/logo-white.svg"
           alt="Kofin" width="40" height="40" class="me-0 me-lg-2">
    </a>
    <button class="btn-close btn-close-white" data-bs-dismiss="offcanvas"></button>
  </div>
  <div class="offcanvas-body p-0">
    <!-- reutiliza o mesmo <ul> da sidebar via JS -->
  </div>
</div>

<!-- CONTEÚDO -->
<main class="flex-grow-1">

  <div class="container-fluid pt-4 mt-2">

  <!-- header -->
  <div class="d-flex justify-content-between mb-3">
    <h3>Dashboard</h3>
  </div>

  <!-- =================== ROW: CARTÕES + RESUMO =================== -->
  <div class="row gy-4 mb-5 gap-3">

    <!-- =============== BLOCO: CARTÕES ================= -->
    <div class="col-12 col-xl-5 d-flex flex-column border border-dark rounded-2 p-4">
      <div class="d-flex flex-row justify-content-between mb-4">
        <div>
          <h5 class="mb-2">Cartões</h5>
          <h6 class="mb-0">Gerencie seus cartões</h6>
        </div>

        <!-- botão + para novo cartão -->
        <button
                class="btn btn-sm btn-outline-secondary rounded-circle p-0 add-card-btn align-self-end"
                data-bs-toggle="modal"
                data-bs-target="#newCardModal">+</button>
      </div>
      <div class="bg-light rounded p-0 cards-wrap">

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

                <c:if test="${not empty c.flag}">
                  <span
                    class="card-flag ${fn:toLowerCase(c.flag.name())}"
                    title="${c.flag}">
                  </span>
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
                      action="${pageContext.request.contextPath}/cards"
                      onclick="event.stopPropagation()">
                  <input type="hidden" name="action" value="delete"/>
                  <input type="hidden" name="id"     value="${c.id}"/>
                  <button type="submit" class="btn btn-sm btn-outline-danger">🗑</button>
                </form>
              </div>
            </div>
          </c:forEach>

        </div><!-- /h-scroll -->



        <!-- barra‐dica de scroll -->
        <div class="scroll-hint" id="scrollHint"></div>
      </div>
    </div><!-- /Cartões -->

    <!-- Resumo ------------------------------------------------------ -->

    <div class="d-flex flex-column align-items-start border border-dark rounded-2 p-4 w-auto">
      <h5 class="mb-2">Resumo</h5>
      <h6 class="mb-4">Confira suas entradas e despesas semanais</h6>

      <!-- container flex: coluna no XS, linha no MD+, gap entre cards, centralizado -->
      <div class="d-flex flex-column flex-md-row justify-content-center gap-3 w-auto">

        <!-- Card 1 -->
        <div style="min-width: 200px; height: 140px" class="d-flex flex-column align-items-center bg-success bg-opacity-25 rounded p-3">
          <h6 class="text-success-emphasis">Entradas (mês)</h6>
          <h4 class="text-success">R$ ${incomeMonth}</h4>
          <small>Total: R$ ${incomeTotal}</small>
        </div>

        <!-- Card 2 -->
        <div class="d-flex flex-column align-items-center bg-danger bg-opacity-25 rounded p-3">
          <h6 class="text-danger-emphasis">Saídas (mês)</h6>
          <h4 class="text-danger">R$ ${expenseMonth}</h4>
          <small>Total: R$ ${expenseTotal}</small>
        </div>

        <!-- Card 3 -->
        <div class="d-flex flex-column align-items-center bg-secondary bg-opacity-25 rounded p-3">
          <h6>Saldo</h6>
          <h4>R$ ${saldoTotal}</h4>
          <small>Mês: R$ ${saldoMes}</small>
        </div>

      </div>
    </div>

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
        <%-- ---------- BOTÃO “LIMPAR” (aparece só quando há parâmetros) --------- --%>
        <c:if test="${param.card  ne null or
               param.cat   ne null or
               param.q     ne null or
               param.pm    ne null or
               param.vmin  ne null or
               param.vmax  ne null}">
          <a href="${pageContext.request.contextPath}/dashboard"
             class="btn btn-sm btn-outline-warning ms-1">Limpar</a>
        </c:if>
      </form>

    </div>

    <!-- colunas -------------------------------------------------------------- -->
    <div class="bg-light rounded p-3">
      <div class="row row-cols-1 row-cols-md-3 g-3 align-items-stretch">

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


<!-- MODAIS -->
<!-- Modal: criação de cartão  -->
<div class="modal fade" id="newCardModal" tabindex="-1">
  <div class="modal-dialog">
    <form class="modal-content" method="post" action="${pageContext.request.contextPath}/cards">
      <input type="hidden" name="action" value="create"/>

      <div class="modal-header bg-light text-dark">
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
    <form class="modal-content" method="post" action="${pageContext.request.contextPath}/cards">
      <input type="hidden" name="action" value="update"/>
      <input type="hidden" name="id" id="editCardId"/>

      <div class="modal-header bg-light text-dark">
        <h5 class="modal-title">Editar cartão</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">
        <div class="mb-3">
          <label class="form-label">Nome do cartão</label>
          <input type="text" name="name" id="editCardName" class="form-control" required/>
        </div>

        <div class="mb-3">
          <label class="form-label">Últimos 4 dígitos</label>
          <input type="text" name="last4" id="editCardLast4" class="form-control"
                 maxlength="4" pattern="\d{4}" title="Insira exatamente 4 números"/>
        </div>

        <div class="mb-3">
          <label class="form-label">Tipo</label>
          <select name="type" id="editCardType" class="form-select">
            <option value="DEBIT">Débito</option>
            <option value="CREDIT">Crédito</option>
          </select>
        </div>

        <div class="mb-3">
          <label class="form-label">Validade</label>
          <input type="month" name="validity" id="editCardValidity" class="form-control" required/>
        </div>

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

<!-- MODAL: NOVA TRANSAÇÃO -->
<div class="modal fade" id="newTxModal" tabindex="-1">
  <div class="modal-dialog">
    <form class="modal-content" method="post" action="${pageContext.request.contextPath}/transaction">
      <input type="hidden" name="action" value="create"/>
      <input type="hidden" name="type"   id="newTxType"/>

      <div class="modal-header bg-light text-dark">
        <h5 class="modal-title">Nova transação</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">

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
            <c:forEach var="pm" items="${paymentMethods}">
              <option value="${pm.name()}"
                ${pm.name() == param.pm ? 'selected' : ''}>
                  ${pm.name()}
              </option>
            </c:forEach>
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


<!-- MODAL: EDITAR TRANSAÇÃO -->
<div class="modal fade" id="editTxModal" tabindex="-1">
  <div class="modal-dialog">
    <form class="modal-content" method="post" action="${pageContext.request.contextPath}/transaction">
      <input type="hidden" name="action" value="update"/>
      <input type="hidden" name="id"     id="editTxId"/>
      <input type="hidden" name="type"   id="editTxType"/>

      <div class="modal-header bg-light text-dark">
        <h5 class="modal-title">Editar transação</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">

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
          <label class="form-label">Forma de pagamento</label>
          <select name="payMethod" id="editPayMethod" class="form-select">
            <c:forEach var="pm" items="${paymentMethods}">
              <option value="${pm.name()}"
                ${pm.name() == editPayMethod.value ? 'selected' : ''}>
                  ${pm.name()}
              </option>
            </c:forEach>
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

  <!-- MODAL: VISUALIZAR TRANSAÇÃO -->
  <div class="modal fade" id="viewTxModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content border-0 shadow-sm">

        <div class="modal-header bg-light text-dark">
          <h5 class="modal-title">Detalhes da Transação</h5>
          <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
        </div>

        <div class="modal-body">
          <table class="table table-striped mb-0">
            <tbody>
            <tr>
              <th scope="row" class="w-25">Nome</th>
              <td id="tx-name"></td>
            </tr>
            <tr>
              <th scope="row">Categoria</th>
              <td id="tx-cat"></td>
            </tr>
            <tr>
              <th scope="row">Tipo</th>
              <td id="tx-type"></td>
            </tr>
            <tr>
              <th scope="row">Valor</th>
              <td id="tx-val"></td>
            </tr>
            <tr>
              <th scope="row">Método de Pagamento</th>
              <td id="tx-pm"></td>
            </tr>
            <tr>
              <th scope="row">Data</th>
              <td id="tx-date"></td>
            </tr>
            </tbody>
          </table>
        </div>

        <div class="modal-footer">
          <button type="button"
                  class="btn btn-secondary"
                  data-bs-dismiss="modal">
            Fechar
          </button>
        </div>

      </div>
    </div>
  </div>


<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
  <script src="${pageContext.request.contextPath}/js/dashboard.js"></script>
</main>
</body>
</html>
