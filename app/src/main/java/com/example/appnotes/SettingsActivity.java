package com.example.smartnotes;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.widget.RadioGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.appcompat.widget.SwitchCompat;

import com.google.android.material.appbar.MaterialToolbar;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;

import java.util.List;

public class SettingsActivity extends AppCompatActivity {

    private MaterialToolbar toolbar;
    private TextView accountEmailText;
    private SwitchCompat switchLocalBackup;
    private RadioGroup radioGroupTheme;
    private MaterialButton btnLogout;
    private SharedPreferences sharedPreferences;

    // Pour la base de données locale
    private DatabaseHelper dbHelper;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);

        initViews();
        loadPreferences();
        setupListeners();

        // Initialiser la base de données locale
        dbHelper = new DatabaseHelper(this);
    }

    private void initViews() {
        toolbar = findViewById(R.id.toolbar);
        accountEmailText = findViewById(R.id.account_email);
        switchLocalBackup = findViewById(R.id.switch_local_backup);
        radioGroupTheme = findViewById(R.id.radio_group_theme);
        btnLogout = findViewById(R.id.btn_logout);

        sharedPreferences = getSharedPreferences("app_prefs", Context.MODE_PRIVATE);

        setSupportActionBar(toolbar);
        if (getSupportActionBar() != null) {
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }
    }

    private void loadPreferences() {
        String userEmail = sharedPreferences.getString("user_email", "utilisateur@gmail.com");
        accountEmailText.setText(userEmail);

        boolean isLocalBackupEnabled = sharedPreferences.getBoolean("local_backup_enabled", true);
        switchLocalBackup.setChecked(isLocalBackupEnabled);

        int themeMode = sharedPreferences.getInt("theme_mode", AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM);
        if (themeMode == AppCompatDelegate.MODE_NIGHT_NO) {
            radioGroupTheme.check(R.id.radio_light);
        } else if (themeMode == AppCompatDelegate.MODE_NIGHT_YES) {
            radioGroupTheme.check(R.id.radio_dark);
        } else {
            radioGroupTheme.check(R.id.radio_auto);
        }
    }

    private void setupListeners() {
        toolbar.setNavigationOnClickListener(v -> finish());

        switchLocalBackup.setOnCheckedChangeListener((buttonView, isChecked) -> {
            SharedPreferences.Editor editor = sharedPreferences.edit();
            editor.putBoolean("local_backup_enabled", isChecked);
            editor.apply();
            Toast.makeText(this,
                    isChecked ? "Sauvegarde locale activée" : "Sauvegarde locale désactivée",
                    Toast.LENGTH_SHORT).show();
        });

        // Carte Google Drive (simple Toast, pas de fonctionnalité)
        findViewById(R.id.card_google_drive).setOnClickListener(v -> {
            Toast.makeText(this, "Fonctionnalité à venir", Toast.LENGTH_SHORT).show();
        });

        // Carte Restaurer (simple Toast)
        findViewById(R.id.card_restore).setOnClickListener(v -> {
            Toast.makeText(this, "Fonctionnalité à venir", Toast.LENGTH_SHORT).show();
        });

        // Carte Supprimer toutes les notes - ACTIVE
        findViewById(R.id.card_delete_all).setOnClickListener(v -> {
            new MaterialAlertDialogBuilder(this)
                    .setTitle("Supprimer toutes les notes")
                    .setMessage("Voulez-vous supprimer TOUTES les notes ?")
                    .setPositiveButton("Oui", (dialog, which) -> {
                        dbHelper.deleteAllNotes();
                        Toast.makeText(this, "Toutes les notes ont été supprimées", Toast.LENGTH_SHORT).show();
                    })
                    .setNegativeButton("Non", null)
                    .show();
        });

        // Carte Gérer les notes - ACTIVE (affiche la liste des notes locales)
        findViewById(R.id.card_manage_notes).setOnClickListener(v -> {
            afficherListeNotes();
        });

        // Carte Compte (info)
        findViewById(R.id.card_account).setOnClickListener(v ->
                Toast.makeText(this, "Email: " + accountEmailText.getText(), Toast.LENGTH_SHORT).show());

        // Gestion du thème
        radioGroupTheme.setOnCheckedChangeListener((group, checkedId) -> {
            int mode;
            if (checkedId == R.id.radio_light) {
                mode = AppCompatDelegate.MODE_NIGHT_NO;
                Toast.makeText(this, "Thème clair activé", Toast.LENGTH_SHORT).show();
            } else if (checkedId == R.id.radio_dark) {
                mode = AppCompatDelegate.MODE_NIGHT_YES;
                Toast.makeText(this, "Thème sombre activé", Toast.LENGTH_SHORT).show();
            } else {
                mode = AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM;
                Toast.makeText(this, "Thème automatique activé", Toast.LENGTH_SHORT).show();
            }

            SharedPreferences.Editor editor = sharedPreferences.edit();
            editor.putInt("theme_mode", mode);
            editor.apply();
            AppCompatDelegate.setDefaultNightMode(mode);
        });

        // Bouton Se déconnecter
        btnLogout.setOnClickListener(v -> showLogoutDialog());
    }

    // ================ GESTION DES NOTES LOCALES ================

    private void afficherListeNotes() {
        List<Note> notes = dbHelper.getAllNotes();

        if (notes.isEmpty()) {
            new MaterialAlertDialogBuilder(this)
                    .setTitle("Mes Notes")
                    .setMessage("Aucune note disponible")
                    .setPositiveButton("OK", null)
                    .show();
            return;
        }

        // Créer un tableau des titres pour l'affichage
        String[] titres = new String[notes.size()];
        for (int i = 0; i < notes.size(); i++) {
            titres[i] = (i+1) + ". " + notes.get(i).getTitre();
        }

        // Afficher la liste des notes
        new MaterialAlertDialogBuilder(this)
                .setTitle("Mes Notes (" + notes.size() + ")")
                .setItems(titres, (dialog, which) -> {
                    // Quand on clique sur une note, afficher ses détails
                    afficherDetailNote(notes.get(which));
                })
                .setPositiveButton("Fermer", null)
                .show();
    }

    private void afficherDetailNote(Note note) {
        String message = "📝 Titre: " + note.getTitre() + "\n\n"
                + "📄 Contenu:\n" + note.getContenu();

        new MaterialAlertDialogBuilder(this)
                .setTitle("Détail de la note")
                .setMessage(message)
                .setPositiveButton("🗑️ Supprimer", (dialog, which) -> {
                    // Supprimer cette note précise
                    dbHelper.deleteNote(note.getId());
                    Toast.makeText(this, "Note supprimée", Toast.LENGTH_SHORT).show();
                    // Re-afficher la liste mise à jour
                    afficherListeNotes();
                })
                .setNegativeButton("Retour", (dialog, which) -> {
                    // Revenir à la liste
                    afficherListeNotes();
                })
                .show();
    }

    // ================ DIALOGUES EXISTANTS ================

    private void showLogoutDialog() {
        new MaterialAlertDialogBuilder(this)
                .setTitle("Déconnexion")
                .setMessage("Voulez-vous vraiment vous déconnecter ?")
                .setPositiveButton("Se déconnecter", (dialog, which) -> {
                    SharedPreferences.Editor editor = sharedPreferences.edit();
                    editor.putBoolean("is_logged_in", false);
                    editor.apply();
                    Toast.makeText(this, "Déconnexion...", Toast.LENGTH_SHORT).show();
                    finish();
                })
                .setNegativeButton("Annuler", null)
                .show();
    }
}