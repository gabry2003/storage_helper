import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:storage_helper_gen/storage_helper_category.dart';
import 'package:storage_helper_gen/storage_helper_custom_type.dart';
import 'package:storage_helper_gen/storage_helper_element.dart';
import 'package:storage_helper_gen/storage_helper_model.dart';
import 'package:storage_helper_gen/storage_helper_type.dart';

class StorageHelperGenConverter {
  void log(String msg) {
    print(DateTime.now().toString());
    print("[STORAGE_HELPER_GENERATOR] $msg");
  }

  String getStringValue(DartObject obj, String name) => obj.getField(name).toStringValue();
  bool getBoolValue(DartObject obj, String name) => obj.getField(name).toBoolValue() ?? false;
  int getIntValue(DartObject obj, String name) => obj.getField(name).toIntValue();
  double getDoubleValue(DartObject obj, String name) => obj.getField(name).toDoubleValue();
  List<DartObject> getListValue(DartObject obj, String name) => obj.getField(name).toListValue();
  Map<DartObject,DartObject> getMapValue(DartObject obj, String name) => obj.getField(name).toMapValue();
  ExecutableElement getFunctionValue(DartObject obj, String name) => obj.getField(name).toFunctionValue();

  T convert<T>(DartObject obj) {
    log("Convert from:");
    print(T);

    try {
      switch(T) {
        case String:
          return obj.toStringValue() as T;
        case bool:
          return (obj.toBoolValue() ?? false) as T;
        case int:
          return obj.toIntValue() as T;
        case double:
          return obj.toDoubleValue() as T;
        case StorageHelperCategory:
          return StorageHelperCategory(
            key: getStringValue(obj, "key"),
            description: getList<String>(getListValue(obj, "description")),
            elements: getList<StorageHelperElement>(getListValue(obj, "elements")),
            addSource: getStringValue(obj, "addSource")
          ) as T;
        case StorageHelperElement:
          String key = getStringValue(obj, "key");

          dynamic type;
          dynamic defaultValue;

          String typeToString = obj.getField("type").toString();
          String defaultValueToString = obj.getField("defaultValue").toString();

          if(typeToString.contains("StorageHelperType")) {  // Se è un tipo di StorageHelper
            // Estraggo l'indice dell'enum dal toString e accedo al valore dall'enum da qui
            type = StorageHelperType.values[int.tryParse(typeToString.split("index = ")[1].replaceAll("int (", "").replaceAll(")", ""))];
          }else {
            type = getStringValue(obj, "type");
          }

          try {
            if(defaultValueToString.contains("bool")) { // Se è un booleano
              defaultValue = defaultValueToString.substring(0, defaultValueToString.length - 1).replaceAll("bool (", "") == "true";
            }else if(defaultValueToString.contains("int")) {  // Se è un intero
              defaultValue = int.tryParse(defaultValueToString.substring(0, defaultValueToString.length - 1).replaceAll("int (", ""));
            }else if(defaultValueToString.contains("double")) {  // Se è un double
              defaultValue = double.tryParse(defaultValueToString.substring(0, defaultValueToString.length - 1).replaceAll("int (", ""));
            }else if(defaultValueToString.contains("DateTime")) {  // Se è un DateTime
              defaultValue = DateTime.parse(defaultValueToString.substring(0, defaultValueToString.length - 1).replaceAll("DateTime (", ""));
            }else if(defaultValueToString.contains("String")) {  // Se è un String
              defaultValue = defaultValueToString.substring(0, defaultValueToString.length - 1).replaceAll("String (", "");
            }
          } catch(e) {
            log("Impossibile prendere il valore di defaullt dell'elemento \"$key\"");
          }

          return StorageHelperElement(
            key: key,
            staticKey: getStringValue(obj, "staticKey"),
            concateneKeys: getList<String>(getListValue(obj, "concateneKeys")),
            type: type,
            onInit: getBoolValue(obj, "onInit"),
            description: getList<String>(getListValue(obj, "description")),
            defaultValue: defaultValue,
          ) as T;
        default:
          return null;
      }
    } catch(e) {
      return null;
    }
  }

  List<T> getList<T>(List<DartObject> listObject) => listObject?.map(
          (DartObject obj) => convert<T>(obj)
  )?.toList();

  Map<K, V> getMap<K, V>(Map<DartObject, DartObject> mapObject) {
    Map<K, V> map = {};

    List<DartObject> origKeys = mapObject.keys.toList();
    List<K> keys = getList<K>(origKeys);

    for(int i = 0;i < keys.length;i++) {  // Per ogni chiave
      map[keys[i]] = convert<V>(mapObject[origKeys[i]]);  // Converto la chiave e converto il valore
    }

    return map;
  }
}