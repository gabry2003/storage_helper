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
  /// Descrizione dell'elemento, ogni elmeento della lista è una riga della descrizione (opzionale)
  final List<String> description;
  /// Valore di default dell'elemento (opzionale)
  final dynamic defaultValue;

  const StorageHelperElement({this.key, this.type, this.onInit=false, this.description, this.defaultValue});

  Map<String, dynamic> get toMap => {
    "key": key,
    "type": type,
    "onInit": onInit,
    "description": description,
    "defaultValue": defaultValue
  };
}