package br.com.kofin.model.entities;

import br.com.kofin.model.enums.CardType;
import java.time.LocalDate;

/** Entidade de Cartão do usuário. */
public class Cards {

    /* ---------- campos ---------- */
    private Integer   id;
    private String    name;      // apelido escolhido pelo usuário
    private String    last4;     // “XXXX” ou 4 dígitos
    private CardType  type;      // DEBIT | CREDIT
    private LocalDate validity;  // AAAA-MM-01
    private String    flag;      // texto / emoji / ícone
    private LocalDate creationDate;
    private LocalDate updateDate;

    /* ---------- construtores ---------- */
    public Cards() {}

    public Cards(Integer id, String name, String last4, CardType type,
                 LocalDate validity, String flag,
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

    /* ---------- getters / setters ---------- */
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

    public String  getFlag()                  { return flag; }
    public void    setFlag(String flag)       { this.flag = flag; }

    public LocalDate getCreationDate()        { return creationDate; }
    public void      setCreationDate(LocalDate d){ this.creationDate = d; }

    public LocalDate getUpdateDate()          { return updateDate; }
    public void      setUpdateDate(LocalDate d){ this.updateDate = d; }

    @Override public String toString() {
        return "Cards{id=%d,name=%s,last4=%s,type=%s}".formatted(id,name,last4,type);
    }
}
