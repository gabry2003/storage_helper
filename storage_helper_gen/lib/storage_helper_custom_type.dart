class StorageHelperCustomType {
  /// Funzione che converte da stringa al tipo di dato
  final Function convert;
  /// Funzione che converte dal tipo di dato a stringa
  final Function reConvert;

  const StorageHelperCustomType({this.convert, this.reConvert});
}