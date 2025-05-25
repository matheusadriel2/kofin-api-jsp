package br.com.kofin.model.enums;

public enum CardFlag {
    VISA        ("visa.png"),
    MASTERCARD  ("mastercard.png"),
    ELO         ("elo.png"),
    AMEX        ("amex.png");

    private final String img;
    CardFlag(String img){ this.img = img; }
    public String getImg(){ return img; }
}
