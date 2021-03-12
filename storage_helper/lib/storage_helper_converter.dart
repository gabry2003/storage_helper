import 'package:storage_helper_gen/storage_helper_model.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:intl/intl.dart';

/// It is used to convert elements from String to that type and from that type to string
class StorageHelperConverter {
  /// StorageHelper's model
  StorageHelperModel model;

  /// Constructor, takes [model] as a parameter
  StorageHelperConverter(this.model);

  /// It takes [val] as a parameter, which is the string returned by FlutterSecureStorage
  /// Returns the string converted to an object of type `T`
  T convert<T>(String? val, {String? dateFormat}) {
    switch(T.toString()) {
      case "bool":
      case "bool?":
        return (val == "1") as T;
      case "int":
      case "int?":
        return int?.tryParse(val!) as T;
      case "double":
      case "double?":
        return double?.tryParse(val!) as T;
      case "DateTime":
      case "DateTime?":
        return (new DateFormat(dateFormat ?? model.dateFormat).parse(val!)) as T;
      case "String":
      case "String?":
        return val as T;
      default:
        return model.getType(T.toString())?.convertFromString(val) as T;
    }
  }

  /// It receives [val] as a parameter, which is an object of type `T`
  /// Returns the object converted to a string
  String? reConvert<T>(T val, {String? dateFormat}) {
    switch(T.toString()) {
      case "bool":
        return (val as bool) ? "1" : "0";
      case "bool?":
        return ((val as bool?) ?? false) ? "1" : "ß";
      case "int":
      case "double":
        return val.toString();
      case "int?":
      case "double?":
        return val?.toString();
      case "DateTime":
      case "DateTime?":
        return new DateFormat(dateFormat ?? model.dateFormat).format(val as DateTime);
      case "String":
        return val as String;
      case "String?":
        return val as String?;
      default:
        return model.getType(T.toString())?.convertToString(val);
    }
  }
}