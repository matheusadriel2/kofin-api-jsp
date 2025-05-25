package br.com.kofin.dao;

import br.com.kofin.exception.EntityNotFoundException;
import br.com.kofin.factory.ConnectionFactory;
import br.com.kofin.model.entities.UserDetails;
import br.com.kofin.model.entities.Users;

import java.sql.*;
import java.time.LocalDateTime;

public class UserDetailsDao {
    private final Connection connection;

    public UserDetailsDao() throws SQLException {
        this.connection = ConnectionFactory.getConnection();
    }

    public void register(UserDetails details) throws SQLException {
        String sql = "INSERT INTO T_USUARIO_DETALHES " +
                "(ID_DETALHES, T_USUARIOS_ID_USUARIO, CPF, DT_NASCIMENTO, GENERO, DT_CRIACAO, DT_ATUALIZACAO) " +
                "VALUES (seq_id_userdetalhes.NEXTVAL, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt  (1, details.getUser().getId());
            ps.setString(2, details.getCpf());
            ps.setDate (3, Date.valueOf(details.getBirthDate()));
            ps.setString(4, details.getGender());
            ps.setTimestamp(5, Timestamp.valueOf(details.getCreationDate() != null
                    ? details.getCreationDate() : LocalDateTime.now()));
            ps.setTimestamp(6, details.getUpdateDate() != null
                    ? Timestamp.valueOf(details.getUpdateDate()) : null);
            ps.executeUpdate();
        }
    }

    public UserDetails searchByUser(Users user) throws SQLException, EntityNotFoundException {
        String sql = "SELECT * FROM T_USUARIO_DETALHES WHERE T_USUARIOS_ID_USUARIO = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, user.getId());
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new EntityNotFoundException("Detalhes do usuário não encontrados.");
                }
                UserDetails d = new UserDetails();
                d.setId(rs.getInt("ID_DETALHES"));
                d.setUser(user);
                d.setCpf(rs.getString("CPF"));
                d.setBirthDate(rs.getDate("DT_NASCIMENTO").toLocalDate());
                d.setGender(rs.getString("GENERO"));
                d.setCreationDate(rs.getTimestamp("DT_CRIACAO").toLocalDateTime());
                Timestamp upd = rs.getTimestamp("DT_ATUALIZACAO");
                if (upd != null) d.setUpdateDate(upd.toLocalDateTime());
                return d;
            }
        }
    }

    public void update(UserDetails details) throws SQLException {
        String sql = "UPDATE T_USUARIO_DETALHES SET CPF = ?, DT_NASCIMENTO = ?, GENERO = ?, DT_ATUALIZACAO = ? " +
                "WHERE T_USUARIOS_ID_USUARIO = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, details.getCpf());
            ps.setDate  (2, Date.valueOf(details.getBirthDate()));
            ps.setString(3, details.getGender());
            ps.setTimestamp(4, Timestamp.valueOf(LocalDateTime.now()));
            ps.setInt   (5, details.getUser().getId());
            ps.executeUpdate();
        }
    }

    public void close() throws SQLException {
        connection.close();
    }
}