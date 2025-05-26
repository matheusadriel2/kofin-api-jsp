<%@ page contentType="text/html; charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Carregando…</title>
    <link rel="stylesheet" href="<c:url value='/css/bootstrap.css'/>"/>
    <style>
        body {
            background: #fff;
        }
        #loading-logo {
            width: 120px;
            animation: pulse 1.5s ease-in-out infinite;
        }
        @keyframes pulse {
            0%   { transform: scale(1); }
            50%  { transform: scale(1.2); }
            100% { transform: scale(1); }
        }
    </style>
</head>
<body class="d-flex justify-content-center align-items-center vh-100">
<div class="d-flex flex-column align-items-center">
    <img id="loading-logo" src="<c:url value='/assets/logo-black.svg'/>" alt="Kofin"/>
    <div class="spinner-border text-secondary mt-3" role="status">
        <span class="visually-hidden">Carregando…</span>
    </div>
</div>

<script>
    setTimeout(function(){
        window.location.href = '<c:url value="/dashboard"/>';
    }, 800);
</script>
</body>
</html>
