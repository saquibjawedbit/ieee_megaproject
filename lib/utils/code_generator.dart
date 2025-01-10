import '../models/widget_node.dart';

class CodeGenerator {
  static String generate(List<WidgetNode> nodes) {
    StringBuffer code = StringBuffer();
    code.writeln('import \'package:flutter/material.dart\';');
    code.writeln();
    code.writeln('class GeneratedWidget extends StatelessWidget {');
    code.writeln('  const GeneratedWidget({super.key});');
    code.writeln();
    code.writeln('  @override');
    code.writeln('  Widget build(BuildContext context) {');
    code.writeln('    return MaterialApp(');
    code.writeln('      debugShowCheckedModeBanner: false,');
    code.writeln('      theme: ThemeData(useMaterial3: true),');
    code.writeln('      home: MyApp(),');
    code.writeln('    );');
    code.writeln('  }');
    code.writeln('}');

    code.writeln('class MyApp extends StatelessWidget {');
    code.writeln('  const MyApp({super.key});');
    code.writeln(' @override');
    code.writeln('  Widget build(BuildContext context) {');
    code.writeln('    return Scaffold(');
    code.writeln('      body: ${_generateWidgetTree(nodes)},');
    code.writeln('    );');
    code.writeln(' }');
    code.writeln('}');

    return code.toString();
  }

  static String _generateWidgetTree(List<WidgetNode> nodes) {
    if (nodes.isEmpty) return 'Placeholder()';

    return _generateWidget(nodes.first);
  }

  static String _generateWidget(WidgetNode node) {
    switch (node.type) {
      case 'Scaffold':
        return '''Scaffold(
          body: Container(
            color: Colors.white,
            child: ${node.children.isEmpty ? 'const Center(child: Text("Add widgets here"))' : _generateChildren(node.children)},
          ),
        )''';

      case 'Container':
        return '''Container(
          width: ${node.width.value},
          height: ${node.height.value},
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0x${node.color.value.value.toRadixString(16).padLeft(8, '0')}),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ${_generateChildren(node.children)},
        )''';

      case 'Row':
        return '''Row(
          mainAxisAlignment: ${node.mainAxisAlignment.value},
          crossAxisAlignment: ${node.crossAxisAlignment.value},
          children: [${node.children.map(_generateWidget).join(',\n')}],
        )''';

      case 'Column':
        return '''Column(
          mainAxisAlignment: ${node.mainAxisAlignment.value},
          crossAxisAlignment: ${node.crossAxisAlignment.value},
          children: [${node.children.map(_generateWidget).join(',\n')}],
        )''';

      case 'Text':
        return '''Text(
          '${node.content.value}',
          style: TextStyle(
            fontSize: ${node.fontSize.value},
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        )''';

      case 'Center':
        return '''Center(
          child: ${_generateChildren(node.children)},
        )''';

      default:
        return 'const SizedBox()';
    }
  }

  static String _generateChildren(List<WidgetNode> children) {
    if (children.isEmpty) return 'const SizedBox()';
    if (children.length == 1) return _generateWidget(children.first);
    return '''Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ${children.map(_generateWidget).join(',\n')}
      ],
    )''';
  }
}
