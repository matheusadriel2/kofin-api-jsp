package br.com.kofin.controller;

import br.com.kofin.dao.CardsDao;
import br.com.kofin.exception.EntityNotFoundException;
import br.com.kofin.model.entities.Cards;
import br.com.kofin.model.enums.CardFlag;
import br.com.kofin.model.enums.CardType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

@WebServlet({"/cards", "/cards/*"})
public class CardsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        try (CardsDao dao = new CardsDao()) {
            List<Cards> list = dao.listByUser(userId);
            req.setAttribute("cards", list);
            req.getRequestDispatcher("/WEB-INF/views/cards.jsp")
                    .forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Falha ao listar cartões", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        int userId = (Integer) session.getAttribute("userId");
        String action = req.getParameter("action");

        try (CardsDao dao = new CardsDao()) {
            switch (action) {
                case "create" -> {
                    Cards c = new Cards();
                    fill(req, c);
                    dao.register(c, userId);
                }
                case "update" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    Cards c = dao.search(id);
                    fill(req, c);
                    dao.update(c);
                }
                case "delete" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    dao.delete(id);
                }
                default -> {
                    resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Ação inválida.");
                    return;
                }
            }
        } catch (EntityNotFoundException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Cartão não encontrado.");
            return;
        } catch (Exception e) {
            throw new ServletException("Erro ao processar operação de cartão", e);
        }

        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }

    private void fill(HttpServletRequest req, Cards c) {
        c.setName(req.getParameter("name"));

        String last4 = req.getParameter("last4");
        c.setLast4((last4 == null || last4.isBlank()) ? "XXXX" : last4);

        c.setType(CardType.valueOf(req.getParameter("type").toUpperCase()));
        c.setValidity(LocalDate.parse(req.getParameter("validity") + "-01"));

        String flag = req.getParameter("flag");
        c.setFlag((flag == null || flag.isBlank())
                ? null
                : CardFlag.valueOf(flag.toUpperCase()));
    }
}
