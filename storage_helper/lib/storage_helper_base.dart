import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:storage_helper/storage_helper_converter.dart';
import 'package:storage_helper_gen/storage_helper.model.dart';

class StorageHelperBase {
  final StorageHelperModel model;
  final FlutterSecureStorage storage = new FlutterSecureStorage();
  StorageHelperConverter converter;

  StorageHelperBase(this.model) {
    converter = new StorageHelperConverter(model);
  }

  void log(dynamic val) {
    if(model.log) print("[StorageHelper]"); print(val);
  }

  Future<dynamic> convertEl(dynamic type, String key, [dynamic defaultValue]) async {
    try {
      String val = await storage.read(
          key: key
      ) ?? converter.reConvert(type, defaultValue);

      if(val == null) return null;

      return converter.convert(type, val);
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
            value: converter.reConvert(type, val)
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
    try {
      log("getting \"$key\"...");

      dynamic val = await convertEl(type, key, defaultValue);

      log("\"$key\" = ");
      log(val);

      return val;
    } catch(e, stacktrace) {
      print(e);
      print(stacktrace);
      return null;
    }
  }
}