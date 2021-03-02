import 'package:storage_helper_gen/storage_helper_element.dart';

class StorageHelperCategory {
  /// Categoria padre
  final int parent;
  /// Chiave identificativa della categoria
  /// Può essere non inserita solamente in una categoria e in quel caso la classe generata sarà quella principale
  final String key;
  /// Descrizione della categoria (opzionale)
  final String description;
  /// Elementi della categoria
  final List<StorageHelperElement> elements;

  const StorageHelperCategory({this.parent, this.key, this.description, this.elements});

  Map<String, dynamic> get toMap => {
    "parent": parent,
    "key": key,
    "description": description,
    "elements": elements.map(
            (StorageHelperElement element) => element.toMap
    )
  };
}