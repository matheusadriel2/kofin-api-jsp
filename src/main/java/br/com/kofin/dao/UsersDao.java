package br.com.kofin.dao;

import br.com.kofin.exception.EntityNotFoundException;
import br.com.kofin.factory.ConnectionFactory;
import br.com.kofin.model.entities.Users;
import br.com.kofin.model.enums.Verified;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UsersDao implements AutoCloseable {
    private Connection connection;

    public UsersDao() throws SQLException {
        connection = ConnectionFactory.getConnection();
    }

    public void register(Users user) throws SQLException {
        String sql = "INSERT INTO T_USUARIOS (ID_USUARIO, NOME, SOBRENOME, EMAIL, SALDO, ESTA_VERIFICADO, ESTA_ATIVO, DT_CRIACAO, DT_ATUALIZACAO) " +
                "VALUES (seq_id_user.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setString(1, user.getFirstName());
        stm.setString(2, user.getLastName());
        stm.setString(3, user.getEmail());
        stm.setDouble(4, user.getBalance() != null ? user.getBalance() : 0.0);
        stm.setString(5, user.getIsVerified() == Verified.VERIFIED ? "S" : "N");
        stm.setString(6, user.getIsActive() != null && user.getIsActive() ? "S" : "N");
        stm.setObject(7, user.getCreationDate() != null ? user.getCreationDate() : java.time.LocalDateTime.now());
        stm.setObject(8, user.getUpdateDate());
        stm.executeUpdate();
    }

    public Users search(Integer id) throws SQLException, EntityNotFoundException {
        String sql = "SELECT * FROM T_USUARIOS WHERE ID_USUARIO = ?";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setInt(1, id);
        ResultSet result = stm.executeQuery();

        if (!result.next())
            throw new EntityNotFoundException("Usuário não encontrado.");

        Users user = new Users();
        user.setId(result.getInt("ID_USUARIO"));
        user.setFirstName(result.getString("NOME"));
        user.setLastName(result.getString("SOBRENOME"));
        user.setEmail(result.getString("EMAIL"));
        user.setBalance(result.getDouble("SALDO"));
        user.setIsVerified("S".equals(result.getString("ESTA_VERIFICADO")) ? Verified.VERIFIED : Verified.NONVERIFIED);
        user.setIsActive("S".equals(result.getString("ESTA_ATIVO")));
        user.setCreationDate(result.getTimestamp("DT_CRIACAO").toLocalDateTime());
        if (result.getTimestamp("DT_ATUALIZACAO") != null)
            user.setUpdateDate(result.getTimestamp("DT_ATUALIZACAO").toLocalDateTime());

        return user;
    }


    public List<Users> getAll() throws SQLException {
        String sql = "SELECT * FROM T_USUARIOS";
        PreparedStatement stm = connection.prepareStatement(sql);
        ResultSet result = stm.executeQuery();

        List<Users> users = new ArrayList<>();

        while (result.next()) {
            Users user = new Users();
            user.setId(result.getInt("ID_USUARIO"));
            user.setFirstName(result.getString("NOME"));
            user.setLastName(result.getString("SOBRENOME"));
            user.setEmail(result.getString("EMAIL"));
            user.setBalance(result.getDouble("SALDO"));
            user.setIsVerified("S".equals(result.getString("ESTA_VERIFICADO")) ? Verified.VERIFIED : Verified.NONVERIFIED);
            user.setIsActive("S".equals(result.getString("ESTA_ATIVO")));
            user.setCreationDate(result.getTimestamp("DT_CRIACAO").toLocalDateTime());

            if (result.getTimestamp("DT_ATUALIZACAO") != null) {
                user.setUpdateDate(result.getTimestamp("DT_ATUALIZACAO").toLocalDateTime());
            }

            users.add(user);
        }

        return users;
    }


    public void update(Users user) throws SQLException {
        String sql = "UPDATE T_USUARIOS SET NOME = ?, SOBRENOME = ?, EMAIL = ?, SALDO = ?, ESTA_VERIFICADO = ?, ESTA_ATIVO = ?, DT_ATUALIZACAO = ? WHERE ID_USUARIO = ?";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setString(1, user.getFirstName());
        stm.setString(2, user.getLastName());
        stm.setString(3, user.getEmail());
        stm.setDouble(4, user.getBalance() != null ? user.getBalance() : 0.0);
        stm.setString(5, user.getIsVerified() == Verified.VERIFIED ? "S" : "N");
        stm.setString(6, user.getIsActive() != null && user.getIsActive() ? "S" : "N");
        stm.setObject(7, java.time.LocalDateTime.now());
        stm.setInt(8, user.getId());
        stm.executeUpdate();
    }


    public void delete(Integer id) throws SQLException {
        String sql = "DELETE FROM T_USUARIOS WHERE ID_USUARIO = ?";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setInt(1, id);
        stm.executeUpdate();
    }

    public Users searchByEmail(String email) throws SQLException, EntityNotFoundException {  // CHANGED: método adicionado
        String sql = "SELECT * FROM T_USUARIOS WHERE EMAIL = ?";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setString(1, email);
        ResultSet rs = stm.executeQuery();
        if (!rs.next()) {
            throw new EntityNotFoundException("Usuário não encontrado.");
        }
        Users user = new Users();
        user.setId(rs.getInt("ID_USUARIO"));
        user.setFirstName(rs.getString("NOME"));
        user.setLastName(rs.getString("SOBRENOME"));
        user.setEmail(rs.getString("EMAIL"));
        user.setBalance(rs.getDouble("SALDO"));
        user.setIsVerified("S".equals(rs.getString("ESTA_VERIFICADO"))
                ? Verified.VERIFIED : Verified.NONVERIFIED);
        user.setIsActive("S".equals(rs.getString("ESTA_ATIVO")));
        user.setCreationDate(rs.getTimestamp("DT_CRIACAO").toLocalDateTime());
        Timestamp upd = rs.getTimestamp("DT_ATUALIZACAO");
        if (upd != null) user.setUpdateDate(upd.toLocalDateTime());
        return user;
    }

    public void close() throws SQLException {
        connection.close();
    }
}
