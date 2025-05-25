package br.com.kofin.model.entities;

import br.com.kofin.model.enums.AccountType;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Accounts {
    private Integer id;
    private String name;
    private AccountType type;
    private Integer number;
    private Double balance;
    private LocalDateTime creationDate;
    private LocalDateTime updateDate;

    public Accounts() {
    }

    public Accounts(Integer id, String name, AccountType type, Integer number, Double balance, LocalDateTime creationDate, LocalDateTime updateDate) {
        this.id = id;
        this.name = name;
        this.type = type;
        this.number = number;
        this.balance = balance;
        this.creationDate = creationDate;
        this.updateDate = updateDate;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public AccountType getType() {
        return type;
    }

    public void setType(AccountType type) {
        this.type = type;
    }

    public Integer getNumber() {
        return number;
    }

    public void setNumber(Integer number) {
        this.number = number;
    }

    public Double getBalance() {
        return balance;
    }

    public void setBalance(Double balance) {
        this.balance = balance;
    }

    public LocalDateTime getCreationDate() {
        return creationDate;
    }

    public void setCreationDate(LocalDateTime creationDate) {
        this.creationDate = creationDate;
    }

    public LocalDateTime getUpdateDate() {
        return updateDate;
    }

    public void setUpdateDate(LocalDateTime updateDate) {
        this.updateDate = updateDate;
    }

    public LocalDateTime updateInfoDate() {
        LocalDateTime newDate = LocalDateTime.now();
        return this.updateDate = LocalDateTime.parse(newDate.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")));
    }

    public void addBalance(double value) {
        balance += value;
        updateInfoDate();
    }

    public void withdraw(double value) {
        if (value <= balance) {
            balance -= value;
            updateInfoDate();
        } else {
            System.out.println("Insufficient funds");
        }
    }

    @Override
    public String toString() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM/dd/yyyy HH:mm");
        StringBuilder sb = new StringBuilder();
        sb.append("Account ID: " + id + "\n");
        sb.append("Name: " + name + "\n");
        sb.append("Account Type: " + type + "\n");
        sb.append("Account Number: " + number + "\n");
        sb.append("Balance: $" + String.format("%.2f", balance) + "\n");
        sb.append("Creation Date: " + (creationDate != null ? creationDate.format(formatter) : "not available") + "\n");
        sb.append("Update Date: " + (updateDate != null ? updateDate.format(formatter) : "not available"));
        return sb.toString();
    }
}
