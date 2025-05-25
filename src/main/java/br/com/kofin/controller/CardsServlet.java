package br.com.kofin.controller;

import br.com.kofin.dao.CardsDao;
import br.com.kofin.model.entities.Cards;
import br.com.kofin.model.enums.CardType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/card/*")
public class CardsServlet extends HttpServlet {

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login"); return;
        }

        try (CardsDao dao = new CardsDao()) {
            List<Cards> list = dao.listByUser((Integer) s.getAttribute("userId"));
            req.setAttribute("cards", list);
        } catch (SQLException e) {
            throw new ServletException("Falha ao listar cartões", e);
        }
        req.getRequestDispatcher("/WEB-INF/views/cards.jsp").forward(req, resp);
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED); return;
        }
        int userId = (Integer) s.getAttribute("userId");
        String action = req.getParameter("action");

        try (CardsDao dao = new CardsDao()) {
            switch (action) {
                case "create" -> {
                    Cards c = new Cards();
                    fill(req, c);
                    dao.register(c, userId);
                }
                case "update" -> {
                    Cards c = dao.search(Integer.parseInt(req.getParameter("id")));
                    fill(req, c);
                    dao.update(c);
                }
                case "delete" -> dao.delete(Integer.parseInt(req.getParameter("id")));
                default       -> resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ação inválida.");
            }
        } catch (Exception e) {
            throw new ServletException("Erro no cartão", e);
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }

    private void fill(HttpServletRequest req, Cards c) {
        c.setName (req.getParameter("name"));
        String last4 = req.getParameter("last4");
        c.setLast4(last4 == null || last4.isBlank() ? "XXXX" : last4);
        c.setType (CardType.valueOf(req.getParameter("type").toUpperCase()));
        c.setValidity(LocalDate.parse(req.getParameter("validity") + "-01")); // <input type=month>
        c.setFlag (req.getParameter("flag"));
    }
}
