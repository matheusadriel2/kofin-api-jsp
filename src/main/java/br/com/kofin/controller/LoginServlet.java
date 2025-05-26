package br.com.kofin.controller;

import br.com.kofin.auth.JwtUtil;
import br.com.kofin.auth.PasswordUtil;
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email       = request.getParameter("email");
        String rawPassword = request.getParameter("password");

        try (UsersDao usersDao = new UsersDao();
             UserPasswordDao pwdDao = new UserPasswordDao()) {

            Users user = usersDao.searchByEmail(email);
            UserPassword storedPwd = pwdDao.searchByUser(user);

            if (!PasswordUtil.verifyPassword(rawPassword, storedPwd.getPassword())) {
                request.setAttribute("error", "Senha incorreta.");
                doGet(request, response);
                return;
            }

            String token = JwtUtil.generateToken(user.getId());
            Cookie jwtCookie = new Cookie("token", token);
            jwtCookie.setHttpOnly(true);
            jwtCookie.setPath(request.getContextPath());
            response.addCookie(jwtCookie);

            request.getRequestDispatcher("/WEB-INF/views/loading.jsp")
                    .forward(request, response);

        } catch (EntityNotFoundException e) {
            request.setAttribute("error", "Credenciais inválidas.");
            doGet(request, response);
        } catch (SQLException e) {
            throw new ServletException("Erro ao conectar ao banco de dados", e);
        }
    }
}
