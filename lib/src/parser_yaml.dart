import 'dart:io';
import 'dart:convert';

String getName(String ymalPath) {
  // Read YAML file
  File file = File(ymalPath);
  String yamlString = file.readAsStringSync();

  // Parse YAML
  Map<String, dynamic> yamlMap = _loadYaml(yamlString);

  // Access data
  String name = yamlMap['name'];

  // Print the name
  print('Name from YAML: $name');
  return name;
}

Map<String, dynamic> _loadYaml(String source) {
  var lines =
      LineSplitter.split(source).where((line) => line.trim().isNotEmpty);
  var result = <String, dynamic>{};
  for (var line in lines) {
    var split = line.split(':');
    if (split.length >= 2) {
      var key = split[0].trim();
      var value = split.sublist(1).join(':').trim();
      result[key] = _parseYamlValue(value);
    }
  }
  return result;
}

dynamic _parseYamlValue(String value) {
  value = value.trim();
  if (value == 'true') {
    return true;
  } else if (value == 'false') {
    return false;
  } else {
    // Attempt to parse as number or leave as string
    try {
      return int.parse(value);
    } catch (_) {
      try {
        return double.parse(value);
      } catch (_) {
        return value;
      }
    }
  }
}
