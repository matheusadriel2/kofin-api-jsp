<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Kofin · Cadastro</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.css" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
</head>
<body>
<div class="container-fluid vh-100 d-flex p-0">
  <div class="container text-center d-flex flex-column justify-content-center align-items-center gap-5 vh-100 p-0">
    <a href="${pageContext.request.contextPath}/">
      <img src="${pageContext.request.contextPath}/assets/logo-black.svg" alt="Logo" id="logo" />
    </a>
    <div class="d-flex flex-column w-50">
      <h2>Cadastro de Usuário</h2>
      <% if (request.getAttribute("error") != null) { %>
      <p class="text-danger"><%= request.getAttribute("error") %></p>
      <% } %>
      <form action="${pageContext.request.contextPath}/register" method="post" class="d-grid gap-2" novalidate>
        <input type="text" name="name" class="form-control" placeholder="Nome completo" required />
        <input type="email" name="email" class="form-control" placeholder="E-mail" required />
        <div class="input-group">
          <input type="password" name="password" class="form-control" placeholder="Senha" required />
          <span class="input-group-text">
              <i class="bi bi-eye-slash toggle-password"></i>
            </span>
        </div>
        <button type="submit" class="btn btn-secondary">Continuar</button>
      </form>
    </div>
  </div>
  <div class="bg-dark w-100 d-none d-lg-block">
    <img src="${pageContext.request.contextPath}/assets/geometric-pattern2.jpg" alt="Pattern" id="pattern" />
  </div>
</div>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/script.js"></script>