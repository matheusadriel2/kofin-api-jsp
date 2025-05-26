<%@ page contentType="text/html; charset=UTF-8" language="java"
         isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Kofin · Logout</title>
    <link rel="stylesheet" href="<c:url value='/css/bootstrap.css'/>" />
    <link rel="stylesheet" href="<c:url value='/css/style.css'/>" />
</head>
<body class="bg-dark no-select">
<div class="container vh-100 d-flex justify-content-center align-items-center">
    <div class="text-center d-flex flex-column align-items-center gap-2">
        <a href="<c:url value='/'/>">
            <img src="<c:url value='/assets/logo-white.svg'/>" alt="Logo" id="logo" />
        </a>

        <h3 class="text-light mb-1">Você saiu com sucesso!</h3>
        <p class="text-secondary mb-3">Até breve.</p>

        <a href="<c:url value='/login'/>"
           class="btn btn-secondary"
           role="button">
            Entrar novamente
        </a>
    </div>
</div>

<script src="<c:url value='/js/bootstrap.bundle.min.js'/>"></script>
<script src="<c:url value='/js/script.js'/>"></script>
</body>
</html>
