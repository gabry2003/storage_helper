import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:storage_helper/storage_helper_converter.dart';
import 'package:storage_helper_gen/storage_helper_model.dart';

class StorageHelperBase {
  /// Modello of StorageHelper
  final StorageHelperModel model;
  /// Object of FlutterSecureStorage
  final FlutterSecureStorage storage = new FlutterSecureStorage();
  StorageHelperConverter converter;

  StorageHelperBase(this.model) {
    converter = new StorageHelperConverter(model);
  }

  /// Print the log on the screen if [model.log] is active
  void log(dynamic val) {
    if(model.log) print("[StorageHelper]"); print(val);
  }

  /// Reads a value given the [key]
  Future<String> read(String key) async => await storage.read(
      key: key
  );

  /// Write [value] inside [key]
  Future<void> write(String key, String value) async => await storage.write(
      key: key,
      value: value
  );

  /// Delete [key]
  Future<void> delete(String key) async => await storage.delete(
      key: key
  );

  /// Converts [key] and a [defaultValue] from string to data element
  Future<T> convertEl<T>(String key, [T defaultValue]) async {
    try {
      String val = await read(key) ?? converter.reConvert<T>(defaultValue);

      if(val == null) return null;

      return converter.convert<T>(val);
    } catch(e, stacktrace) {
      print(e);
      print(stacktrace);

      return null;
    }
  }

  /// Insert the value [val] into the element with the key "[key]"
  /// Returns `true` if the operation was successful, otherwise returns `false`
  Future<bool> set<T>(String key, T val) async {
    try {
      if(val != null) {
        await write(key, converter.reConvert<T>(val));

        log("");
        print("\"$key\" = ");
        print(val);
      }else {
        await delete(key);

        log("deleting $key...");
      }

      return true;
    } catch(e, stacktrace) {
      print(e);
      print(stacktrace);
      return false;
    }
  }

  /// Returns the value of the element with the key "[key]" and if it is null it returns [defaultValue]
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