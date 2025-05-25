package br.com.kofin.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.List;

import br.com.kofin.dao.TransactionsDao;
import br.com.kofin.model.entities.Transactions;
import br.com.kofin.model.enums.PaymentMethod;
import br.com.kofin.model.enums.Scheduled;
import br.com.kofin.model.enums.TransactionType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/transaction")
public class TransactionsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String typeParam = request.getParameter("type");

            if (typeParam == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tipo de transação não especificado.");
                return;
            }

            TransactionType type;
            try {
                type = TransactionType.valueOf(typeParam.toUpperCase());
            } catch (IllegalArgumentException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tipo de transação inválido.");
                return;
            }

            TransactionsDao transDAO = new TransactionsDao();
            List<Transactions> trans = transDAO.getAllByType(type);

            request.setAttribute("transactions", trans);
            request.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Erro ao buscar transações", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if (action == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ação não especificada.");
            return;
        }

        try {
            TransactionsDao dao = new TransactionsDao();

            switch (action) {
                case "create":
                    Transactions newTransaction = extractTransactionFromRequest(request, false);
                    Integer userId = (Integer) request.getSession().getAttribute("userId");
                    if (userId == null) {
                        response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Usuário não autenticado.");
                        return;
                    }
                    dao.register(newTransaction, userId, null, null);
                    break;

                case "update":
                    Transactions updateTransaction = extractTransactionFromRequest(request, true);
                    dao.update(updateTransaction);
                    break;

                case "delete":
                    Integer idToDelete = Integer.parseInt(requireParam(request, "id"));
                    dao.delete(idToDelete);
                    break;

                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ação inválida.");
                    return;
            }

            response.sendRedirect(request.getContextPath() + "/transaction?type=" + request.getParameter("type"));

        } catch (Exception e) {
            throw new ServletException("Erro ao processar transação", e);
        }
    }

    private Transactions extractTransactionFromRequest(HttpServletRequest request, boolean hasId) {
        Transactions t = new Transactions();

        if (hasId) {
            t.setId(Integer.parseInt(requireParam(request, "id")));
        }

        try {
            t.setValue(Double.parseDouble(requireParam(request, "value")));
            t.setPayMethod(PaymentMethod.valueOf(requireParam(request, "payMethod").toUpperCase()));
            t.setType(TransactionType.valueOf(requireParam(request, "type").toUpperCase()));
            t.setIsScheduled(Scheduled.valueOf(requireParam(request, "scheduled").toUpperCase()));
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Valor inválido em enums de transação.");
        }

        String transfer = request.getParameter("transfer");
        t.setTransfer("S".equalsIgnoreCase(transfer));

        String date = request.getParameter("date");
        if (date != null && !date.isEmpty()) {
            try {
                t.setTransactionDate(LocalDateTime.parse(date));
            } catch (DateTimeParseException e) {
                throw new IllegalArgumentException("Formato de data inválido.");
            }
        } else {
            t.setTransactionDate(LocalDateTime.now());
        }

        return t;
    }

    private String requireParam(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("Campo obrigatório ausente ou vazio: " + name);
        }
        return value;
    }
}
