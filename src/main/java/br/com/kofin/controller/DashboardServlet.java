package br.com.kofin.controller;

import br.com.kofin.dao.UsersDao;
import br.com.kofin.exception.EntityNotFoundException;
import br.com.kofin.model.entities.Users;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

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
        try (UsersDao usersDao = new UsersDao()) {
            Users user = usersDao.search(userId);
            req.setAttribute("user", user);
        } catch (SQLException | EntityNotFoundException e) {
            throw new ServletException("Erro ao carregar dashboard", e);
        }

        req.getRequestDispatcher("/WEB-INF/views/dashboard.jsp")
                .forward(req, resp);
    }
}