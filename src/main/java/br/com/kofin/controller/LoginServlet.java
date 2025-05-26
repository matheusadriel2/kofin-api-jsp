package br.com.kofin.controller;

import br.com.kofin.dao.UsersDao;
import br.com.kofin.dao.UserPasswordDao;
import br.com.kofin.exception.EntityNotFoundException;
import br.com.kofin.model.entities.Users;
import br.com.kofin.model.entities.UserPassword;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/login.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email       = request.getParameter("email");
        String rawPassword = request.getParameter("password");

        try (UsersDao usersDao = new UsersDao();
             UserPasswordDao pwdDao = new UserPasswordDao()) {

            Users user;
            try {
                user = usersDao.searchByEmail(email);
            } catch (EntityNotFoundException e) {
                request.setAttribute("error", "E-mail não cadastrado.");
                doGet(request, response);
                return;
            }

            UserPassword storedPwd;
            try {
                storedPwd = pwdDao.searchByUser(user);
            } catch (EntityNotFoundException e) {
                request.setAttribute("error", "Nenhuma senha cadastrada para este usuário.");
                doGet(request, response);
                return;
            }

            if (!rawPassword.equals(storedPwd.getPassword())) {
                request.setAttribute("error", "Senha incorreta.");
                doGet(request, response);
                return;
            }

            HttpSession session = request.getSession();
            session.setAttribute("userId", user.getId());

            request.getRequestDispatcher("/WEB-INF/views/loading.jsp")
                    .forward(request, response);

        } catch (SQLException e) {
            throw new ServletException("Erro ao conectar ao banco de dados", e);
        }
    }
}
