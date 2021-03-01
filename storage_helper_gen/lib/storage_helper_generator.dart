import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:storage_helper_gen/storage_helper_builder.dart';
import 'package:storage_helper_gen/storage_helper_custom_type.dart';
import 'package:storage_helper_gen/storage_helper_element.dart';
import 'package:storage_helper_gen/storage_helper_model.dart';

class StorageHelperGenerator extends GeneratorForAnnotation<StorageHelperBuilder> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    print("[StorageHelperGenerator] start...");
    print("[StorageHelperGenerator] element:");
    print(element);

    String code = """class StorageHelper {""";
    String getSet = "\n";
    String statics = "";
    String attributes = "";
    String init = "\nFuture<void> init() async {";

    if(element is! StorageHelperBuilder) {
      throw InvalidGenerationSourceError("Sorgente non valida!");
    }

    StorageHelperModel model = annotation.read('model').objectValue as StorageHelperModel;
    List<StorageHelperElement> elementi = model.elements;
    Map<String, StorageHelperCustomType> customTypes = model.customTypes;

    for(StorageHelperElement elemento in elementi) {
      print("[StorageHelperGenerator] Add element:");
      print(elemento.toMap());

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