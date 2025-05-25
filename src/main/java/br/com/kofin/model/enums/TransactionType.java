package br.com.kofin.model.enums;

public enum TransactionType {
    INCOME('I'),
    EXPENSE('E'),
    INVESTMENT('V');   // “V” de inVestimento

    private final char code;
    TransactionType(char code){ this.code = code; }
    public char getCode(){ return code; }

    public static TransactionType fromCode(char c){
        return switch (c){
            case 'I' -> INCOME;
            case 'E' -> EXPENSE;
            case 'V' -> INVESTMENT;
            default  -> throw new IllegalArgumentException("Código inválido: "+c);
        };
    }
}
