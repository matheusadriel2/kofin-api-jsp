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
import java.util.List;

/**
 * Servlet /transaction
 * Ações:
 *   GET  /transaction?type=INCOME            -> lista por tipo (mais recente primeiro)
 *   GET  /transaction/view?id=123            -> detalhes
 *   POST /transaction (action=create|update|delete)
 */
@WebServlet("/transaction/*")
public class TransactionsServlet extends HttpServlet {

    /* ------------------------ GET -------------------------------------------------------- */

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        int userId = (Integer) session.getAttribute("userId");

        /* rota /transaction/view?id= */
        if (req.getPathInfo() != null && req.getPathInfo().startsWith("/view")) {
            int id = Integer.parseInt(req.getParameter("id"));
            try (TransactionsDao dao = new TransactionsDao()) {
                Transactions t = dao.search(id);
                req.setAttribute("transaction", t);
                req.getRequestDispatcher("/WEB-INF/views/transactionDetail.jsp").forward(req, resp);
            } catch (Exception e) {
                throw new ServletException("Erro ao buscar transação.", e);
            }
            return;
        }

        /* lista por tipo */
        String typeParam = req.getParameter("type");
        if (typeParam == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tipo de transação não especificado.");
            return;
        }

        try {
            TransactionType type = TransactionType.valueOf(typeParam.toUpperCase());
            List<Transactions> list;
            try (TransactionsDao dao = new TransactionsDao()) {
                list = dao.listByUserAndType(userId, type);
            }
            req.setAttribute("transactions", list);
            req.setAttribute("selectedType", typeParam);
            req.getRequestDispatcher("/WEB-INF/views/transactions.jsp").forward(req, resp);

        } catch (IllegalArgumentException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tipo inválido.");
        } catch (SQLException e) {
            throw new ServletException("Erro ao listar transações.", e);
        }
    }

    /* ------------------------ POST ------------------------------------------------------- */

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

                /* ---------- criar -------------------------------------------------- */
                case "create" -> {
                    Transactions t = buildFromRequest(req, false);
                    dao.register(t, userId);
                }

                /* ---------- editar -------------------------------------------------- */
                case "update" -> {
                    Transactions t = buildFromRequest(req, true);
                    dao.update(t);
                }

                /* ---------- excluir ------------------------------------------------- */
                case "delete" -> {
                    int id = Integer.parseInt(required(req, "id"));
                    dao.delete(id);
                }

                default -> resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ação inválida.");
            }
        } catch (Exception e) {
            throw new ServletException("Falha ao processar transação.", e);
        }

        /* redireciona de volta para a lista do tipo atual */
        resp.sendRedirect(req.getContextPath() + "/transaction?type=" + req.getParameter("type"));
    }

    /* -------------------- helpers -------------------------------------------------------- */

    private Transactions buildFromRequest(HttpServletRequest req, boolean hasId) {
        Transactions t = new Transactions();

        if (hasId) t.setId(Integer.parseInt(required(req, "id")));

        try {
            t.setType(TransactionType.valueOf(required(req, "type").toUpperCase()));
            t.setValue(Double.parseDouble(required(req, "value")));
            t.setPayMethod(PaymentMethod.valueOf(required(req, "payMethod").toUpperCase()));
            t.setTransfer("S".equalsIgnoreCase(req.getParameter("transfer")));
            t.setIsScheduled(Scheduled.valueOf(required(req, "scheduled").toUpperCase()));
        } catch (IllegalArgumentException ex) {
            throw new IllegalArgumentException("Enum inválido: " + ex.getMessage());
        }

        /* opcional: cardId e accountId */
        String cardParam = req.getParameter("cardId");
        if (cardParam != null && !cardParam.isBlank()) t.setCardId(Integer.parseInt(cardParam));

        String accParam = req.getParameter("accountId");
        if (accParam != null && !accParam.isBlank()) t.setAccountId(Integer.parseInt(accParam));

        /* data da transação */
        String date = req.getParameter("date");
        if (date != null && !date.isBlank()) {
            try { t.setTransactionDate(LocalDateTime.parse(date)); }
            catch (DateTimeParseException ex) { throw new IllegalArgumentException("Data inválida."); }
        } else {
            t.setTransactionDate(LocalDateTime.now());
        }

        return t;
    }

    private String required(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        if (v == null || v.isBlank())
            throw new IllegalArgumentException("Campo obrigatório faltando: " + name);
        return v;
    }
}
