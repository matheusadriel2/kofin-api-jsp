package br.com.kofin.dao;

import br.com.kofin.exception.EntityNotFoundException;
import br.com.kofin.factory.ConnectionFactory;
import br.com.kofin.model.entities.Cards;
import br.com.kofin.model.enums.CardFlag;
import br.com.kofin.model.enums.CardType;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class CardsDao implements AutoCloseable {

    private final Connection connection;

    public CardsDao() throws SQLException {
        connection = ConnectionFactory.getConnection();
    }

    public void register(Cards c, int userId) throws SQLException {
        String sql = """
          INSERT INTO T_CARTOES
           (ID_CARTAO, T_USUARIOS_ID_USUARIO, NM_CARTAO, NR_ULTIMOS4,
            TIPO_CARTAO, VALIDADE, BANDEIRA, DT_CRIACAO)
          VALUES (seq_id_cartao.NEXTVAL, ?, ?, ?, ?, ?, ?, SYSTIMESTAMP)
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            ps.setString(2, c.getName());
            ps.setString(3, c.getLast4());
            ps.setString(4, c.getType().name());
            ps.setDate  (5, Date.valueOf(c.getValidity()));

            if (c.getFlag() == null)
                ps.setNull(6, Types.VARCHAR);
            else
                ps.setString(6, c.getFlag().name());

            ps.executeUpdate();
        }
    }

    public Cards search(int id) throws SQLException, EntityNotFoundException {
        try (PreparedStatement ps =
                     connection.prepareStatement("SELECT * FROM T_CARTOES WHERE ID_CARTAO=?")) {
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
            NM_CARTAO = ?, NR_ULTIMOS4 = ?, TIPO_CARTAO = ?,
            VALIDADE = ?, BANDEIRA = ?, DT_ATUALIZACAO = SYSTIMESTAMP
          WHERE ID_CARTAO = ?
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, c.getName());
            ps.setString(2, c.getLast4());
            ps.setString(3, c.getType().name());
            ps.setDate  (4, Date.valueOf(c.getValidity()));

            if (c.getFlag() == null)
                ps.setNull(5, Types.VARCHAR);
            else
                ps.setString(5, c.getFlag().name());

            ps.setInt(6, c.getId());
            ps.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        try (PreparedStatement ps =
                     connection.prepareStatement("DELETE FROM T_CARTOES WHERE ID_CARTAO=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    private Cards mapRow(ResultSet rs) throws SQLException {
        Cards c = new Cards();
        c.setId      (rs.getInt("ID_CARTAO"));
        c.setName    (rs.getString("NM_CARTAO"));
        c.setLast4   (rs.getString("NR_ULTIMOS4"));
        c.setType    (CardType.valueOf(rs.getString("TIPO_CARTAO")));
        c.setValidity(rs.getDate("VALIDADE").toLocalDate());

        String band = rs.getString("BANDEIRA");
        if (band != null)
            c.setFlag(CardFlag.valueOf(band));    // guarda enum
        else
            c.setFlag(null);

        Timestamp ts = rs.getTimestamp("DT_CRIACAO");
        if (ts != null) c.setCreationDate(ts.toLocalDateTime().toLocalDate());

        ts = rs.getTimestamp("DT_ATUALIZACAO");
        if (ts != null) c.setUpdateDate(ts.toLocalDateTime().toLocalDate());

        return c;
    }

    @Override public void close() throws SQLException { connection.close(); }
}
