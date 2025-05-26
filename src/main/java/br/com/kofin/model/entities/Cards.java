package br.com.kofin.model.entities;

import br.com.kofin.model.enums.CardFlag;
import br.com.kofin.model.enums.CardType;
import java.time.LocalDate;

public class Cards {

    private Integer   id;
    private String    name;
    private String    last4;
    private CardType  type;
    private LocalDate validity;
    private CardFlag  flag;
    private LocalDate creationDate;
    private LocalDate updateDate;

    public Cards() {}

    public Cards(Integer id, String name, String last4, CardType type,
                 LocalDate validity, CardFlag flag,
                 LocalDate creationDate, LocalDate updateDate) {
        this.id = id;
        this.name = name;
        this.last4 = last4;
        this.type = type;
        this.validity = validity;
        this.flag = flag;
        this.creationDate = creationDate;
        this.updateDate = updateDate;
    }

    public Integer getId()                    { return id; }
    public void    setId(Integer id)          { this.id = id; }

    public String  getName()                  { return name; }
    public void    setName(String name)       { this.name = name; }

    public String  getLast4()                 { return last4; }
    public void    setLast4(String last4)     { this.last4 = last4; }

    public CardType getType()                 { return type; }
    public void     setType(CardType type)    { this.type = type; }

    public LocalDate getValidity()            { return validity; }
    public void      setValidity(LocalDate v) { this.validity = v; }

    public CardFlag getFlag()                 { return flag; }
    public void     setFlag(CardFlag f)       { this.flag = f; }

    public LocalDate getCreationDate()        { return creationDate; }
    public void      setCreationDate(LocalDate d){ this.creationDate = d; }

    public LocalDate getUpdateDate()          { return updateDate; }
    public void      setUpdateDate(LocalDate d){ this.updateDate = d; }

    @Override public String toString() {
        return "Cards{id=%d,name=%s,last4=%s,type=%s}".formatted(id,name,last4,type);
    }
}
