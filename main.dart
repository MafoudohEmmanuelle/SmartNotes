import 'package:flutter/material.dart';
import 'package:smart_notes/models/note_model.dart';
import 'package:smart_notes/services/database_helper.dart';
import 'package:smart_notes/views/add_note_screen.dart';
import 'package:smart_notes/views/settings_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const NotesScreen(),
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> mesNotes = [];

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    final data = await DatabaseHelper.instance.queryNotesWithFolderName();
    setState(() {
      mesNotes = data.map((item) => Note(
        id: item['id_note'],
        titre: item['titre'],
        contenu: item['contenu'] ?? '',
        dateCreation: DateTime.parse(item['date_creation']),
        idDossier: item['id_dossier'], // Optionnel mais bien de l'avoir
        nomDossier: item['nom_du_dossier'] ?? 'Général', // <--- AJOUTE CECI
      )).toList();
    });
  }

  void _ajouterOuModifierNote({Note? note}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(note: note),
      ),
    ).then((_) => _refreshNotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Mes Notes",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text(
              "Toutes les notes",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: mesNotes.isEmpty
                ? const Center(child: Text("Aucune note pour le moment"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: mesNotes.length,
                    itemBuilder: (context, index) {
                      final note = mesNotes[index];
                      return _buildNoteItem(note);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ajouterOuModifierNote(),
        shape: const CircleBorder(),
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNoteItem(Note note) {
    String dateStr = "${note.dateCreation.day}/${note.dateCreation.month}/${note.dateCreation.year}";
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.note, color: Colors.green),
        title: Text(note.titre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dossier : ${note.nomDossier ?? 'Général'}",
                style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600)),
            Text("Créé le $dateStr", style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          _ajouterOuModifierNote(note: note);
        },
      ),
    );
  }
}