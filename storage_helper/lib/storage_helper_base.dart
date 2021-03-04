import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:storage_helper/storage_helper_converter.dart';
import 'package:storage_helper_gen/src/storage_helper_model.dart';

/// Parent class of all generated helpers
class StorageHelperBase {
  /// StorageHelper's model
  final StorageHelperModel model;
  /// FlutterSecureStorage's object
  final FlutterSecureStorage storage = new FlutterSecureStorage();
  /// StorageHelperConverter's object
  StorageHelperConverter converter;

  /// Constructor, takes [model] as a parameter
  /// It initialize [converter]
  StorageHelperBase(this.model) {
    converter = new StorageHelperConverter(model);
  }

  /// Print [logs] on the screen if [model.log] is active
  void log(List<dynamic> logs) {
    if(model.log) {
      print("[StorageHelper]");
      for(dynamic val in logs) print(val);
    }
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

        log(["$key = ${val.toString()}"]);
      }else {
        await delete(key);

        log(["deleting $key..."]);
      }

      return true;
    } catch(e, stacktrace) {
      print(e);
      print(stacktrace);
      return false;
    }
  }

  /// Returns the value of the element with the key [key] and if it is null it returns [defaultValue]
  Future<T> get<T>(String key, [T defaultValue]) async {
    try {
      log(["getting \"$key\"..."]);

      T val = await convertEl<T>(key, defaultValue);

      log(["$key = ${val.toString()}"]);

      return val;
    } catch(e, stacktrace) {
      print(e);
      print(stacktrace);

      return null;
    }
  }
}