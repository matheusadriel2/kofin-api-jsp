package br.com.kofin.model.entities;

import br.com.kofin.model.enums.*;
import java.time.LocalDateTime;

public class Transactions {

    private Integer id;
    private String  name;
    private String  category;
    private TransactionType type;
    private Double value;
    private PaymentMethod payMethod;
    private Boolean transfer;
    private Scheduled isScheduled;
    private LocalDateTime transactionDate;

    private Integer cardId;
    private Integer accountId;

    public Transactions(){}

    public Integer getId()               { return id; }
    public void    setId(Integer id)     { this.id = id; }

    public String  getName()             { return name; }
    public void    setName(String n)     { this.name = n; }

    public String  getCategory()         { return category; }
    public void    setCategory(String c) { this.category = c; }

    public TransactionType getType()           { return type; }
    public void            setType(TransactionType t){ this.type = t; }

    public Double getValue()             { return value; }
    public void   setValue(Double value) { this.value = value; }

    public PaymentMethod getPayMethod()               { return payMethod; }
    public void          setPayMethod(PaymentMethod p){ this.payMethod = p; }

    public Boolean getTransfer()                 { return transfer; }
    public void    setTransfer(Boolean transfer) { this.transfer = transfer; }

    public Scheduled getIsScheduled()                    { return isScheduled; }
    public void      setIsScheduled(Scheduled scheduled) { this.isScheduled = scheduled; }

    public LocalDateTime getTransactionDate()                    { return transactionDate; }
    public void          setTransactionDate(LocalDateTime date)  { this.transactionDate = date; }

    public Integer getCardId()            { return cardId; }
    public void    setCardId(Integer id)  { this.cardId = id; }

    public Integer getAccountId()         { return accountId; }
    public void    setAccountId(Integer id){ this.accountId = id; }

    @Override public String toString(){
        return "Transactions{id=%d,name=%s,cat=%s,type=%s,val=%.2f,method=%s}".formatted(
                id,name,category,type,value,payMethod);
    }
}
