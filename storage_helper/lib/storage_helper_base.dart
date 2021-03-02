import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:storage_helper/storage_helper_converter.dart';
import 'package:storage_helper_gen/storage_helper_model.dart';

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

  Future<T> convertEl<T>(String key, [T defaultValue]) async {
    try {
      String val = await storage.read(
          key: key
      ) ?? converter.reConvert<T>(defaultValue);

      if(val == null) return null;

      return converter.convert<T>(val);
    } catch(e, stacktrace) {
      print(e);
      print(stacktrace);

      return null;
    }
  }

  Future<bool> set<T>(String key, T val) async {
    try {
      if(val != null) {
        await storage.write(
            key: key,
            value: converter.reConvert<T>(val)
        );

        log("\"$key\" = ");
        log(val);
      }else {
        await storage.delete(key: key);

        log("deleting $key...");
      }

      return true;
    } catch(e, stacktrace) {
      print(e);
      print(stacktrace);
      return false;
    }
  }

  Future<T> get<T>(String key, [T defaultValue]) async {
    try {
      log("getting \"$key\"...");

      dynamic val = await convertEl<T>(key, defaultValue);

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