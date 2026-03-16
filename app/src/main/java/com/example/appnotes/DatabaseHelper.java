package com.example.smartnotes;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import java.util.ArrayList;
import java.util.List;

public class DatabaseHelper extends SQLiteOpenHelper {

    private static final String DATABASE_NAME = "notes.db";
    private static final int DATABASE_VERSION = 2;
    private static final String TABLE_NOTES = "notes";
    private static final String COLUMN_ID = "id";
    private static final String COLUMN_TITRE = "titre";
    private static final String COLUMN_CONTENU = "contenu";

    public DatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        String createTable = "CREATE TABLE " + TABLE_NOTES + "("
                + COLUMN_ID + " INTEGER PRIMARY KEY AUTOINCREMENT,"
                + COLUMN_TITRE + " TEXT,"
                + COLUMN_CONTENU + " TEXT"
                + ")";
        db.execSQL(createTable);

        // Ajouter des notes de test automatiquement
        ajouterNotesTest(db);
    }

    private void ajouterNotesTest(SQLiteDatabase db) {
        String[][] notesTest = {
                {"Bienvenue", "Bienvenue dans votre application"},
                {"Liste de courses", "Lait, Pain, Oeufs, Beurre"},
                {"Idées projet", "Interface paramètres\nGestion des notes"},
                {"Rendez-vous", "Réunion demain à 14h"},
                {"Notes cours", "Android Studio - SQLite - Paramètres"}
        };

        for (String[] note : notesTest) {
            ContentValues values = new ContentValues();
            values.put(COLUMN_TITRE, note[0]);
            values.put(COLUMN_CONTENU, note[1]);
            db.insert(TABLE_NOTES, null, values);
        }
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_NOTES);
        onCreate(db);
    }

    // Récupérer toutes les notes
    public List<Note> getAllNotes() {
        List<Note> notes = new ArrayList<>();
        String query = "SELECT * FROM " + TABLE_NOTES + " ORDER BY " + COLUMN_ID + " DESC";

        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.rawQuery(query, null);

        if (cursor.moveToFirst()) {
            do {
                Note note = new Note();
                note.setId(cursor.getInt(0));
                note.setTitre(cursor.getString(1));
                note.setContenu(cursor.getString(2));
                notes.add(note);
            } while (cursor.moveToNext());
        }

        cursor.close();
        db.close();
        return notes;
    }

    // Supprimer une note précise
    public void deleteNote(int id) {
        SQLiteDatabase db = this.getWritableDatabase();
        db.delete(TABLE_NOTES, COLUMN_ID + " = ?", new String[]{String.valueOf(id)});
        db.close();
    }

    // Supprimer toutes les notes
    public void deleteAllNotes() {
        SQLiteDatabase db = this.getWritableDatabase();
        db.execSQL("DELETE FROM " + TABLE_NOTES);
        db.close();
    }

    // Compter les notes
    public int getNotesCount() {
        SQLiteDatabase db = this.getReadableDatabase();
        Cursor cursor = db.rawQuery("SELECT COUNT(*) FROM " + TABLE_NOTES, null);
        cursor.moveToFirst();
        int count = cursor.getInt(0);
        cursor.close();
        db.close();
        return count;
    }
}