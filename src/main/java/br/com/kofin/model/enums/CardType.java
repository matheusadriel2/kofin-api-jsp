package br.com.kofin.model.enums;

import java.util.ArrayList;
import java.util.Arrays;

public enum CardType {
    DEBIT("Debit"),
    CREDIT("Credit");

    private final String description;

    CardType(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }

    public static ArrayList<CardType> getValues() {
        return (ArrayList<CardType>) Arrays.asList(CardType.values());
    }
}
