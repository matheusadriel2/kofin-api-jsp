package br.com.kofin.dao;

import br.com.kofin.exception.EntityNotFoundException;
import br.com.kofin.factory.ConnectionFactory;
import br.com.kofin.model.entities.UserPassword;
import br.com.kofin.model.entities.Users;

import java.sql.*;
import java.time.LocalDateTime;

public class UserPasswordDao implements AutoCloseable {
    private final Connection connection;

    public UserPasswordDao() throws SQLException {
        this.connection = ConnectionFactory.getConnection();
    }

    public void register(UserPassword pwd) throws SQLException {
        String sql = "INSERT INTO T_USUARIO_SENHAS " +
                "(ID_SENHAS, T_USUARIOS_ID_USUARIO, SENHA, DT_CRIACAO, DT_ATUALIZACAO) " +
                "VALUES (seq_id_usersenha.NEXTVAL, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt  (1, pwd.getUser().getId());
            ps.setString(2, pwd.getPassword());
            ps.setTimestamp(3, Timestamp.valueOf(pwd.getCreationDate() != null
                    ? pwd.getCreationDate() : LocalDateTime.now()));
            ps.setTimestamp(4, pwd.getUpdateDate() != null
                    ? Timestamp.valueOf(pwd.getUpdateDate()) : null);
            ps.executeUpdate();
        }
    }

    public UserPassword searchByUser(Users user)
            throws SQLException, EntityNotFoundException {
        String sql = "SELECT * FROM T_USUARIO_SENHAS WHERE T_USUARIOS_ID_USUARIO = ?";
        PreparedStatement ps = connection.prepareStatement(sql);
        ps.setInt(1, user.getId());
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) {
            throw new EntityNotFoundException("Senha não encontrada.");
        }
        UserPassword up = new UserPassword();
        up.setId(rs.getInt("ID_SENHAS"));
        up.setUser(user);                                      // CHANGED: usa get/set de Users
        up.setPassword(rs.getString("SENHA"));
        up.setCreationDate(rs.getTimestamp("DT_CRIACAO").toLocalDateTime());
        Timestamp upd = rs.getTimestamp("DT_ATUALIZACAO");
        if (upd != null) up.setUpdateDate(upd.toLocalDateTime());
        return up;
    }

    public void update(UserPassword pwd) throws SQLException {
        String sql = "UPDATE T_USUARIO_SENHAS SET SENHA = ?, DT_ATUALIZACAO = ? " +
                "WHERE T_USUARIOS_ID_USUARIO = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, pwd.getPassword());
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt   (3, pwd.getUser().getId());
            ps.executeUpdate();
        }
    }

    @Override
    public void close() throws SQLException {
        connection.close();
    }
}
