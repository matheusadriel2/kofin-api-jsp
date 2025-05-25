package br.com.kofin.model.enums;

public enum AccountType {
    CURRENT("Current Account"),
    SAVINGS("Savings Account"),
    SALARY("Salary Account"),
    PAYMENT("Payment Account"),
    DIGITAL("Digital Account"),
    JOINT("Joint Account");

    private final String description;

    AccountType(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
