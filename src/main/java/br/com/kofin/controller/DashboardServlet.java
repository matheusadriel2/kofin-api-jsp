package br.com.kofin.controller;

import br.com.kofin.dao.CardsDao;
import br.com.kofin.dao.TransactionsDao;
import br.com.kofin.model.entities.Cards;
import br.com.kofin.model.entities.Transactions;
import br.com.kofin.model.enums.TransactionType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        int userId = (Integer) session.getAttribute("userId");

        try (CardsDao cDao = new CardsDao();
             TransactionsDao tDao = new TransactionsDao()) {

            /* ---------------- cartões ---------------- */
            List<Cards> cards = cDao.listByUser(userId);
            req.setAttribute("cards", cards);

            /* ---------------- transações agrupadas ---------------- */
            Map<TransactionType, List<Transactions>> grouped =
                    tDao.listByUser(userId).stream()
                            .collect(Collectors.groupingBy(Transactions::getType));

            req.setAttribute("txIncome",     grouped.getOrDefault(TransactionType.INCOME,     List.of()));
            req.setAttribute("txExpense",    grouped.getOrDefault(TransactionType.EXPENSE,    List.of()));
            req.setAttribute("txInvestment", grouped.getOrDefault(TransactionType.INVESTMENT, List.of()));

            /* ---------------- totais ---------------- */
            YearMonth now   = YearMonth.now();
            LocalDate firstDay = now.atDay(1);
            LocalDate lastDay  = now.atEndOfMonth();

            double totalMonth = tDao.sumByUserAndDateRange(userId, firstDay, lastDay);

            double totalAll   = tDao.sumByUser(userId);

            req.setAttribute("totalMonth", totalMonth);
            req.setAttribute("totalAll"  , totalAll );

        } catch (SQLException e) {
            throw new ServletException("Erro ao carregar dashboard", e);
        }

        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp")
                .forward(req, resp);
    }
}
