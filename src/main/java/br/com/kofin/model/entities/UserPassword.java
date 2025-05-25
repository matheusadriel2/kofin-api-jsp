package br.com.kofin.model.entities;

import java.time.LocalDateTime;

public class UserPassword {
    private Integer id;
    private Users user;
    private String password;
    private LocalDateTime creationDate;
    private LocalDateTime updateDate;

    public UserPassword() {}

    public UserPassword(Integer id, Users user, String password,
                        LocalDateTime creationDate, LocalDateTime updateDate) {
        this.id = id;
        this.user = user;
        this.password = password;
        this.creationDate = creationDate;
        this.updateDate = updateDate;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Users getUser() { return user; }
    public void setUser(Users user) { this.user = user; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public LocalDateTime getCreationDate() { return creationDate; }
    public void setCreationDate(LocalDateTime creationDate) { this.creationDate = creationDate; }

    public LocalDateTime getUpdateDate() { return updateDate; }
    public void setUpdateDate(LocalDateTime updateDate) { this.updateDate = updateDate; }
}
