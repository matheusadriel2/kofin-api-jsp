package br.com.kofin.dao;

import br.com.kofin.exception.EntityNotFoundException;
import br.com.kofin.factory.ConnectionFactory;
import br.com.kofin.model.entities.Transactions;
import br.com.kofin.model.enums.PaymentMethod;
import br.com.kofin.model.enums.Scheduled;
import br.com.kofin.model.enums.TransactionType;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class TransactionsDao implements AutoCloseable {
    private final Connection connection;

    public TransactionsDao() throws SQLException {
        this.connection = ConnectionFactory.getConnection();
    }

    public void register(Transactions t, int userId) throws SQLException {
        String sql = """
            INSERT INTO T_TRANSACOES
              (ID_TRANSACAO, T_USUARIOS_ID_USUARIO, T_CARTOES_ID_CARTAO, T_CONTAS_ID_CONTA,
               NM_TRANSACAO, CATEGORIA, CD_TRANSACAO, TIPO_TRANSACAO, VALOR, PGT_METODO,
               NR_TRANSFERENCIA, ESTA_AGENDADA, DT_TRANSACAO)
            VALUES (seq_id_transacao.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            if (t.getCardId()    != null) ps.setInt   (2, t.getCardId());    else ps.setNull(2, Types.INTEGER);
            if (t.getAccountId() != null) ps.setInt   (3, t.getAccountId()); else ps.setNull(3, Types.INTEGER);

            ps.setString(4,  t.getName());
            ps.setString(5,  t.getCategory());
            ps.setString(6,  "TRX"+System.currentTimeMillis());
            ps.setString(7,  String.valueOf(t.getType().getCode()));
            ps.setDouble(8,  t.getValue());
            ps.setString(9,  t.getPayMethod().name());
            ps.setString(10, Boolean.TRUE.equals(t.getTransfer()) ? "S" : "N");
            ps.setString(11, t.getIsScheduled() == Scheduled.SCHEDULED ? "S" : "N");
            ps.setTimestamp(12,
                    Timestamp.valueOf(t.getTransactionDate() != null
                            ? t.getTransactionDate()
                            : LocalDateTime.now()));
            ps.executeUpdate();
        }
    }

    public Transactions search(int id) throws SQLException, EntityNotFoundException {
        String sql = "SELECT * FROM T_TRANSACOES WHERE ID_TRANSACAO = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new EntityNotFoundException("Transação não encontrada.");
                return mapRow(rs);
            }
        }
    }

    public List<Transactions> listByUserAndType(int userId, TransactionType type) throws SQLException {
        String sql = """
            SELECT * FROM T_TRANSACOES
             WHERE T_USUARIOS_ID_USUARIO = ? AND TIPO_TRANSACAO = ?
             ORDER BY DT_TRANSACAO DESC
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            // aqui também usamos o code
            ps.setString(2, String.valueOf(type.getCode()));
            try (ResultSet rs = ps.executeQuery()) {
                List<Transactions> list = new ArrayList<>();
                while (rs.next()) list.add(mapRow(rs));
                return list;
            }
        }
    }

    public void update(Transactions t) throws SQLException {
        String sql = """
            UPDATE T_TRANSACOES SET
              NM_TRANSACAO        = ?, 
              CATEGORIA           = ?, 
              TIPO_TRANSACAO      = ?, 
              VALOR               = ?, 
              PGT_METODO          = ?,
              NR_TRANSFERENCIA    = ?, 
              ESTA_AGENDADA       = ?, 
              DT_TRANSACAO        = ?,
              T_CARTOES_ID_CARTAO = ?, 
              T_CONTAS_ID_CONTA   = ?
            WHERE ID_TRANSACAO = ?
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString (1, t.getName());
            ps.setString (2, t.getCategory());
            ps.setString (3, String.valueOf(t.getType().getCode()));
            ps.setDouble (4, t.getValue());
            ps.setString (5, t.getPayMethod().name());
            ps.setString (6, Boolean.TRUE.equals(t.getTransfer()) ? "S" : "N");
            ps.setString (7, t.getIsScheduled() == Scheduled.SCHEDULED ? "S" : "N");
            ps.setTimestamp(8, Timestamp.valueOf(t.getTransactionDate()));
            if (t.getCardId()    != null) ps.setInt   (9, t.getCardId());    else ps.setNull(9, Types.INTEGER);
            if (t.getAccountId() != null) ps.setInt   (10, t.getAccountId()); else ps.setNull(10, Types.INTEGER);
            ps.setInt    (11, t.getId());
            ps.executeUpdate();
        }
    }

    public void delete(int id) throws SQLException {
        try (PreparedStatement ps =
                     connection.prepareStatement("DELETE FROM T_TRANSACOES WHERE ID_TRANSACAO = ?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    public List<Transactions> listByUser(int userId) throws SQLException {
        String sql = """
            SELECT * FROM T_TRANSACOES
             WHERE T_USUARIOS_ID_USUARIO = ?
             ORDER BY DT_TRANSACAO DESC
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                List<Transactions> list = new ArrayList<>();
                while (rs.next()) list.add(mapRow(rs));
                return list;
            }
        }
    }

    public double sumByUser(int userId) throws SQLException {
        String sql = """
            SELECT SUM(
                   CASE
                     WHEN TIPO_TRANSACAO = 'D' THEN -VALOR
                     WHEN TIPO_TRANSACAO = 'I' THEN -VALOR
                     ELSE VALOR
                   END
                 ) AS TOTAL
              FROM T_TRANSACOES
             WHERE T_USUARIOS_ID_USUARIO = ?
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble("TOTAL") : 0.0;
            }
        }
    }

    public double sumByUserAndDateRange(int userId, LocalDate from, LocalDate to) throws SQLException {
        String sql = """
            SELECT SUM(
                   CASE
                     WHEN TIPO_TRANSACAO = 'D' THEN -VALOR
                     WHEN TIPO_TRANSACAO = 'I' THEN -VALOR
                     ELSE VALOR
                   END
                 ) AS TOTAL
              FROM T_TRANSACOES
             WHERE T_USUARIOS_ID_USUARIO = ?
               AND TRUNC(DT_TRANSACAO) BETWEEN ? AND ?
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt  (1, userId);
            ps.setDate (2, Date.valueOf(from));
            ps.setDate (3, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble("TOTAL") : 0.0;
            }
        }
    }

    public double sumByUserAndType(int userId, TransactionType type) throws SQLException {
        String sql = """
            SELECT COALESCE(SUM(
                   CASE
                     WHEN TIPO_TRANSACAO IN ('D','I') THEN -VALOR
                     ELSE VALOR
                   END
                 ),0) AS TOTAL
              FROM T_TRANSACOES
             WHERE T_USUARIOS_ID_USUARIO = ?
               AND TIPO_TRANSACAO = ?
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            ps.setString(2, String.valueOf(type.getCode()));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble("TOTAL") : 0.0;
            }
        }
    }

    public double sumByUserTypeAndDate(int userId, TransactionType type, LocalDate from, LocalDate to) throws SQLException {
        String sql = """
            SELECT COALESCE(SUM(
                   CASE
                     WHEN TIPO_TRANSACAO IN ('D','I') THEN -VALOR
                     ELSE VALOR
                   END
                 ),0) AS TOTAL
              FROM T_TRANSACOES
             WHERE T_USUARIOS_ID_USUARIO = ?
               AND TIPO_TRANSACAO = ?
               AND TRUNC(DT_TRANSACAO) BETWEEN ? AND ?
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt  (1, userId);
            ps.setString(2, String.valueOf(type.getCode()));
            ps.setDate (3, Date.valueOf(from));
            ps.setDate (4, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble("TOTAL") : 0.0;
            }
        }
    }

    public List<Transactions> listByUserAndCard(int userId, Integer cardId) throws SQLException {
        String sql = """
            SELECT * FROM T_TRANSACOES
             WHERE T_USUARIOS_ID_USUARIO = ?
               AND ( ? IS NULL OR T_CARTOES_ID_CARTAO = ? )
             ORDER BY DT_TRANSACAO DESC
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            if (cardId == null) {
                ps.setNull (2, Types.INTEGER);
                ps.setNull (3, Types.INTEGER);
            } else {
                ps.setInt  (2, cardId);
                ps.setInt  (3, cardId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<Transactions> list = new ArrayList<>();
                while (rs.next()) list.add(mapRow(rs));
                return list;
            }
        }
    }

    public double sumByUserTypeAndCard(int userId, TransactionType type, Integer cardId) throws SQLException {
        String sql = """
            SELECT COALESCE(SUM(
                   CASE
                     WHEN TIPO_TRANSACAO IN ('D','I') THEN -VALOR
                     ELSE VALOR
                   END
                 ),0) AS TOTAL
              FROM T_TRANSACOES
             WHERE T_USUARIOS_ID_USUARIO = ?
               AND TIPO_TRANSACAO = ?
               AND ( ? IS NULL OR T_CARTOES_ID_CARTAO = ? )
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            ps.setString(2, String.valueOf(type.getCode()));
            if (cardId == null) {
                ps.setNull (3, Types.INTEGER);
                ps.setNull (4, Types.INTEGER);
            } else {
                ps.setInt  (3, cardId);
                ps.setInt  (4, cardId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble("TOTAL") : 0.0;
            }
        }
    }

    private Transactions mapRow(ResultSet rs) throws SQLException {
        Transactions t = new Transactions();
        t.setId              (rs.getInt("ID_TRANSACAO"));
        t.setName            (rs.getString("NM_TRANSACAO"));
        t.setCategory        (rs.getString("CATEGORIA"));
        t.setType            (TransactionType.fromCode(rs.getString("TIPO_TRANSACAO").charAt(0)));
        t.setValue           (rs.getDouble("VALOR"));
        t.setPayMethod       (PaymentMethod.valueOf(rs.getString("PGT_METODO")));
        t.setTransfer        ("S".equals(rs.getString("NR_TRANSFERENCIA")));
        t.setIsScheduled     ("S".equals(rs.getString("ESTA_AGENDADA"))
                ? Scheduled.SCHEDULED
                : Scheduled.NONSCHEDULED);
        t.setTransactionDate (rs.getTimestamp("DT_TRANSACAO").toLocalDateTime());
        int cid = rs.getInt("T_CARTOES_ID_CARTAO");
        t.setCardId          (cid == 0 ? null : cid);
        int aid = rs.getInt("T_CONTAS_ID_CONTA");
        t.setAccountId       (aid == 0 ? null : aid);
        return t;
    }

    @Override
    public void close() throws SQLException {
        connection.close();
    }
}
