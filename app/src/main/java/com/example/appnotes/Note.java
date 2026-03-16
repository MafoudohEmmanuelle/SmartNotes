package com.example.smartnotes;

public class Note {
    private int id;
    private String titre;
    private String contenu;

    public Note() {}

    public Note(String titre, String contenu) {
        this.titre = titre;
        this.contenu = contenu;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }

    public String getContenu() { return contenu; }
    public void setContenu(String contenu) { this.contenu = contenu; }
}