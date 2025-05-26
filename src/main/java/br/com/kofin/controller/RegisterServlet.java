package br.com.kofin.controller;

import br.com.kofin.auth.PasswordUtil;
import br.com.kofin.dao.UsersDao;
import br.com.kofin.dao.UserPasswordDao;
import br.com.kofin.exception.EntityNotFoundException;
import br.com.kofin.model.entities.Users;
import br.com.kofin.model.entities.UserPassword;
import br.com.kofin.model.enums.Verified;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String name     = req.getParameter("name");
        String email    = req.getParameter("email");
        String password = req.getParameter("password");

        try (UsersDao usersDao = new UsersDao();
             UserPasswordDao pwdDao = new UserPasswordDao()) {

            Users u = new Users();
            u.setFirstName(name);
            u.setLastName("");
            u.setEmail(email);
            u.setBalance(0.0);
            u.setIsVerified(Verified.NONVERIFIED);
            u.setIsActive(true);
            u.setCreationDate(LocalDateTime.now());
            u.setUpdateDate(LocalDateTime.now());
            usersDao.register(u);

            Users newUser = usersDao.searchByEmail(email);

            String hashed = PasswordUtil.hashPassword(password);

            UserPassword up = new UserPassword();
            up.setUser(newUser);
            up.setPassword(hashed);
            up.setCreationDate(LocalDateTime.now());
            up.setUpdateDate(null);
            pwdDao.register(up);

            resp.sendRedirect(req.getContextPath() + "/login?registered=true");
        }
        catch (EntityNotFoundException e) {
            throw new ServletException("Erro interno: usuário não encontrado.", e);
        }
        catch (SQLException e) {
            req.setAttribute("error", "Falha ao registrar: " + e.getMessage());
            doGet(req, resp);
        }
    }
}
