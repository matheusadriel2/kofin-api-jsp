package br.com.kofin.dao;

import br.com.kofin.exception.EntityNotFoundException;
import br.com.kofin.factory.ConnectionFactory;
import br.com.kofin.model.entities.Cards;
import br.com.kofin.model.enums.CardType;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO de Cartões.
 * Todas as listagens retornam cartões ordenados pelo dt_criacao DESC.
 */
public class CardsDao implements AutoCloseable {

    private final Connection connection;

    public CardsDao() throws SQLException {
        this.connection = ConnectionFactory.getConnection();
    }

    /* -------------------- CRUD ----------------------------------------- */

    public void register(Cards c, int userId) throws SQLException {
        String sql = """
            INSERT INTO T_CARTOES
              (ID_CARTAO, T_USUARIOS_ID_USUARIO, TIPO_CARTAO, NR_CARTAO,
               VALIDADE, BANDEIRA, DT_CRIACAO, DT_ATUALIZACAO)
            VALUES (seq_id_cartao.NEXTVAL, ?, ?, ?, ?, ?, ?, ?)
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            ps.setString(2, c.getType().name());
            ps.setInt   (3, c.getNumber());
            ps.setDate  (4, Date.valueOf(c.getValidity()));
            ps.setString(5, c.getFlag());
            ps.setDate  (6, Date.valueOf(c.getCreationDate() != null
                    ? c.getCreationDate() : LocalDate.now()));
            ps.setDate  (7, c.getUpdateDate() != null ? Date.valueOf(c.getUpdateDate()) : null);
            ps.executeUpdate();
        }
    }

    public Cards search(int id) throws SQLException, EntityNotFoundException {
        String sql = "SELECT * FROM T_CARTOES WHERE ID_CARTAO = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new EntityNotFoundException("Cartão não encontrado.");
                return mapRow(rs);
            }
        }
    }

    public List<Cards> listByUser(int userId) throws SQLException {
        String sql = """
            SELECT * FROM T_CARTOES
             WHERE T_USUARIOS_ID_USUARIO = ?
             ORDER BY DT_CRIACAO DESC
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                List<Cards> list = new ArrayList<>();
                while (rs.next()) list.add(mapRow(rs));
                return list;
            }
        }
    }

    public void update(Cards c) throws SQLException {
        String sql = """
            UPDATE T_CARTOES SET
              TIPO_CARTAO = ?, NR_CARTAO = ?, VALIDADE = ?,
              BANDEIRA = ?, DT_ATUALIZACAO = ?
            WHERE ID_CARTAO = ?
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, c.getType().name());
            ps.setInt   (2, c.getNumber());
            ps.setDate  (3, Date.valueOf(c.getValidity()));
            ps.setString(4, c.getFlag());
            ps.setDate  (5, Date.valueOf(LocalDate.now()));
            ps.setInt   (6, c.getId());
            ps.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        try (PreparedStatement ps =
                     connection.prepareStatement("DELETE FROM T_CARTOES WHERE ID_CARTAO = ?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    /* ------------------- helper --------------------------------------- */
    private Cards mapRow(ResultSet rs) throws SQLException {
        Cards c = new Cards();
        c.setId        (rs.getInt("ID_CARTAO"));
        c.setType      (CardType.valueOf(rs.getString("TIPO_CARTAO")));
        c.setNumber    (rs.getInt("NR_CARTAO"));
        c.setValidity  (rs.getDate("VALIDADE").toLocalDate());
        c.setFlag      (rs.getString("BANDEIRA"));
        c.setCreationDate(rs.getDate("DT_CRIACAO").toLocalDate());
        Date upd = rs.getDate("DT_ATUALIZACAO");
        if (upd != null) c.setUpdateDate(upd.toLocalDate());
        return c;
    }

    @Override
    public void close() throws SQLException { connection.close(); }
}
