package br.com.kofin.controller;

import br.com.kofin.dao.TransactionsDao;
import br.com.kofin.model.entities.Transactions;
import br.com.kofin.model.enums.PaymentMethod;
import br.com.kofin.model.enums.Scheduled;
import br.com.kofin.model.enums.TransactionType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;

/**
 * Servlet /transaction
 * Ações:
 *   POST /transaction?action=create|update|delete
 *   Após o POST redireciona sempre para /dashboard
 */
@WebServlet("/transaction")
public class TransactionsServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ação não especificada.");
            return;
        }

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Usuário não autenticado.");
            return;
        }
        int userId = (Integer) session.getAttribute("userId");

        try (TransactionsDao dao = new TransactionsDao()) {
            switch (action) {
                case "create" -> {
                    Transactions t = buildFromRequest(req, false);
                    dao.register(t, userId);
                }
                case "update" -> {
                    Transactions t = buildFromRequest(req, true);
                    dao.update(t);
                }
                case "delete" -> {
                    int id = Integer.parseInt(required(req, "id"));
                    dao.delete(id);
                }
                default -> resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ação inválida.");
            }
        } catch (SQLException e) {
            throw new ServletException("Erro de banco de dados.", e);
        } catch (Exception e) {
            throw new ServletException("Falha ao processar transação.", e);
        }

        // Sempre retorna para a dashboard
        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }

    /**
     * Constrói o objeto Transactions a partir dos parâmetros de request.
     * @param req     HttpServletRequest
     * @param hasId   true se for update (precisa do parâmetro "id")
     */
    private Transactions buildFromRequest(HttpServletRequest req, boolean hasId) {
        Transactions t = new Transactions();

        if (hasId) {
            t.setId(Integer.parseInt(required(req, "id")));
        }

        // Nome e categoria (novos campos)
        t.setName(req.getParameter("txName"));
        t.setCategory(req.getParameter("category"));

        // Tipo, valor, método, transferência e agendamento
        try {
            t.setType(TransactionType.valueOf(required(req, "type").toUpperCase()));
            t.setValue(Double.parseDouble(required(req, "value")));
            t.setPayMethod(PaymentMethod.valueOf(required(req, "payMethod").toUpperCase()));
            t.setTransfer("S".equalsIgnoreCase(req.getParameter("transfer")));
            t.setIsScheduled(Scheduled.valueOf(required(req, "scheduled").toUpperCase()));
        } catch (IllegalArgumentException ex) {
            throw new IllegalArgumentException("Enum inválido: " + ex.getMessage());
        }

        // Cartão opcional (só se payMethod == CARD)
        String cardParam = req.getParameter("cardId");
        if ("CARD".equalsIgnoreCase(req.getParameter("payMethod"))
                && cardParam != null && !cardParam.isBlank()) {
            t.setCardId(Integer.parseInt(cardParam));
        }

        // Conta opcional
        String accParam = req.getParameter("accountId");
        if (accParam != null && !accParam.isBlank()) {
            t.setAccountId(Integer.parseInt(accParam));
        }

        // Data da transação
        String date = req.getParameter("date");
        if (date != null && !date.isBlank()) {
            try {
                t.setTransactionDate(LocalDateTime.parse(date));
            } catch (DateTimeParseException ex) {
                throw new IllegalArgumentException("Data inválida: " + date);
            }
        } else {
            t.setTransactionDate(LocalDateTime.now());
        }

        return t;
    }

    /** Garante que o parâmetro exista e não esteja em branco. */
    private String required(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        if (v == null || v.isBlank()) {
            throw new IllegalArgumentException("Campo obrigatório faltando: " + name);
        }
        return v;
    }
}
