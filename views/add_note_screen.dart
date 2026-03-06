import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/note_model.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note;

  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _contenuController = TextEditingController();
  // Nouveau contrôleur pour le dossier
  final TextEditingController _dossierController = TextEditingController();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titreController.text = widget.note!.titre;
      _contenuController.text = widget.note!.contenu;
      // On suppose que ton modèle Note a maintenant un champ idDossier
      _dossierController.text = widget.note!.idDossier ?? "";
    }
  }

  void _sauvegarderNote() async {
    if (_titreController.text.isNotEmpty) {
      final String now = DateTime.now().toIso8601String();
      String nomDossier = _dossierController.text.trim();

      // Si vide, on met dans un dossier par défaut
      if (nomDossier.isEmpty) nomDossier = "Général";

      // L'ID du dossier est le nom en minuscule (simple et efficace)
      String idDossier = nomDossier.toLowerCase().replaceAll(' ', '_');

      // 1. On crée le dossier s'il n'existe pas
      await DatabaseHelper.instance.insertDossier({
        'id_dossier': idDossier,
        'nom': nomDossier,
      });

      // 2. On prépare la note avec l'id_dossier
      final Map<String, dynamic> noteData = {
        'id_note': widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'titre': _titreController.text,
        'contenu': _contenuController.text,
        'id_dossier': idDossier, // Lien vers le dossier
        'date_creation': widget.note?.dateCreation.toIso8601String() ?? now,
        'statut_synchro': 0,
      };

      if (widget.note == null) {
        await DatabaseHelper.instance.insertNote(noteData);
      } else {
        await DatabaseHelper.instance.updateNote(noteData);
      }

      setState(() {
        _isSaved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Note enregistrée dans '$nomDossier' !"),
            backgroundColor: Colors.green
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(widget.note == null ? "Ajouter une note" : "Modifier la note",
            style: const TextStyle(color: Colors.white)),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined, color: Colors.greenAccent, size: 28),
            onPressed: _sauvegarderNote,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CHAMP DOSSIER ajouté
            TextField(
              controller: _dossierController,
              decoration: InputDecoration(
                hintText: "Nom du dossier...",
                prefixIcon: const Icon(Icons.folder_open, color: Colors.deepOrange),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _titreController,
              decoration: const InputDecoration(
                hintText: "Titre",
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 24, color: Colors.black54),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const SizedBox(height: 10),
            TextField(
              controller: _contenuController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: "Notez quelque chose...",
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.image_outlined, color: Colors.deepOrange),
                label: const Text("Ajouter un média", style: TextStyle(color: Colors.black87)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}