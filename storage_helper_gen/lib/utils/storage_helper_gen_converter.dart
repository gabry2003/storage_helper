// ignore: import_of_legacy_library_into_null_safe
import 'package:analyzer/dart/constant/value.dart';
import 'package:storage_helper_gen/exceptions/storage_helper_exception.dart';
import 'package:storage_helper_gen/storage_helper_category.dart';
import 'package:storage_helper_gen/storage_helper_element.dart';
import 'package:storage_helper_gen/utils/storage_helper_log.dart';
import 'package:storage_helper_gen/storage_helper_model.dart';
import 'package:storage_helper_gen/storage_helper_type.dart';

/// This is to convert from `DartObject` to the necessary types so that we can interpret the model
class StorageHelperGenConverter {
  /// Takes the object "[obj]" as a parameter and the name of the attribute to read the value of
  /// Return the attribute as a String
  String? getStringValue(DartObject? obj, String name) => obj?.getField(name)?.toStringValue();
  /// Takes the object "[obj]" as a parameter and the name of the attribute to read the value of
  /// Return the attribute as a bool
  bool? getBoolValue(DartObject? obj, String name) => obj?.getField(name)?.toBoolValue() ?? false;
  /// Takes the object "[obj]" as a parameter and the name of the attribute to read the value of
  /// Return the attribute as int
  int? getIntValue(DartObject? obj, String name) => obj?.getField(name)?.toIntValue();
  /// Takes the object "[obj]" as a parameter and the name of the attribute to read the value of
  /// Return the attribute as a double
  double? getDoubleValue(DartObject? obj, String name) => obj?.getField(name)?.toDoubleValue();
  /// Takes the object "[obj]" as a parameter and the name of the attribute to read the value of
  /// Return the attribute as List <DartObject>
  /// Of this list obviously all the elements must be converted with the `getList` method
  List<DartObject?>? getListValue(DartObject? obj, String name) => obj?.getField(name)?.toListValue();
  /// Takes the object "[obj]" as a parameter and the name of the attribute to read the value of
  /// Return the attribute as Map <DartObject, DartObject>
  /// Of this map obviously the keys and values must be converted with the `getMap` method
  Map<DartObject?, DartObject?>? getMapValue(DartObject? obj, String name) => obj?.getField(name)?.toMapValue();

  /// Given a list of `DartObject` returns a list of` T` by converting each element
  List<T?>? getList<T>(List<DartObject?>? listObject) => listObject?.map(
          (DartObject? obj) => convert<T>(obj)
  ).toList();

  /// Given a `Map<DartObject, DartObject>` returns a `Map<K, V>` by converting each keys and each values
  Map<K?, V?>? getMap<K, V>(Map<DartObject?, DartObject?>? mapObject) {
    Map<K?, V?> map = {};

    List<DartObject?>? origKeys = mapObject?.keys.toList();
    List<K?>? keys = getList<K?>(origKeys);

    for(int i = 0;i < (keys?.length ?? 0);i++) {  // For each key
      map[keys![i]] = convert<V>(mapObject![origKeys![i]]!);  //  Convert key and convert value
    }

    return map;
  }

  /// Dato [obj] ritorna un oggetto di tipo `T`
  T? convert<T>(DartObject? obj) {
    try {
      // Based on the type of the item to return
      switch(T) {
        case String:
          // If I need to return a String then I just convert the object to a String
          return obj?.toStringValue() as T;
        case bool:
          // If I need to return a boolean then I just convert the object to a bool
          return (obj?.toBoolValue() ?? false) as T;
        case int:
          // If I need to return a int then I simply convert the object to a int
          return obj?.toIntValue() as T;
        case double:
          // If I need to return a double then I simply convert the object to a double
          return obj?.toDoubleValue() as T;
        case StorageHelperCategory:
          // If I have to return a category of type `StorageHelperCategory` I create a new StorageHelperCategory object and pass all the parameters to the constructor taking the attributes of the object
          return StorageHelperCategory(
            parent: getStringValue(obj, "parent"),
            key: getStringValue(obj, "key"),
            description: getList<String>(getListValue(obj, "description")),
            elements: getList<StorageHelperElement>(getListValue(obj, "elements")) as List<StorageHelperElement>,
            addSource: getStringValue(obj, "addSource")
          ) as T;
        case StorageHelperElement:
          // If I have to return an element of type `StorageHelperElement` I create a new StorageHelperElement object and pass all the parameters to the constructor taking the attributes of the object
          String key = getStringValue(obj, "key") as String;
          String? staticKey = getStringValue(obj, "staticKey");
          String? getKey = getStringValue(obj, "getKey");
          List<String?>? concateneKeys = getList<String>(getListValue(obj, "concateneKeys"));
          List<String?>? description = getList<String>(getListValue(obj, "description"));
          bool? onInit = getBoolValue(obj, "onInit");
          bool? defaultIsCode = getBoolValue(obj, "defaultIsCode");

          dynamic? type;
          dynamic defaultValue;

          String? typeToString = obj?.getField("type")?.toString();
          String? defaultValueToString = obj?.getField("defaultValue")?.toString();

          if(typeToString?.contains("StorageHelperType") ?? false) {  // If it is a StorageHelperType
            // I extract the enum index from the toString and access the value from the enum from here
            try {
              List<String?>? split = typeToString?.split("index = ");
              String? index = split?[1]?.replaceAll("int (", "").replaceAll(")", "");
              type = StorageHelperType.values[int?.tryParse(index as String) as int];
            } catch(e) {
              try {
                List<String?>? split = typeToString?.split("int = ");
                String? index = split?[1]?.replaceAll("int (", "").replaceAll(")", "");
                type = StorageHelperType.values[int?.tryParse(index as String) as int];
              } catch(err, stacktrace) {
                print(err);
                print(stacktrace);

                throw new StorageHelperException("Unable to identify StorageHelperElement's type");
              }
            }

            try {
              if(defaultValueToString?.contains("bool") ?? false) { // Se è un booleano
                defaultValue = defaultValueToString?.substring(0, defaultValueToString.length - 1).replaceAll("bool (", "") == "true";
              }else if(defaultValueToString?.contains("int") ?? false) {  // Se è un intero
                defaultValue = int.tryParse(defaultValueToString?.substring(0, defaultValueToString.length - 1).replaceAll("int (", "") as String);
              }else if(defaultValueToString?.contains("double") ?? false) {  // Se è un double
                defaultValue = double.tryParse(defaultValueToString?.substring(0, defaultValueToString.length - 1).replaceAll("int (", "") as String);
              }else if(defaultValueToString?.contains("DateTime") ?? false) {  // Se è un DateTime
                defaultValue = DateTime.parse(defaultValueToString?.substring(0, defaultValueToString.length - 1).replaceAll("DateTime (", "") as String);
              }else if(defaultValueToString?.contains("String") ?? false) {  // Se è un String
                defaultValue = defaultValueToString?.substring(0, defaultValueToString.length - 1).replaceAll("String (", "");
                defaultValue = defaultValue.substring(0, defaultValue.length - 1);  // RImuovo l'ultimo carattere (apice)
                defaultValue = defaultValue.substring(1); // Rimuovo il primo carattere (apice)
              }
            } catch(e) {
              throw new StorageHelperException("Unable to get default value of element with key \"§key\§");
            }
          }else {
            type = getStringValue(obj, "type");

            defaultValue = getStringValue(obj, "defaultValue");
          }

          if(type == null) throw new StorageHelperException("Unable to get type of element with key \"§key\§");

          StorageHelperElement element;
          if(type is StorageHelperType) {
            element = StorageHelperElement<StorageHelperType>(
                key: key,
                staticKey: staticKey,
                getKey: getKey,
                concateneKeys: concateneKeys,
                type: type,
                onInit: onInit,
                description: description,
                defaultValue: defaultValue,
                defaultIsCode: defaultIsCode
            );
          }else {
            element = StorageHelperElement<String>(
                key: key,
                staticKey: staticKey,
                getKey: getKey,
                concateneKeys: concateneKeys,
                type: type,
                onInit: onInit,
                description: description,
                defaultValue: defaultValue,
                defaultIsCode: defaultIsCode
            );
          }

          return element as T;
        case StorageHelperModel:
          // If I have to return a model of type `StorageHelperModel` I create a new StorageHelperModel object and pass all the parameters to the constructor taking the attributes of the object
          StorageHelperModel model = StorageHelperModel(
              categories: getList<StorageHelperCategory>(getListValue(obj, "categories")) as List<StorageHelperCategory>,
              log: getBoolValue(obj, "log"),
              dateFormat: getStringValue(obj, "dateFormat")
          );
          
          storageHelperLog("Model successfully converterd!");
          
          return model as T;
        default:
          return null;
      }
    } catch(e, stacktrace) {
      print(e);
      print(stacktrace);
      return null;
    }
  }
}