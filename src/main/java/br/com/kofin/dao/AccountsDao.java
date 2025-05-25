package br.com.kofin.dao;

import br.com.kofin.exception.EntityNotFoundException;
import br.com.kofin.factory.ConnectionFactory;
import br.com.kofin.model.entities.Accounts;
import br.com.kofin.model.enums.AccountType;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class AccountsDao {
    private Connection connection;

    public AccountsDao() throws SQLException {
        connection = ConnectionFactory.getConnection();
    }

    public void register(Accounts account, Integer userId) throws SQLException {
        String sql = "INSERT INTO T_CONTAS (ID_CONTA, T_USUARIOS_ID_USUARIO, NM_BANCO, TIPO_CONTA, NR_CONTA, SALDO, DT_CRIACAO, DT_ATUALIZACAO) " +
                "VALUES (seq_id_account.NEXTVAL, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setInt(1, userId);
        stm.setString(2, account.getName());
        stm.setString(3, account.getType().name()); // ou account.getType().getDescription() se quiser salvar a descrição
        stm.setInt(4, account.getNumber());
        stm.setDouble(5, account.getBalance());
        stm.setObject(6, account.getCreationDate() != null ? account.getCreationDate() : LocalDateTime.now());
        stm.setObject(7, account.getUpdateDate());
        stm.executeUpdate();
    }

    public Accounts search(Integer id) throws SQLException, EntityNotFoundException {
        String sql = "SELECT * FROM T_CONTAS WHERE ID_CONTA = ?";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setInt(1, id);
        ResultSet result = stm.executeQuery();

        if (!result.next())
            throw new EntityNotFoundException("Conta não encontrada.");

        Accounts account = new Accounts();
        account.setId(result.getInt("ID_CONTA"));
        account.setName(result.getString("NM_BANCO"));
        account.setType(AccountType.valueOf(result.getString("TIPO_CONTA")));
        account.setNumber(result.getInt("NR_CONTA"));
        account.setBalance(result.getDouble("SALDO"));
        account.setCreationDate(result.getTimestamp("DT_CRIACAO").toLocalDateTime());

        Timestamp update = result.getTimestamp("DT_ATUALIZACAO");
        if (update != null) {
            account.setUpdateDate(update.toLocalDateTime());
        }

        return account;
    }

    public List<Accounts> getAll() throws SQLException {
        String sql = "SELECT * FROM T_CONTAS";
        PreparedStatement stm = connection.prepareStatement(sql);
        ResultSet result = stm.executeQuery();

        List<Accounts> list = new ArrayList<>();

        while (result.next()) {
            Accounts account = new Accounts();
            account.setId(result.getInt("ID_CONTA"));
            account.setName(result.getString("NM_BANCO"));
            account.setType(AccountType.valueOf(result.getString("TIPO_CONTA")));
            account.setNumber(result.getInt("NR_CONTA"));
            account.setBalance(result.getDouble("SALDO"));
            account.setCreationDate(result.getTimestamp("DT_CRIACAO").toLocalDateTime());

            Timestamp update = result.getTimestamp("DT_ATUALIZACAO");
            if (update != null) {
                account.setUpdateDate(update.toLocalDateTime());
            }

            list.add(account);
        }

        return list;
    }

    public void update(Accounts account) throws SQLException {
        String sql = "UPDATE T_CONTAS SET NM_BANCO = ?, TIPO_CONTA = ?, NR_CONTA = ?, SALDO = ?, DT_ATUALIZACAO = ? WHERE ID_CONTA = ?";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setString(1, account.getName());
        stm.setString(2, account.getType().name());
        stm.setInt(3, account.getNumber());
        stm.setDouble(4, account.getBalance());
        stm.setObject(5, LocalDateTime.now());
        stm.setInt(6, account.getId());
        stm.executeUpdate();
    }

    public void delete(Integer id) throws SQLException {
        String sql = "DELETE FROM T_CONTAS WHERE ID_CONTA = ?";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setInt(1, id);
        stm.executeUpdate();
    }

    public void closeConnection() throws SQLException {
        connection.close();
    }
}
