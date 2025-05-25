package br.com.kofin.dao;

import br.com.kofin.exception.EntityNotFoundException;
import br.com.kofin.factory.ConnectionFactory;
import br.com.kofin.model.entities.Transactions;
import br.com.kofin.model.enums.PaymentMethod;
import br.com.kofin.model.enums.Scheduled;
import br.com.kofin.model.enums.TransactionType;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class TransactionsDao {
    private Connection connection;

    public TransactionsDao() throws SQLException {
        connection = ConnectionFactory.getConnection();
    }

    public void register(Transactions t, int userId, Integer cardId, Integer accountId) throws SQLException {
        String sql = "INSERT INTO T_TRANSACOES (ID_TRANSACAO, T_USUARIOS_ID_USUARIO, T_CARTOES_ID_CARTAO, T_CONTAS_ID_CONTA, NM_TRANSACAO, CD_TRANSACAO, TIPO_TRANSACAO, VALOR, PGT_METODO, NR_TRANSFERENCIA, ESTA_AGENDADA, DT_TRANSACAO) " +
                "VALUES (seq_id_transacao.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setInt(1, userId);
        if (cardId != null) stm.setInt(2, cardId); else stm.setNull(2, Types.INTEGER);
        if (accountId != null) stm.setInt(3, accountId); else stm.setNull(3, Types.INTEGER);
        stm.setString(4, "Transação de " + t.getPayMethod());
        stm.setString(5, "TRX" + System.currentTimeMillis());
        stm.setString(6, t.getType().name());
        stm.setDouble(7, t.getValue());
        stm.setString(8, t.getPayMethod().name());
        stm.setString(9, t.getTransfer() != null && t.getTransfer() ? "S" : "N");
        stm.setString(10, t.getIsScheduled() == Scheduled.SCHEDULED ? "S" : "N");
        stm.setObject(11, t.getTransactionDate() != null ? t.getTransactionDate() : LocalDateTime.now());
        stm.executeUpdate();
    }

    public Transactions search(Integer id) throws SQLException, EntityNotFoundException {
        String sql = "SELECT * FROM T_TRANSACOES WHERE ID_TRANSACAO = ?";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setInt(1, id);
        ResultSet rs = stm.executeQuery();

        if (!rs.next())
            throw new EntityNotFoundException("Transação não encontrada.");

        Transactions t = new Transactions();
        t.setId(rs.getInt("ID_TRANSACAO"));
        t.setType(TransactionType.valueOf(rs.getString("TIPO_TRANSACAO")));
        t.setValue(rs.getDouble("VALOR"));
        t.setPayMethod(PaymentMethod.valueOf(rs.getString("PGT_METODO")));
        t.setTransfer("S".equals(rs.getString("NR_TRANSFERENCIA")));
        t.setIsScheduled("S".equals(rs.getString("ESTA_AGENDADA")) ? Scheduled.SCHEDULED : Scheduled.NONSCHEDULED);
        t.setTransactionDate(rs.getTimestamp("DT_TRANSACAO").toLocalDateTime());

        return t;
    }


    public List<Transactions> getAllByUserAndType(int userId, TransactionType type) throws SQLException {
        String sql = "SELECT * FROM T_TRANSACOES WHERE T_USUARIOS_ID_USUARIO = ? AND TIPO_TRANSACAO = ?";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, userId);
            stm.setString(2, type.name());
            try (ResultSet rs = stm.executeQuery()) {
                List<Transactions> list = new ArrayList<>();
                while (rs.next()) {
                    Transactions t = new Transactions();
                    t.setId(rs.getInt("ID_TRANSACAO"));
                    t.setType(TransactionType.valueOf(rs.getString("TIPO_TRANSACAO")));
                    t.setValue(rs.getDouble("VALOR"));
                    t.setPayMethod(PaymentMethod.valueOf(rs.getString("PGT_METODO")));
                    t.setTransfer("S".equals(rs.getString("NR_TRANSFERENCIA")));
                    t.setIsScheduled(
                            "S".equals(rs.getString("ESTA_AGENDADA"))
                                    ? Scheduled.SCHEDULED
                                    : Scheduled.NONSCHEDULED
                    );
                    t.setTransactionDate(rs.getTimestamp("DT_TRANSACAO").toLocalDateTime());
                    list.add(t);
                }
                return list;
            }
        }
    }



    public void update(Transactions t) throws SQLException {
        String sql = "UPDATE T_TRANSACOES SET TIPO_TRANSACAO = ?, VALOR = ?, PGT_METODO = ?, NR_TRANSFERENCIA = ?, ESTA_AGENDADA = ?, DT_TRANSACAO = ? WHERE ID_TRANSACAO = ?";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setString(1, t.getType().name());
        stm.setDouble(2, t.getValue());
        stm.setString(3, t.getPayMethod().name());
        stm.setString(4, t.getTransfer() != null && t.getTransfer() ? "S" : "N");
        stm.setString(5, t.getIsScheduled() == Scheduled.SCHEDULED ? "S" : "N");
        stm.setObject(6, t.getTransactionDate());
        stm.setInt(7, t.getId());
        stm.executeUpdate();
    }


    public void delete(Integer id) throws SQLException {
        String sql = "DELETE FROM T_TRANSACOES WHERE ID_TRANSACAO = ?";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setInt(1, id);
        stm.executeUpdate();
    }

    public void closeConnection() throws SQLException {
        connection.close();
    }
}
