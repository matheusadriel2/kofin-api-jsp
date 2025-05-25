package br.com.kofin.dao;

import br.com.kofin.exception.EntityNotFoundException;
import br.com.kofin.factory.ConnectionFactory;
import br.com.kofin.model.entities.Cards;
import br.com.kofin.model.enums.CardType;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class CardsDao {
    private Connection connection;

    public CardsDao() throws SQLException {
        connection = ConnectionFactory.getConnection();
    }

    public void register(Cards card, Integer userId) throws SQLException {
        String sql = "INSERT INTO T_CARTOES (ID_CARTAO, T_USUARIOS_ID_USUARIO, TIPO_CARTAO, NR_CARTAO, VALIDADE, BANDEIRA, DT_CRIACAO, DT_ATUALIZACAO) " +
                "VALUES (seq_id_cartao.NEXTVAL, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setInt(1, userId);
        stm.setString(2, card.getType().name());
        stm.setInt(3, card.getNumber());
        stm.setDate(4, Date.valueOf(card.getValidity()));
        stm.setString(5, card.getFlag());
        stm.setDate(6, Date.valueOf(card.getCreationDate() != null ? card.getCreationDate() : LocalDate.now()));
        stm.setDate(7, card.getUpdateDate() != null ? Date.valueOf(card.getUpdateDate()) : null);
        stm.executeUpdate();
    }

    public Cards search(Integer id) throws SQLException, EntityNotFoundException {
        String sql = "SELECT * FROM T_CARTOES WHERE ID_CARTAO = ?";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setInt(1, id);
        ResultSet rs = stm.executeQuery();

        if (!rs.next())
            throw new EntityNotFoundException("Cartão não encontrado.");

        Cards card = new Cards();
        card.setId(rs.getInt("ID_CARTAO"));
        card.setType(CardType.valueOf(rs.getString("TIPO_CARTAO")));
        card.setNumber(rs.getInt("NR_CARTAO"));
        card.setValidity(rs.getDate("VALIDADE").toLocalDate());
        card.setFlag(rs.getString("BANDEIRA"));
        card.setCreationDate(rs.getDate("DT_CRIACAO").toLocalDate());

        Date update = rs.getDate("DT_ATUALIZACAO");
        if (update != null) {
            card.setUpdateDate(update.toLocalDate());
        }

        return card;
    }

    public List<Cards> getAllByUser(int userId) throws SQLException {
        String sql = "SELECT * FROM T_CARTOES WHERE T_USUARIOS_ID_USUARIO = ?";
        try (PreparedStatement stm = connection.prepareStatement(sql)) {
            stm.setInt(1, userId);
            try (ResultSet rs = stm.executeQuery()) {
                List<Cards> list = new ArrayList<>();
                while (rs.next()) {
                    Cards card = new Cards();
                    card.setId(rs.getInt("ID_CARTAO"));
                    card.setType(CardType.valueOf(rs.getString("TIPO_CARTAO")));
                    card.setNumber(rs.getInt("NR_CARTAO"));
                    card.setValidity(rs.getDate("VALIDADE").toLocalDate());
                    card.setFlag(rs.getString("BANDEIRA"));
                    card.setCreationDate(rs.getDate("DT_CRIACAO").toLocalDate());
                    Date update = rs.getDate("DT_ATUALIZACAO");
                    if (update != null) {
                        card.setUpdateDate(update.toLocalDate());
                    }
                    list.add(card);
                }
                return list;
            }
        }
    }

    public void update(Cards card) throws SQLException {
        String sql = "UPDATE T_CARTOES SET TIPO_CARTAO = ?, NR_CARTAO = ?, VALIDADE = ?, BANDEIRA = ?, DT_ATUALIZACAO = ? WHERE ID_CARTAO = ?";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setString(1, card.getType().name());
        stm.setInt(2, card.getNumber());
        stm.setDate(3, Date.valueOf(card.getValidity()));
        stm.setString(4, card.getFlag());
        stm.setDate(5, Date.valueOf(LocalDate.now()));
        stm.setInt(6, card.getId());
        stm.executeUpdate();
    }

    public void delete(Integer id) throws SQLException {
        String sql = "DELETE FROM T_CARTOES WHERE ID_CARTAO = ?";
        PreparedStatement stm = connection.prepareStatement(sql);
        stm.setInt(1, id);
        stm.executeUpdate();
    }

    public void closeConnection() throws SQLException {
        connection.close();
    }
}