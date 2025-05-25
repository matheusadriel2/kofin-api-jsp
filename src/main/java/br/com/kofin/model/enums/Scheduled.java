package br.com.kofin.model.enums;

public enum Scheduled {
    SCHEDULED("Scheduled"),
    NONSCHEDULED("Not Scheduled");

    private final String description;

    Scheduled(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }

    public Scheduled getNext() {
        return this == SCHEDULED ? NONSCHEDULED : SCHEDULED;
    }
}
