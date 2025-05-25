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

/**
 * DAO responsável pelas operações em T_TRANSACOES.
 * Observação: todas as consultas que retornam listas já vêm ordenadas pela data (mais recente primeiro).
 */
public class TransactionsDao implements AutoCloseable {
    private final Connection connection;

    public TransactionsDao() throws SQLException {
        this.connection = ConnectionFactory.getConnection();
    }

    /* ------------------------- CRUD ------------------------------------------------------- */

    public void register(Transactions t, int userId) throws SQLException {
        String sql = """
            INSERT INTO T_TRANSACOES
              (ID_TRANSACAO, T_USUARIOS_ID_USUARIO, T_CARTOES_ID_CARTAO, T_CONTAS_ID_CONTA,
               NM_TRANSACAO, CD_TRANSACAO, TIPO_TRANSACAO, VALOR, PGT_METODO,
               NR_TRANSFERENCIA, ESTA_AGENDADA, DT_TRANSACAO)
            VALUES (seq_id_transacao.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            if (t.getCardId()    != null) ps.setInt(2, t.getCardId());    else ps.setNull(2, Types.INTEGER);
            if (t.getAccountId() != null) ps.setInt(3, t.getAccountId()); else ps.setNull(3, Types.INTEGER);

            ps.setString(4, t.getPayMethod().name() + " transaction");
            ps.setString(5, "TRX" + System.currentTimeMillis());
            ps.setString(6, t.getType().name());
            ps.setDouble(7, t.getValue());
            ps.setString(8, t.getPayMethod().name());
            ps.setString(9, Boolean.TRUE.equals(t.getTransfer()) ? "S" : "N");
            ps.setString(10, t.getIsScheduled() == Scheduled.SCHEDULED ? "S" : "N");
            ps.setTimestamp(11,
                    Timestamp.valueOf(t.getTransactionDate() != null ? t.getTransactionDate() : LocalDateTime.now()));
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
            ps.setString(2, type.name());
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
              TIPO_TRANSACAO = ?, VALOR = ?, PGT_METODO = ?,
              NR_TRANSFERENCIA = ?, ESTA_AGENDADA = ?, DT_TRANSACAO = ?,
              T_CARTOES_ID_CARTAO = ?, T_CONTAS_ID_CONTA = ?
            WHERE ID_TRANSACAO = ?
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, t.getType().name());
            ps.setDouble(2, t.getValue());
            ps.setString(3, t.getPayMethod().name());
            ps.setString(4, Boolean.TRUE.equals(t.getTransfer()) ? "S" : "N");
            ps.setString(5, t.getIsScheduled() == Scheduled.SCHEDULED ? "S" : "N");
            ps.setTimestamp(6, Timestamp.valueOf(t.getTransactionDate()));
            if (t.getCardId()    != null) ps.setInt(7, t.getCardId());    else ps.setNull(7, Types.INTEGER);
            if (t.getAccountId() != null) ps.setInt(8, t.getAccountId()); else ps.setNull(8, Types.INTEGER);
            ps.setInt(9, t.getId());
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

    /* ==========  NOVOS MÉTODOS  ============================== */

    /** Lista TODAS as transações do usuário (mais recente primeiro). */
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

    /**
     * Soma o valor de todas as transações do usuário independentemente do tipo.
     * Entradas contam positivo, saídas/ investimentos negativo.
     */
    public double sumByUser(int userId) throws SQLException {
        String sql = """
        SELECT SUM(
                   CASE
                       WHEN TIPO_TRANSACAO = 'EXPENSE'    THEN -VALOR
                       WHEN TIPO_TRANSACAO = 'INVESTMENT' THEN -VALOR
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

    /**
     * Soma no intervalo (fechado) de data/hora.
     * @param from data inicial (inclusive)
     * @param to   data final   (inclusive)
     */
    public double sumByUserAndDateRange(int userId, LocalDate from, LocalDate to) throws SQLException {
        String sql = """
         SELECT SUM(
                    CASE
                        WHEN TIPO_TRANSACAO = 'EXPENSE'    THEN -VALOR
                        WHEN TIPO_TRANSACAO = 'INVESTMENT' THEN -VALOR
                        ELSE VALOR
                    END
                ) AS TOTAL
           FROM T_TRANSACOES
          WHERE T_USUARIOS_ID_USUARIO = ?
            AND TRUNC(DT_TRANSACAO) BETWEEN ? AND ?
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            ps.setDate  (2, Date.valueOf(String.valueOf(from)));
            ps.setDate  (3, Date.valueOf(String.valueOf(to)));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble("TOTAL") : 0.0;
            }
        }
    }

    public double sumByUserAndType(int userId, TransactionType type) throws SQLException {
        String sql = """
            SELECT COALESCE(SUM(
              CASE WHEN TIPO_TRANSACAO IN ('EXPENSE','INVESTMENT')
                   THEN -VALOR ELSE VALOR END),0) AS TOTAL
              FROM T_TRANSACOES
             WHERE T_USUARIOS_ID_USUARIO = ? AND TIPO_TRANSACAO = ?
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            ps.setString(2, type.name());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble("TOTAL") : 0.0;
            }
        }
    }

    /** Soma por tipo *e* intervalo de datas (inclusivo). */
    public double sumByUserTypeAndDate(int userId,
                                       TransactionType type,
                                       LocalDate from,
                                       LocalDate to) throws SQLException {
        String sql = """
            SELECT COALESCE(SUM(
              CASE WHEN TIPO_TRANSACAO IN ('EXPENSE','INVESTMENT')
                   THEN -VALOR ELSE VALOR END),0) AS TOTAL
              FROM T_TRANSACOES
             WHERE T_USUARIOS_ID_USUARIO = ?
               AND TIPO_TRANSACAO = ?
               AND TRUNC(DT_TRANSACAO) BETWEEN ? AND ?
            """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt   (1, userId);
            ps.setString(2, type.name());
            ps.setDate  (3, Date.valueOf(from));
            ps.setDate  (4, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getDouble("TOTAL") : 0.0;
            }
        }
    }

    public List<Transactions> listByUserAndCard(int userId, Integer cardId) throws SQLException{
        String sql = """
       SELECT * FROM T_TRANSACOES
        WHERE T_USUARIOS_ID_USUARIO = ?
          AND ( ? IS NULL OR T_CARTOES_ID_CARTAO = ? )
        ORDER BY DT_TRANSACAO DESC
   """;
        try(PreparedStatement ps = connection.prepareStatement(sql)){
            ps.setInt(1,userId);
            if(cardId==null){ ps.setNull(2,Types.INTEGER); ps.setNull(3,Types.INTEGER);}
            else            { ps.setInt (2,cardId);       ps.setInt (3,cardId);}
            try(ResultSet rs = ps.executeQuery()){
                List<Transactions> l = new ArrayList<>();
                while(rs.next()) l.add(mapRow(rs));
                return l;
            }
        }
    }

    public double sumByUserTypeAndCard(int userId,TransactionType tp,Integer cardId) throws SQLException{
        String sql = """
      SELECT COALESCE(SUM(
        CASE WHEN TIPO_TRANSACAO IN ('EXPENSE','INVESTMENT')
             THEN -VALOR ELSE VALOR END),0) AS TOTAL
        FROM T_TRANSACOES
       WHERE T_USUARIOS_ID_USUARIO = ?
         AND TIPO_TRANSACAO = ?
         AND ( ? IS NULL OR T_CARTOES_ID_CARTAO = ? )
   """;
        try (PreparedStatement ps = connection.prepareStatement(sql)){
            ps.setInt(1,userId); ps.setString(2,tp.name());
            if(cardId==null){ ps.setNull(3,Types.INTEGER); ps.setNull(4,Types.INTEGER);}
            else            { ps.setInt (3,cardId);       ps.setInt (4,cardId);}
            try(ResultSet rs = ps.executeQuery()){
                return rs.next()? rs.getDouble("TOTAL"):0;
            }
        }
    }



    /* ---------------------- helpers ------------------------------------------------------- */

    private Transactions mapRow(ResultSet rs) throws SQLException {
        Transactions t = new Transactions();
        t.setId(rs.getInt("ID_TRANSACAO"));
        t.setType(TransactionType.valueOf(rs.getString("TIPO_TRANSACAO")));
        t.setValue(rs.getDouble("VALOR"));
        t.setPayMethod(PaymentMethod.valueOf(rs.getString("PGT_METODO")));
        t.setTransfer("S".equals(rs.getString("NR_TRANSFERENCIA")));
        t.setIsScheduled("S".equals(rs.getString("ESTA_AGENDADA"))
                ? Scheduled.SCHEDULED : Scheduled.NONSCHEDULED);
        t.setTransactionDate(rs.getTimestamp("DT_TRANSACAO").toLocalDateTime());
        t.setCardId(rs.getInt("T_CARTOES_ID_CARTAO") == 0 ? null : rs.getInt("T_CARTOES_ID_CARTAO"));
        t.setAccountId(rs.getInt("T_CONTAS_ID_CONTA") == 0 ? null : rs.getInt("T_CONTAS_ID_CONTA"));
        return t;
    }

    @Override
    public void close() throws SQLException { connection.close(); }
}
