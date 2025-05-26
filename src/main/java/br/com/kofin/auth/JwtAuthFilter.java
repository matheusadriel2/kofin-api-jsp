package br.com.kofin.auth;

import io.jsonwebtoken.JwtException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebFilter(urlPatterns = {
        "/dashboard",
        "/user",
        "/cards",
        "/cards/*",
        "/card",
        "/card/*",
        "/transactions",
        "/transaction/*"
})
public class JwtAuthFilter implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest  request  = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String token = null;
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            token = authHeader.substring(7);
        } else if (request.getCookies() != null) {
            for (Cookie c : request.getCookies()) {
                if ("token".equals(c.getName())) {
                    token = c.getValue();
                    break;
                }
            }
        }

        if (token != null) {
            try {
                int userId = JwtUtil.getUserIdFromToken(token);
                request.setAttribute("userId", userId);
                chain.doFilter(request, response);
                return;
            } catch (JwtException e) {
                request.setAttribute("error", "Token inválido ou expirado.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/login");
    }
}
