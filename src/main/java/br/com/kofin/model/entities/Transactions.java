package br.com.kofin.model.entities;

import br.com.kofin.model.enums.PaymentMethod;
import br.com.kofin.model.enums.Scheduled;
import br.com.kofin.model.enums.TransactionType;

import java.time.LocalDateTime;

public class Transactions {
    private Integer id;
    private TransactionType type;
    private Double value;
    private PaymentMethod payMethod;
    private Boolean isTransfer;
    private Scheduled isScheduled;
    private LocalDateTime transactionDate;

    public Transactions() {
    }

    public Transactions(Integer id, TransactionType type, Double value, PaymentMethod payMethod, Boolean isTransfer, Scheduled isScheduled, LocalDateTime transactionDate) {
        this.id = id;
        this.type = type;
        this.value = value;
        this.payMethod = payMethod;
        this.isTransfer = isTransfer;
        this.isScheduled = isScheduled;
        this.transactionDate = transactionDate;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public TransactionType getType() {
        return type;
    }

    public void setType(TransactionType type) {
        this.type = type;
    }

    public Double getValue() {
        return value;
    }

    public void setValue(Double value) {
        this.value = value;
    }

    public PaymentMethod getPayMethod() {
        return payMethod;
    }

    public void setPayMethod(PaymentMethod payMethod) {
        this.payMethod = payMethod;
    }

    public Boolean getTransfer() {
        return isTransfer;
    }

    public void setTransfer(Boolean transfer) {
        isTransfer = transfer;
    }

    public Scheduled getIsScheduled() {
        return isScheduled;
    }

    public void setIsScheduled(Scheduled isScheduled) {
        this.isScheduled = isScheduled;
    }

    public LocalDateTime getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(LocalDateTime transactionDate) {
        this.transactionDate = transactionDate;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("Transaction ID: " + id + "\n");
        sb.append("Value: " + value + "\n");
        sb.append("Payment Method: " + payMethod + "\n");
        sb.append("Date: " + transactionDate + " (" + isScheduled + ").");
        return sb.toString();
    }
}