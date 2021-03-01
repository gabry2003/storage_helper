import 'package:flutter/cupertino.dart';
import 'package:storage_helper/storage_helper_type.dart';

/// Modello di un elemento StorageHelper
/// Passare il la classe del tipo di dato
class StorageHelperElement<T> {
  /// Chiave identificativa dell'elemento
  final String key;
  /// Tipo di dato dell'elemento
  final T type;
  /// Se l'elemento deve essere inserito come attributo e deve essere inizializzato nel metodo init
  /// Può essere utile nel caso in cui tu voglia accedere a quell'elemento senza effettuare una chiamata asincrona, ma inizializzando tutti gli attributi in una sola chiamata
  final bool onInit;
  /// Descrizione dell'elemento (opzionale)
  final String description;
  /// Valore di default dell'elemento (opzionale)
  final String defaultValue;

  StorageHelperElement({@required this.key, @required this.type, this.onInit=false, this.description, this.defaultValue}) {
    assert(T is String || T is StorageHelperType);
  }
}