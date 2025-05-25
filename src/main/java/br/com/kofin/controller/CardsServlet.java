package br.com.kofin.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

import br.com.kofin.dao.CardsDao;
import br.com.kofin.dao.UsersDao;
import br.com.kofin.model.entities.Cards;
import br.com.kofin.model.entities.Users;
import br.com.kofin.model.enums.CardType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/card")
public class CardsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        int userId = (Integer) session.getAttribute("userId");

        try (UsersDao usersDao = new UsersDao()) {
            Users user = usersDao.search(userId);
            request.setAttribute("user", user);
        } catch (Exception e) {
            throw new ServletException("Erro ao buscar usuário", e);
        }

        try {
            CardsDao cardsDAO = new CardsDao();
            List<Cards> cards = cardsDAO.getAllByUser(userId);
            request.setAttribute("cards", cards);
            request.getRequestDispatcher("/WEB-INF/views/dashboard.jsp")
                    .forward(request, response);
        } catch (SQLException e) {
            throw new ServletException("Erro ao buscar cartões", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        int userId = (Integer) session.getAttribute("userId");

        try {
            CardsDao dao = new CardsDao();
            String action = request.getParameter("action");

            if ("delete".equals(action)) {
                Integer cardId = Integer.parseInt(request.getParameter("cardId"));
                dao.delete(cardId);

            } else {
                Cards card = new Cards();
                card.setType(CardType.CREDIT);
                card.setNumber((int)(100000000 + Math.random() * 900000000));
                card.setValidity(LocalDate.now().plusYears(5));
                card.setFlag("VISA");

                dao.register(card, userId);
            }

            response.sendRedirect(request.getContextPath() + "/card");
        } catch (Exception e) {
            throw new ServletException("Erro ao processar cartão", e);
        }
    }
}