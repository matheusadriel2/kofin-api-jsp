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

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }
        int userId = (Integer) s.getAttribute("userId");

        try (CardsDao cDao = new CardsDao();
             TransactionsDao tDao = new TransactionsDao()) {

            /* ---------- cartões ---------- */
            List<Cards> cards = cDao.listByUser(userId);
            req.setAttribute("cards", cards);

            /* ---------- transações agrupadas ---------- */
            Map<TransactionType, List<Transactions>> grouped =
                    tDao.listByUser(userId).stream()
                            .collect(Collectors.groupingBy(Transactions::getType));

            req.setAttribute("txIncome",     grouped.getOrDefault(TransactionType.INCOME,     List.of()));
            req.setAttribute("txExpense",    grouped.getOrDefault(TransactionType.EXPENSE,    List.of()));
            req.setAttribute("txInvestment", grouped.getOrDefault(TransactionType.INVESTMENT, List.of()));

            /* ---------- resumo ---------- */
            YearMonth ym  = YearMonth.now();
            LocalDate d1 = ym.atDay(1);
            LocalDate dN = ym.atEndOfMonth();

            double incomeMonth  = tDao.sumByUserTypeAndDate(userId, TransactionType.INCOME , d1, dN);
            double expenseMonth = tDao.sumByUserTypeAndDate(userId, TransactionType.EXPENSE, d1, dN);

            double incomeTotal  = tDao.sumByUserAndType(userId, TransactionType.INCOME );
            double expenseTotal = tDao.sumByUserAndType(userId, TransactionType.EXPENSE);

            req.setAttribute("incomeMonth",  incomeMonth);
            req.setAttribute("expenseMonth", expenseMonth);
            req.setAttribute("incomeTotal",  incomeTotal);
            req.setAttribute("expenseTotal", expenseTotal);
            req.setAttribute("saldoMes",     incomeMonth  - expenseMonth);
            req.setAttribute("saldoTotal",   incomeTotal  - expenseTotal);

        } catch (SQLException e) {
            throw new ServletException("Falha ao carregar dashboard", e);
        }

        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(req, resp);
    }
}
