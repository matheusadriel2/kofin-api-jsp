package br.com.kofin.model.entities;

import br.com.kofin.model.enums.CardType;

import java.time.LocalDate;

public class Cards {
    private Integer id;
    private CardType type;
    private Integer number;
    private LocalDate validity;
    private String flag;
    private LocalDate creationDate;
    private LocalDate updateDate;

    public Cards() {
    }

    public Cards(Integer id, CardType type, Integer number, LocalDate validity, String flag, LocalDate creationDate, LocalDate updateDate) {
        this.id = id;
        this.type = type;
        this.number = number;
        this.validity = validity;
        this.flag = flag;
        this.creationDate = creationDate;
        this.updateDate = updateDate;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public CardType getType() {
        return type;
    }

    public void setType(CardType type) {
        this.type = type;
    }

    public Integer getNumber() {
        return number;
    }

    public void setNumber(Integer number) {
        this.number = number;
    }

    public LocalDate getValidity() {
        return validity;
    }

    public void setValidity(LocalDate validity) {
        this.validity = validity;
    }

    public String getFlag() {
        return flag;
    }

    public void setFlag(String flag) {
        this.flag = flag;
    }

    public LocalDate getCreationDate() {
        return creationDate;
    }

    public void setCreationDate(LocalDate creationDate) {
        this.creationDate = creationDate;
    }

    public LocalDate getUpdateDate() {
        return updateDate;
    }

    public void setUpdateDate(LocalDate updateDate) {
        this.updateDate = updateDate;
    }
}