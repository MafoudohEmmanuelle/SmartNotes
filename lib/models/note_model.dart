class Note {
  String id;
  String titre;
  String contenu;
  DateTime dateCreation;
  bool statutSynchro;
  String? idDossier;
  String? nomDossier;// Peut être nulle si pas de dossier

  Note({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.dateCreation,
    this.statutSynchro = false,
    this.idDossier,
    this.nomDossier,
  });
}