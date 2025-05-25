package br.com.kofin.controller;

import br.com.kofin.dao.CardsDao;
import br.com.kofin.model.entities.Cards;
import br.com.kofin.model.enums.CardType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

/**
 * Servlet /card
 * GET  /card                – lista cartões do usuário
 * GET  /card/view?id=12     – detalhes
 * POST /card (action=…)     – create | update | delete
 */
@WebServlet("/card/*")
public class CardsServlet extends HttpServlet {

    /* ---------------------------- GET --------------------------------- */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        int userId = (Integer) session.getAttribute("userId");

        /* rota /card/view */
        if (req.getPathInfo() != null && req.getPathInfo().startsWith("/view"))

        /* lista */
        try (CardsDao dao = new CardsDao()) {
            List<Cards> list = dao.listByUser(userId);
            req.setAttribute("cards", list);
            req.getRequestDispatcher("/WEB-INF/views/cards.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Erro ao listar cartões.", e);
        }
    }

    /* ---------------------------- POST -------------------------------- */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        int userId = (Integer) session.getAttribute("userId");

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ação não especificada.");
            return;
        }

        try (CardsDao dao = new CardsDao()) {

            switch (action) {

                /* ---------------- criar ---------------- */
                case "create" -> {
                    Cards c = new Cards();
                    c.setType(CardType.valueOf(req.getParameter("type").toUpperCase()));
                    c.setNumber((int) (1000_0000L + Math.random() * 9000_0000L));
                    c.setValidity(LocalDate.parse(req.getParameter("validity"))); // YYYY-MM-DD
                    c.setFlag(req.getParameter("flag"));
                    dao.register(c, userId);
                }

                /* ---------------- editar ---------------- */
                case "update" -> {
                    Cards c = dao.search(Integer.parseInt(req.getParameter("id")));
                    c.setType(CardType.valueOf(req.getParameter("type").toUpperCase()));
                    c.setValidity(LocalDate.parse(req.getParameter("validity")));
                    c.setFlag(req.getParameter("flag"));
                    dao.update(c);
                }

                /* ---------------- excluir --------------- */
                case "delete" -> {
                    dao.delete(Integer.parseInt(req.getParameter("id")));
                }

                default -> resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ação inválida.");
            }

        } catch (Exception e) {
            throw new ServletException("Erro ao processar cartão.", e);
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }
}
