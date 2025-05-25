<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Kofin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
</head>
<body class="bg-dark no-select">
<div class="container text-center d-flex justify-content-center align-items-center vh-100">
    <div class="d-flex flex-column align-items-center mb-4 gap-5">
        <a href="${pageContext.request.contextPath}/">
            <img src="${pageContext.request.contextPath}/assets/logo-white.svg" alt="Logo" id="logo" />
        </a>
        <div class="d-flex flex-column align-items-center text-start mb-4 gap-2">
            <div class="d-grid gap-2 col-12 mx-auto">
                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/login" role="button">Entrar</a>
            </div>
            <p class="text-secondary">
                Não tem uma conta?
                <a class="text-light link-offset-2 link-underline link-underline-opacity-0" href="${pageContext.request.contextPath}/register">Criar conta</a>
            </p>
        </div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/script.js"></script>
</body>
</html>