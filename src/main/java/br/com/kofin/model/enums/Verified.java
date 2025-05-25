package br.com.kofin.model.enums;

public enum Verified {
    VERIFIED("Verified"),
    NONVERIFIED("Not Verified");

    private final String description;

    Verified(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }

    public static Verified getDefault() {
        return NONVERIFIED;
    }
}
