typedef dynamic StorageHelperCustomConvertFunction(dynamic val);
typedef String StorageHelperCustomReConvertFunction(dynamic val);

class StorageHelperCustomType {
  /// Funzione che converte da stringa al tipo di dato
  final StorageHelperCustomConvertFunction convert;
  /// Funzione che converte dal tipo di dato a stringa
  final StorageHelperCustomReConvertFunction reConvert;

  const StorageHelperCustomType({this.convert, this.reConvert});
}