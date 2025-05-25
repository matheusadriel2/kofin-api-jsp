<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <title>Dashboard</title>
</head>
<body>
<h1>Dashboard</h1>
<p>Bem‑vindo, <%= ((br.com.kofin.model.entities.Users)request.getAttribute("user")).getFirstName() %>!</p>
<p>Seu e‑mail: <%= ((br.com.kofin.model.entities.Users)request.getAttribute("user")).getEmail() %></p>
<p><a href="<%= request.getContextPath() %>/logout">Sair</a></p>
</body>
</html>