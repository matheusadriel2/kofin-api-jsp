package br.com.kofin.model.enums;

public enum TransactionType {
    INCOME     ('R'),
    EXPENSE    ('D'),
    INVESTMENT ('I');

    private final char code;
    TransactionType(char code){ this.code = code; }
    public char getCode(){ return code; }

    public static TransactionType fromCode(char c){
        return switch (c){
            case 'R' -> INCOME;
            case 'D' -> EXPENSE;
            case 'I' -> INVESTMENT;
            default  -> throw new IllegalArgumentException("Código inválido: "+c);
        };
    }
}
