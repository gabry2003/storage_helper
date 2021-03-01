import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:storage_helper/storage_helper_builder.dart';
import 'package:storage_helper/storage_helper_custom_type.dart';
import 'package:storage_helper/storage_helper_element.dart';

class StorageHelperGenerator extends GeneratorForAnnotation<StorageHelperBuilder> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    print("element is $element");

    String code = """class StorageHelper {""";
    String getSet = "\n";
    String statics = "";
    String attributes = "";
    String init = "\nFuture<void> init() async {";

    if(element is! StorageHelperBuilder) {
      throw InvalidGenerationSourceError("Sorgente non valida!");
    }

    List<StorageHelperElement> elementi = annotation.read('elements').listValue as List<StorageHelperElement>;
    Map<String, StorageHelperCustomType> customTypes = annotation.read('customTypes').mapValue as Map<String, StorageHelperCustomType>;

    for(StorageHelperElement elemento in elementi) {
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

    code += init;

    code += """
}""";

    return code;
  }
}