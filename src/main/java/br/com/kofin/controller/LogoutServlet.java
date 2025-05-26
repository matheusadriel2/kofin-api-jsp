package br.com.kofin.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null) session.invalidate();

        Cookie jwtCookie = new Cookie("token", "");
        jwtCookie.setPath(req.getContextPath());
        jwtCookie.setHttpOnly(true);
        jwtCookie.setMaxAge(0);
        resp.addCookie(jwtCookie);

        req.getRequestDispatcher("/WEB-INF/views/logout.jsp")
                .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }
}

