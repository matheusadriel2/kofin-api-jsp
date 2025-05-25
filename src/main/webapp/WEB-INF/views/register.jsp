<%@ page contentType="text/html; charset=UTF-8" language="java"
         isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Kofin · Cadastro</title>
  <link rel="stylesheet" href="<c:url value='/css/bootstrap.css'/>" />
  <link rel="stylesheet" href="<c:url value='/css/style.css'/>" />
</head>
<body>
<div class="container-fluid vh-100 d-flex p-0">
  <div class="container text-center d-flex flex-column justify-content-center align-items-center gap-5 vh-100 p-0">
    <a href="<c:url value='/'/>">
      <img src="<c:url value='/assets/logo-black.svg'/>" alt="Logo" id="logo" />
    </a>
    <div class="d-flex flex-column w-50">
      <h2>Cadastro de Usuário</h2>

      <c:if test="${not empty error}">
        <p class="text-danger">${error}</p>
      </c:if>

      <form action="<c:url value='/register'/>" method="post" class="d-grid gap-2" novalidate>
        <input type="text"  name="name"     class="form-control" placeholder="Nome completo" required />
        <input type="email" name="email"    class="form-control" placeholder="E-mail" required />
        <div class="input-group">
          <input type="password" name="password" class="form-control" placeholder="Senha" required />
          <span class="input-group-text"><i class="bi bi-eye-slash toggle-password"></i></span>
        </div>
        <button type="submit" class="btn btn-secondary">Continuar</button>
      </form>
    </div>
  </div>

  <div class="bg-dark w-100 d-none d-lg-block">
    <img src="<c:url value='/assets/geometric-pattern2.jpg'/>" alt="Pattern" id="pattern" />
  </div>
</div>

<script src="<c:url value='/js/bootstrap.bundle.min.js'/>"></script>
<script src="<c:url value='/js/script.js'/>"></script>
</body>
</html>
