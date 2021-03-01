import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class StorageHelperBase {
  final StorageHelperModel model;
  final bool doLog;
  FlutterSecureStorage storage;

  StorageHelperBase({@required this.model, this.doLog = true}) {
    storage = new FlutterSecureStorage();
  }

  void log(dynamic val) {
    if(doLog) print("[StorageHelper]"); print(val);
  }

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

  Future<dynamic> convertEl(dynamic type, String key, [dynamic defaultValue]) async {
    try {
      String val = await storage.read(
          key: key
      ) ?? reConvert(type, defaultValue);

      if(val == null) return null;

      return convert(type, val);
    } catch(e, stacktrace) {
      print(e);
      print(stacktrace);

      return null;
    }
  }

  Future<bool> set(dynamic type, String key, dynamic val) async {
    try {
      if(val != null) {
        await storage.write(
            key: key,
            value: reConvert(type, val)
        );
      }else {
        await storage.delete(key: key);
      }

      log("\"$key\" = ");
      log(val);

      return true;
    } catch(e, stacktrace) {
      print(e);
      print(stacktrace);
      return false;
    }
  }

  Future<dynamic> get(dynamic type, String key, [dynamic defaultValue]) async {
    log("getting \"$key\"...");

    dynamic val = await convertEl(type, key, defaultValue);

    log("\"$key\" = ");
    log(val);

    return val;
  }
}