<%@ page contentType="text/html; charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core"      %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Kofin • Dashboard</title>

  <link rel="stylesheet"
        href="${pageContext.request.contextPath}/css/bootstrap.css"/>
  <link rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <style>
    .tx-block{
      max-height:420px;
      overflow-y:auto;

      /* esconde o desenho da barra sem impedir o scroll  */
      scrollbar-width:none;          /* Firefox */
      -ms-overflow-style:none;       /* IE/Edge antigo */
    }
    .tx-block::-webkit-scrollbar{    /* Chrome/Safari/Edge */
      display:none;
    }
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

    /* mostra os botões no hover ou após clique/tap */
    .tx-item:hover .tx-actions,
    .tx-item.show-actions .tx-actions{
      opacity:1 !important;     /* sobrepõe utility classes do Bootstrap   */
      pointer-events:auto;
    }
    .tx-actions{
      opacity:0;                 /* invisível                              */
      pointer-events:none;       /* nada clicável                          */
      transition:opacity .15s;   /* animação suave                         */
      position:absolute; top:4px; right:4px;          /* onde já estavam   */
      display:flex; gap:.25rem; z-index:5;             /* idem             */
    }

    .tx-item:hover .tx-actions,
    .tx-item.show-actions .tx-actions{
      opacity:1 !important;      /* força aparecer (sobrepõe utilities)    */
      pointer-events:auto;       /* agora pode clicar                      */
    }
    /* cursor de “link” quando passar sobre uma transação */
    .tx-item{cursor:pointer;}
    /* wrapper posicionado */
    .tx-col {
      position: relative;
    }

    /* scrollable */
    /* Faz .tx-col ser flex coluna e preencher a altura da col-md-4 */
    .tx-col {
      display: flex;
      flex-direction: column;
    }

    /* Faz tx-block crescer para preencher todo o wrapper */
    .tx-block {
      flex: 1;
      overflow-y: auto;
      scrollbar-width: none;         /* Firefox */
      -ms-overflow-style: none;      /* IE11 */
    }
    .tx-block::-webkit-scrollbar {
      display: none;                 /* Chrome/Safari */
    }

    /* Indicador fixo na base */
    .tx-scroll-indicator {
      position: absolute;
      bottom: 8px;
      left: 50%;
      transform: translateX(-50%);
      width: 60px;
      height: 8px;
      background: rgba(108,117,125,0.8);
      pointer-events: none;
      opacity: 0;
      transition: opacity .2s;
      clip-path: polygon(
              0 0,
              100% 0,
              100% 100%,
              60% 100%,
              50% 150%,
              40% 100%,
              0 100%
      );
      z-index: 10;
    }

    /* Só aparece enquanto scroll no meio da lista */
    .tx-col.show-scroll-hint .tx-scroll-indicator {
      opacity: .85;
    }

    /* =============  SIDEBAR DESKTOP  ============= */
    .sidebar{
      position:fixed;
      top:0; left:0;
      height:100vh;
      width:64px;                         /* colapsada */
      background:#212529;
      transition:width .2s;
      z-index:1040;                       /* acima do conteúdo */
    }
    .sidebar:hover,
    .sidebar:focus-within{                 /* expande ao hover/foco */
      width:220px;
    }
    .sidebar .brand{
      font-size:1.1rem;
    }
    .sidebar .nav-link{
      color:#adb5bd;
      padding:.75rem .5rem;
      white-space:nowrap;
      overflow:hidden;
      text-overflow:ellipsis;
    }
    .sidebar .nav-link:hover,
    .sidebar .nav-link.active{
      background:#0d6efd;
      color:#fff;
    }
    .sidebar i{ font-size:1.25rem; }
    .sidebar .link-text{                   /* aparece só quando expandido */
      display:none;
    }
    .sidebar:hover .link-text,
    .sidebar:focus-within .link-text{
      display:inline;
    }

    /* --- NAV-LINK agora fica centralizado no modo compacto
       e ganha padding à esquerda quando a barra expande --- */
    .sidebar .nav-link{
      display:flex;
      align-items:center;
      gap:.75rem;            /* espaço entre ícone e texto          */
      justify-content:center;
      padding:.75rem 0;      /* ↑↓ / ←→ (0 ←→ encosta menos)        */
    }

    .sidebar:hover   .nav-link,
    .sidebar:focus-within .nav-link{
      justify-content:flex-start; /* desloca itens p/ a direita      */
      padding-left:1rem;          /* margem interna confortável      */
    }

    /* marca‐texto (“link-text”) herda o gap acima, não precisa margin */


    /* ---------- TOP NAVBAR fixo ---------- */
    .navbar-app{
      position:fixed; top:0; left:0; right:0;
      z-index:1030;                 /* acima da sidebar   */
    }

    /* dá espaço p/ o conteúdo, pois a navbar tem 56 px */
    main{ margin-top:56px; }

    /* ---------- SIDEBAR ---------- */
    /*   < 1600 px  → colapsada (64 px) e expande no :hover
         ≥ 1600 px → já nasce expandida (220 px)              */
    @media (min-width:992px){          /* desktop em geral   */
      .sidebar{ width:64px; }
      main{ margin-left:64px; }      /* não fica coberto   */
      .sidebar:hover,
      .sidebar:focus-within{
        width:220px;
      }
    }
    @media (min-width:1600px){         /* telas muito largas */
      .sidebar{ width:220px; }       /* sempre expandida   */
      main{ margin-left:220px; }
      /* texto e alinhamento SEM precisar de :hover       */
      .sidebar .link-text{ display:inline; }
      .sidebar .nav-link{
        justify-content:flex-start;
        padding-left:1rem;
      }
    }

    /* ───────────── ESCONDE NAVBAR NO DESKTOP (>992px) ───────────── */
    @media (min-width: 992px) {
      .navbar-app .navbar-brand{
        display: none !important;
      }
      /* já que a navbar some, tira o margin-top do main */
      main {
        margin-top: 0 !important;
      }
    }

    /* ──────────── ESCONDE SIDEBAR NO MOBILE (<992px) ──────────── */
    @media (max-width: 991.98px) {
      .sidebar {
        display: none !important;
      }
      main {
        margin-left: 0 !important;
      }
    }


    /* ────────────── HAMBURGUER ────────────── */
    /* só aparece quando a sidebar está oculta (mobile) */
    @media (min-width: 992px) {
      .btn-hamb {
        display: none !important;
      }
    }
    @media (max-width: 991.98px) {
      .btn-hamb {
        display: inline-flex !important;
      }
    }

    /* aplica um padding interno extra em todas as larguras */
    main {
      padding-left: 1.5rem;
      padding-right: 1.5rem;
    }

    /* quando a sidebar está colapsada (64px), soma mais 0.5rem */
    @media (min-width: 992px) and (max-width: 1599.98px) {
      main {
        margin-left: calc(64px + 0.5rem);
      }
    }

    /* quando a sidebar está expandida (220px), soma mais 0.5rem */
    @media (min-width: 1600px) {
      main {
        margin-left: calc(220px + 0.5rem);
      }
    }


    /* remove bullet padrão do UL colado no offcanvas */
    .offcanvas-body ul{ list-style:none; padding:0; margin:0; }

    #offcanvasNav.offcanvas-start{
      width:220px;          /* mesmo width da sidebar aberta        */
    }

  </style>
</head>
<body class="bg-dark text-light d-flex">
<!-- ───────────── TOP NAVBAR ───────────── -->
<nav class="navbar navbar-dark bg-dark navbar-app">
  <div class="container-fluid justify-content-between">

    <!-- brand  -->
    <a href="${pageContext.request.contextPath}/dashboard"
       class="navbar-brand d-flex align-items-center">
      <img src="${pageContext.request.contextPath}/assets/logo-white.svg"
           alt="Kofin" width="32" height="32" class="me-2">
    </a>

    <!-- à direita -->
    <button class="btn btn-outline-light btn-sm btn-hamb"
            type="button"
            data-bs-toggle="offcanvas"
            data-bs-target="#offcanvasNav"
            aria-label="Menu">
      <i class="bi bi-list fs-5"></i>
    </button>
  </div>
</nav>

<!-- ────────────────  SIDEBAR  ──────────────── -->
<nav id="sidebar" class="sidebar flex-column flex-shrink-0">
  <!-- Logo / brand -->
  <a href="${pageContext.request.contextPath}/dashboard"
     class="brand text-decoration-none text-light d-flex align-items-center justify-content-center py-3">
    <!-- ícone ou imagem pequena   -->
    <img src="${pageContext.request.contextPath}/assets/logo-white.svg"
         alt="Kofin" width="32" height="32" class="me-0 me-lg-2">
  </a>

  <!-- Navegação -->
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

  <!-- logout na base -->
  <a href="${pageContext.request.contextPath}/logout"
     class="nav-link text-light logout-link mb-3 mt-lg-auto">
    <i class="bi bi-box-arrow-right me-lg-2"></i>
    <span class="link-text">Sair</span>
  </a>

</nav>

<!-- Off-canvas para tablet/móvel -->
<div class="offcanvas offcanvas-start text-bg-dark" tabindex="-1" id="offcanvasNav">
  <div class="offcanvas-header">
    <a href="${pageContext.request.contextPath}/dashboard"
       class="brand text-decoration-none text-light d-flex align-items-center justify-content-center py-3">
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

<!-- ────────────────  CONTEÚDO  ──────────────── -->
<main class="flex-grow-1">

  <div class="container-fluid py-4">

  <!-- header -->
  <div class="d-flex justify-content-between mb-4">
    <h2>Dashboard</h2>
  </div>

  <!-- =================== ROW: CARTÕES + RESUMO =================== -->
  <div class="row gy-4 mb-5">

    <!-- =============== BLOCO: CARTÕES ================= -->
    <div class="col-12 col-xl-5">
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
    <div class="col-12 col-xl-7 d-flex flex-column">
      <h5 class="mb-2">Resumo</h5>
      <h6 class="mb-3">Confira suas entradas e despesas semanais...</h6>

      <!-- row-cols-* controla colunas; 1 nos xs, 3 a partir de sm -->
      <div class="row row-cols-1 row-cols-md-3 g-3 flex-grow-1">

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
    <div class="bg-secondary rounded p-3">
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




</script>


<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</main>
</body>
</html>
