import 'package:storage_helper_gen/storage_helper_model.dart';
import 'package:storage_helper_gen/storage_helper_type.dart';

import 'package:intl/intl.dart';

class StorageHelperConverter {
  StorageHelperModel model;

  StorageHelperConverter(this.model);

  dynamic convert(dynamic type, String val) {
    if(type is String) { // Se l'elemento è di un tipo personalizzato
      return model.getType(type).convert(val);
    }else { // Altrimenti converto con i tipi normali
      switch(type) {
        case StorageHelperType.bool:
          return val == "1";
          break;
        case StorageHelperType.int:
          return int.tryParse(val);
          break;
        case StorageHelperType.double:
          return double.tryParse(val);
          break;
        case StorageHelperType.DateTime:
          return new DateFormat(model.dateFormat).parse(val);
          break;
        case StorageHelperType.String:
          return val;
          break;
        default:
          return null;
      }
    }
  }

  String reConvert(dynamic type, dynamic val) {
    switch(type) {
      case StorageHelperType.bool:
        return ((val as bool) ?? false) ? "1" : "0";
        break;
      case StorageHelperType.int:
      case StorageHelperType.double:
        return val?.toString();
        break;
      case StorageHelperType.DateTime:
        return new DateFormat(model.dateFormat).format(val);
        break;
      case StorageHelperType.String:
        return val;
        break;
      default:
        if(type is String) { // Se l'elemento è di un tipo personalizzato
          return model.getType(type).reConvert(val);
        }else { // Altrimenti torno null
          return null;
        }
    }
  }
}