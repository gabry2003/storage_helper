import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:storage_helper/storage_helper_converter.dart';
import 'package:storage_helper_gen/storage_helper_model.dart';

/// Parent class of all generated helpers
abstract class StorageHelperBase {
  /// StorageHelper's model
  final StorageHelperModel model;
  /// FlutterSecureStorage's object
  final FlutterSecureStorage storage = new FlutterSecureStorage();
  /// StorageHelperConverter's object
  StorageHelperConverter? converter;

  /// Constructor, takes [model] as a parameter
  /// It initialize [converter]
  StorageHelperBase(this.model) {
    converter = new StorageHelperConverter(model);
  }

  /// Print [logs] on the screen if [model.log] is active
  void log(List<dynamic> logs) {
    if(model.log ?? false) {
      print("[StorageHelper]");
      for(dynamic val in logs) print(val);
    }
  }

  /// Reads a value given the [key]
  Future<String?> read(String key) async => await storage.read(
      key: key
  );

  /// Reads all values
  Future<Map<String, String>> readAll() async => await storage.readAll();

  /// Write [value] inside [key]
  Future<void> write(String key, String? value) async => await storage.write(
      key: key,
      value: value
  );

  /// Delete [key]
  Future<void> delete(String key) async => await storage.delete(
      key: key
  );

  /// Converts [key] and a [defaultValue] from string to data element
  Future<T> convertEl<T>(String key, {T? defaultValue, String? dateFormat, Duration? duration}) async {
    try {
	  if((duration?.inMilliseconds ?? 0) > 0) {	// If there is a duration
		DateTime? creationDateTime = get<DateTime?>(key + "MomentCreation");
		
		if(DateTime.now().differences(creationDateTime as DateTime).inMilliseconds >= duration.inMilliseconds) {	// Se è passato il tempo di scadenza dell'elemento
			await delete(key);	// Elimino l'elemento
			return null;
		}
	  }
	  
      String? val = await read(key) ?? converter?.reConvert<T>(defaultValue as T, dateFormat: dateFormat);

      if(val == null) return null as T;

      return converter?.convert<T>(val) as T;
    } catch(e, stacktrace) {
      print(e);
      print(stacktrace);

      return defaultValue as T;
    }
  }

  /// Insert the value [val] into the element with the key "[key]"
  /// Returns `true` if the operation was successful, otherwise returns `false`
  Future<bool> set<T>(String key, T? val, {String? dateFormat, Duration? duration}) async {
    try {
      if(val != null) {
        await write(key, converter?.reConvert<T>(val, dateFormat: dateFormat));
		
		if((duration?.inMilliseconds ?? 0) > 0) {	// If there is a duration
			await set<DateTime>(key + "MomentCreation", DateTime.now());
	    }

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
  Future<T> get<T>(String key, {T? defaultValue, String? dateFormat, Duration? duration}) async {
    try {
      T val = await convertEl<T>(key, defaultValue: defaultValue, dateFormat: dateFormat, duration: duration);

      log(["$key = ${val.toString()}"]);

      return val;
    } catch(e, stacktrace) {
      print(e);
      print(stacktrace);

      return defaultValue as T;
    }
  }

  /// toMap get, it is required
  Future<Map> get toMap;

  /// init method, it is required
  Future<void> init();

  /// delete all method, it is required
  Future<void> deleteAll();
}