import 'package:storage_helper_gen/storage_helper_model.dart';
import 'package:intl/intl.dart';

/// It is used to convert elements from String to that type and from that type to string
class StorageHelperConverter {
  /// StorageHelper's model
  StorageHelperModel model;

  /// Constructor, takes [model] as a parameter
  StorageHelperConverter(this.model);

  /// It takes [val] as a parameter, which is the string returned by FlutterSecureStorage
  /// Returns the string converted to an object of type [T]
  T convert<T>(String val) {
    switch(T.toString()) {
      case "bool":
        return (val == "1") as T;
        break;
      case "int":
        return int.tryParse(val) as T;
        break;
      case "double":
        return double.tryParse(val) as T;
        break;
      case "DateTime":
        return (new DateFormat(model.dateFormat).parse(val)) as T;
        break;
      case "String":
        return val as T;
        break;
      default:
        return model.getType(T.toString())?.convert(val);
    }
  }

  /// It receives [val] as a parameter, which is an object of type [T]
  /// Returns the object converted to a string
  String reConvert<T>(T val) {
    switch(T.toString()) {
      case "bool":
        return ((val as bool) ?? false) ? "1" : "0";
        break;
      case "int":
      case "double":
        return val?.toString();
        break;
      case "DateTime":
        return new DateFormat(model.dateFormat).format(val as DateTime);
        break;
      case "String":
        return val as String;
        break;
      default:
        return model.getType(T.toString()).reConvert(val);
    }
  }
}