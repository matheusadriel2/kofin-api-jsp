<%@ page contentType="text/html; charset=UTF-8" language="java"
         isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Kofin</title>
    <link rel="stylesheet" href="<c:url value='/css/bootstrap.css'/>" />
    <link rel="stylesheet" href="<c:url value='/css/style.css'/>" />
</head>
<body class="bg-dark no-select">
<div class="container text-center d-flex justify-content-center align-items-center vh-100">
    <div class="d-flex flex-column align-items-center mb-4 gap-5">
        <a href="<c:url value='/'/>">
            <img src="<c:url value='/assets/logo-white.svg'/>" alt="Logo" id="logo" />
        </a>
        <div class="d-flex flex-column align-items-center text-start mb-4 gap-2">
            <div class="d-grid gap-2 col-12 mx-auto">
                <a class="btn btn-secondary" href="<c:url value='/login'/>" role="button">Entrar</a>
            </div>
            <p class="text-secondary">
                Não tem uma conta?
                <a class="text-light link-offset-2 link-underline link-underline-opacity-0"
                   href="<c:url value='/register'/>">Criar conta</a>
            </p>
        </div>
    </div>
</div>
<script src="<c:url value='/js/bootstrap.bundle.min.js'/>"></script>
<script src="<c:url value='/js/script.js'/>"></script>
</body>
</html>
