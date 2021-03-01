import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:storage_helper_gen/storage_helper_builder.dart';
import 'package:storage_helper_gen/storage_helper_custom_type.dart';
import 'package:storage_helper_gen/storage_helper_element.dart';
import 'package:storage_helper_gen/storage_helper_model.dart';

class StorageHelperGenerator extends GeneratorForAnnotation<StorageHelperBuilder> {
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

  T convert<T>(DartObject obj) {
    switch(T) {
      case String:
        return obj.toStringValue() as T;
      case bool:
        return (obj.toBoolValue() ?? false) as T;
      case int:
        return obj.toIntValue() as T;
      case double:
        return obj.toDoubleValue() as T;
      case StorageHelperElement:
        return StorageHelperElement(
          key: getStringValue(obj, "key"),
          type: getStringValue(obj, "type"),
          onInit: getBoolValue(obj, "onInit"),
          description: getStringValue(obj, "description"),
          defaultValue: getStringValue(obj, "defaultValue"),
        ) as T;
      default:
        return null;
    }
  }

  List<T> getList<T>(List<DartObject> listObject) => listObject.map(
          (DartObject obj) => convert<T>(obj)
  ).toList();

  Map<dynamic, dynamic> getMap<K, V>(Map<DartObject, DartObject> mapObject) {
    Map<dynamic, dynamic> map = {};

    List<DartObject> origKeys = mapObject.keys.toList();
    List<K> keys = getList<K>(origKeys);

    for(int i = 0;i < keys.length;i++) {  // Per ogni chiave
      map[keys[i]] = convert<V>(mapObject[origKeys[i]]);  // Converto la chiave e converto il valore
    }

    return map;
  }

  StorageHelperModel getModel(DartObject obj) => new StorageHelperModel(
    customTypes: getMap<String, StorageHelperCustomType>(getMapValue(obj, "customTypes")),
    elements: getList<StorageHelperElement>(getListValue(obj, "elements")),
    log: getBoolValue(obj, "log"),
    dateFormat: getStringValue(obj, "dateFormat")
  );

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    log("start...");

    String code = """import 'package:flutter/cupertino.dart';
class StorageHelper {""";
    String getSet = "\n";
    String statics = "";
    String attributes = "";
    String init = "\nFuture<void> init() async {";

    StorageHelperModel model = getModel(annotation.read('model').objectValue);

    log("Model:");
    print(model.toMap);

    List<StorageHelperElement> elementi = model.elements;
    Map<String, StorageHelperCustomType> customTypes = model.customTypes;

    for(StorageHelperElement elemento in elementi) {
      print("[StorageHelperGenerator] Add element:");
      print(elemento.toMap);

      String staticName = elemento.key.replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (Match m) => ('_' + m.group(0))).toUpperCase();
      String firstUpper = "${elemento.key.toUpperCase()}${elemento.key.substring(1)}";
      String type;
      String defaultValue;

      if(elemento.type is String) {
        type = "\"${elemento.type}\"";
        defaultValue = customTypes[elemento.key].convert(elemento.defaultValue);
      }else {
        type = elemento.type.toString();
        defaultValue = elemento.defaultValue.toString();
      }

      if(defaultValue != null && defaultValue != "null") defaultValue = "\"$defaultValue\"";

      String getCode = "await get($type, $staticName, $defaultValue);";
      String setCode = "await set($staticName, val);";

      statics += "\n    static const String $staticName = \"${elemento.key}\";";
      if(elemento.onInit) {
        attributes = "\n    dynamic ${elemento.key} = $defaultValue;";
        init += "\n    ${elemento.key} = await get$firstUpper();";
      }else {
        getSet += "\n    async Future<dynamic> get ${elemento.key} async => $getCode";
      }
      getSet += "\n    async Future<dynamic> get$firstUpper() async => $getCode";
      getSet += """\n    async Future<void> set$firstUpper(dynamic val) {
      $setCode
}""";
      getSet += """\n    async Future<void> delete$firstUpper() {
      await set$firstUpper(null);
}""";
    }

    init += "\n    }";

    code += statics;

    code += "\n \n";

    code += attributes;

    code += """
    StorageHelperModel model;
    bool doLog;
    
    StorageHelper({@required this.model, this.doLog=true) : super(
        model: model,
        doLog: doLog
    );""";

    code += getSet;

    code += """
    Future<void> deleteAll() async {
        await storage.deleteAll();
    }
""";

    code += init;

    code += """
}""";

    print("[StorageHelperGenerator] end!");

    return code;
  }
}