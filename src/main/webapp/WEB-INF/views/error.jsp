<%@ page contentType="text/html; charset=UTF-8" language="java"
         isErrorPage="true" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>kofin · Erro</title>

  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css"/>
  <style> html, body { font-family: 'Montserrat', sans-serif; } </style>
</head>
<body class="bg-light text-dark d-flex">

<main class="flex-grow-1 d-flex align-items-center justify-content-center">
  <div class="text-center p-4" style="max-width:400px;">
    <i class="bi bi-exclamation-triangle-fill text-warning" style="font-size:4rem;"></i>
    <h1 class="mt-3">Ops! Algo deu errado</h1>
    <p class="lead">
      <strong>Código:</strong> ${requestScope['javax.servlet.error.status_code'] ?: statusCode}
    </p>
    <p>
      <strong>Mensagem:</strong><br/>
      ${requestScope['javax.servlet.error.message'] ?: message}
    </p>
    <c:if test="${exception != null}">
      <p class="text-muted small">${exception.message}</p>
    </c:if>
    <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary mt-3">
      Voltar ao Dashboard
    </a>
  </div>
</main>

</body>
</html>
