package br.com.kofin.controller;

import br.com.kofin.dao.CardsDao;
import br.com.kofin.dao.TransactionsDao;
import br.com.kofin.model.entities.Cards;
import br.com.kofin.model.entities.Transactions;
import br.com.kofin.model.enums.PaymentMethod;
import br.com.kofin.model.enums.TransactionType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        int userId = (Integer) s.getAttribute("userId");

        // Filtro de cartões
        Integer cardFilter = null;
        String cardParam = req.getParameter("card");
        if (cardParam != null && !cardParam.isBlank())
            cardFilter = Integer.parseInt(cardParam);

        try (CardsDao cDao = new CardsDao();
             TransactionsDao tDao = new TransactionsDao()) {

            // Lista de cartões do usuário
            List<Cards> cards = cDao.listByUser(userId);
            req.setAttribute("cards", cards);
            req.setAttribute("selectedCard", cardFilter);

            // Lista de transações do usuário filtradas por cartão
            List<Transactions> all =
                    tDao.listByUserAndCard(userId, cardFilter);

            // Filtros de transações
            String q       = req.getParameter("q");
            String cat     = req.getParameter("cat");
            String pm      = req.getParameter("pm");
            String vminStr = req.getParameter("vmin");
            String vmaxStr = req.getParameter("vmax");

            Double vmin = (vminStr!=null && !vminStr.isBlank())
                    ? Double.parseDouble(vminStr)
                    : null;
            Double vmax = (vmaxStr!=null && !vmaxStr.isBlank())
                    ? Double.parseDouble(vmaxStr)
                    : null;

            // Aplicando filtros
            all = all.stream()
                    .filter(t -> q   == null || q.isBlank()
                            || t.getName().toLowerCase()
                            .contains(q.toLowerCase()))
                    .filter(t -> cat == null || cat.isBlank()
                            || (t.getCategory()!=null
                            && t.getCategory().toLowerCase()
                            .contains(cat.toLowerCase())))
                    .filter(t -> pm  == null || pm.isBlank()
                            || t.getPayMethod().name()
                            .equalsIgnoreCase(pm))
                    .filter(t -> vmin==null || t.getValue() >= vmin)
                    .filter(t -> vmax==null || t.getValue() <= vmax)
                    .toList();

            Map<TransactionType, List<Transactions>> grouped =
                    all.stream()
                            .collect(Collectors.groupingBy(Transactions::getType));

            req.setAttribute("txIncome",
                    grouped.getOrDefault(TransactionType.INCOME, List.of()));
            req.setAttribute("txExpense",
                    grouped.getOrDefault(TransactionType.EXPENSE, List.of()));
            req.setAttribute("txInvestment",
                    grouped.getOrDefault(TransactionType.INVESTMENT, List.of()));

            // Resumo do mês e total
            YearMonth ym = YearMonth.now();
            double incomeMonth  = sum(all, TransactionType.INCOME,  ym);
            double expenseMonth = sum(all, TransactionType.EXPENSE, ym);
            double incomeTotal  = sum(all, TransactionType.INCOME,  null);
            double expenseTotal = sum(all, TransactionType.EXPENSE, null);

            req.setAttribute("incomeMonth",  incomeMonth);
            req.setAttribute("expenseMonth", expenseMonth);
            req.setAttribute("incomeTotal",  incomeTotal);
            req.setAttribute("expenseTotal", expenseTotal);
            req.setAttribute("saldoMes",     incomeMonth  - expenseMonth);
            req.setAttribute("saldoTotal",   incomeTotal  - expenseTotal);
            req.setAttribute("paymentMethods", PaymentMethod.values());

        } catch (SQLException e) {
            throw new ServletException("Falha ao carregar dashboard", e);
        }

        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp")
                .forward(req, resp);
    }

    private double sum(List<Transactions> list,
                       TransactionType type,
                       YearMonth month) {
        return list.stream()
                .filter(t -> t.getType() == type)
                .filter(t -> month == null ||
                        YearMonth.from(t.getTransactionDate())
                                .equals(month))
                .mapToDouble(Transactions::getValue)
                .sum();
    }
}
