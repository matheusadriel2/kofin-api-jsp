package br.com.kofin.model.entities;

import java.time.LocalDate;
import java.time.LocalDateTime;


public class UserDetails {
    private Integer id;
    private Users user;
    private String cpf;
    private LocalDate birthDate;
    private String gender;
    private LocalDateTime creationDate;
    private LocalDateTime updateDate;

    public UserDetails() {}

    public UserDetails(Integer id, Users user, String cpf, LocalDate birthDate,
                       String gender, LocalDateTime creationDate, LocalDateTime updateDate) {
        this.id = id;
        this.user = user;
        this.cpf = cpf;
        this.birthDate = birthDate;
        this.gender = gender;
        this.creationDate = creationDate;
        this.updateDate = updateDate;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Users getUser() { return user; }
    public void setUser(Users user) { this.user = user; }

    public String getCpf() { return cpf; }
    public void setCpf(String cpf) { this.cpf = cpf; }

    public LocalDate getBirthDate() { return birthDate; }
    public void setBirthDate(LocalDate birthDate) { this.birthDate = birthDate; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public LocalDateTime getCreationDate() { return creationDate; }
    public void setCreationDate(LocalDateTime creationDate) { this.creationDate = creationDate; }

    public LocalDateTime getUpdateDate() { return updateDate; }
    public void setUpdateDate(LocalDateTime updateDate) { this.updateDate = updateDate; }
}