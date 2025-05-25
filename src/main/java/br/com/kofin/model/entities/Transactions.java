package br.com.kofin.model.entities;

import br.com.kofin.model.enums.PaymentMethod;
import br.com.kofin.model.enums.Scheduled;
import br.com.kofin.model.enums.TransactionType;

import java.time.LocalDateTime;

/**
 * Entidade que representa qualquer transação financeira do usuário.
 * Uma transação **pode** estar vinculada a um cartão (cardId) ou conta (accountId).
 */
public class Transactions {
    private Integer id;
    private TransactionType type;
    private Double value;
    private PaymentMethod payMethod;
    private Boolean transfer;          // true = transferência entre contas
    private Scheduled isScheduled;
    private LocalDateTime transactionDate;

    /* NOVO: vínculos opcionais */
    private Integer cardId;            // fk T_CARTOES
    private Integer accountId;         // fk T_CONTAS

    /* --- construtores ---------------------------------------------------------------------- */

    public Transactions() {}

    public Transactions(Integer id,
                        TransactionType type,
                        Double value,
                        PaymentMethod payMethod,
                        Boolean transfer,
                        Scheduled isScheduled,
                        LocalDateTime transactionDate,
                        Integer cardId,
                        Integer accountId) {
        this.id = id;
        this.type = type;
        this.value = value;
        this.payMethod = payMethod;
        this.transfer = transfer;
        this.isScheduled = isScheduled;
        this.transactionDate = transactionDate;
        this.cardId = cardId;
        this.accountId = accountId;
    }

    /* --- getters / setters ----------------------------------------------------------------- */

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public TransactionType getType() { return type; }
    public void setType(TransactionType type) { this.type = type; }

    public Double getValue() { return value; }
    public void setValue(Double value) { this.value = value; }

    public PaymentMethod getPayMethod() { return payMethod; }
    public void setPayMethod(PaymentMethod payMethod) { this.payMethod = payMethod; }

    public Boolean getTransfer() { return transfer; }
    public void setTransfer(Boolean transfer) { this.transfer = transfer; }

    public Scheduled getIsScheduled() { return isScheduled; }
    public void setIsScheduled(Scheduled isScheduled) { this.isScheduled = isScheduled; }

    public LocalDateTime getTransactionDate() { return transactionDate; }
    public void setTransactionDate(LocalDateTime transactionDate) { this.transactionDate = transactionDate; }

    public Integer getCardId() { return cardId; }
    public void setCardId(Integer cardId) { this.cardId = cardId; }

    public Integer getAccountId() { return accountId; }
    public void setAccountId(Integer accountId) { this.accountId = accountId; }

    /* --- util ------------------------------------------------------------------------------ */

    @Override
    public String toString() {
        return """
               Transaction {
                 id=%d, type=%s, value=%.2f, method=%s, transfer=%s, scheduled=%s,
                 date=%s, cardId=%s, accountId=%s
               }""".formatted(id, type, value, payMethod, transfer, isScheduled,
                transactionDate, cardId, accountId);
    }
}
