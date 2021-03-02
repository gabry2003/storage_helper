/// Modello di un elemento StorageHelper
/// Passare il la classe del tipo di dato
class StorageHelperElement<T> {
  /// Chiave identificativa dell'elemento
  final String key;
  /// Chiave da inserire nella variabile static
  final String staticKey;
  /// Chiavi da concatenare nei getter e nei setter
  final List<String> concateneKeys;
  /// Tipo di dato dell'elemento
  final T type;
  /// Se l'elemento deve essere inserito come attributo e deve essere inizializzato nel metodo init
  /// Può essere utile nel caso in cui tu voglia accedere a quell'elemento senza effettuare una chiamata asincrona, ma inizializzando tutti gli attributi in una sola chiamata
  final bool onInit;
  /// Descrizione dell'elemento, ogni elmeento della lista è una riga della descrizione (opzionale)
  final List<String> description;
  /// Valore di default dell'elemento (opzionale)
  /// Al momento non funziona sugli elementi con un tipo personalizzato
  final dynamic defaultValue;

  const StorageHelperElement({this.key, this.staticKey, this.concateneKeys, this.type, this.onInit=false, this.description, this.defaultValue});

  Map<String, dynamic> get toMap => {
    "key": key,
    "staticKey": staticKey,
    "concateneKeys": concateneKeys,
    "type": type,
    "onInit": onInit,
    "description": description,
    "defaultValue": defaultValue
  };
}