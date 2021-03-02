import 'package:storage_helper_gen/storage_helper_model.dart';
import 'package:storage_helper_gen/storage_helper_type.dart';

import 'package:intl/intl.dart';

class StorageHelperConverter {
  StorageHelperModel model;

  StorageHelperConverter(this.model);

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

  String reConvert<T>(dynamic val) {
    switch(T.toString()) {
      case "bool":
        return ((val as bool) ?? false) ? "1" : "0";
        break;
      case "int":
      case "double":
        return val?.toString();
        break;
      case "DateTime":
        return new DateFormat(model.dateFormat).format(val);
        break;
      case "String":
        return val;
        break;
      default:
        return model.getType(T.toString()).reConvert(val);
    }
  }
}