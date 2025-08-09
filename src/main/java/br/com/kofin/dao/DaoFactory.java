package br.com.kofin.dao;

import java.sql.SQLException;

public final class DaoFactory {

    private DaoFactory() {
    }

    public static CardsDao createCardsDao() throws SQLException {
        return new CardsDao();
    }

    public static TransactionsDao createTransactionsDao() throws SQLException {
        return new TransactionsDao();
    }

    public static AccountsDao createAccountsDao() throws SQLException {
        return new AccountsDao();
    }

    public static UsersDao createUsersDao() throws SQLException {
        return new UsersDao();
    }

    public static UserPasswordDao createUserPasswordDao() throws SQLException {
        return new UserPasswordDao();
    }

    public static UserDetailsDao createUserDetailsDao() throws SQLException {
        return new UserDetailsDao();
    }

}
