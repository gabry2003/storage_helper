import 'package:flutter/cupertino.dart';

typedef dynamic StorageHelperCustomConvertFunction(dynamic val);
typedef String StorageHelperCustomReConvertFunction(dynamic val);

class StorageHelperCustomType {
  /// Funzione che converte da stringa al tipo di dato
  StorageHelperCustomConvertFunction convert;
  /// Funzione che converte dal tipo di dato a stringa
  StorageHelperCustomReConvertFunction reConvert;

  StorageHelperCustomType({@required this.convert, @required this.reConvert});
}