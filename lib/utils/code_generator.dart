import 'package:flutter/material.dart';
import '../models/widget_node.dart';

class CodeGenerator {
  static String generateCode(List<WidgetNode> nodes) {
    final buffer = StringBuffer();

    // Add imports
    buffer.writeln("import 'package:flutter/material.dart';");
    buffer.writeln();

    // Generate widget class
    buffer.writeln('class GeneratedWidget extends StatelessWidget {');
    buffer.writeln('  const GeneratedWidget({super.key});');
    buffer.writeln();

    // Generate build method
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln('    return Stack(');
    buffer.writeln('      children: [');

    // Generate positioned widgets
    for (final node in nodes) {
      buffer.writeln(_generatePositionedWidget(node));
    }

    // Close Stack
    buffer.writeln('      ],');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  static String _generatePositionedWidget(WidgetNode node) {
    final buffer = StringBuffer();
    buffer.writeln('        Positioned(');
    buffer.writeln('          left: ${node.x.value},');
    buffer.writeln('          top: ${node.y.value},');
    buffer.writeln('          child: ${_generateWidget(node)},');
    buffer.writeln('        ),');
    return buffer.toString();
  }

  static String _generateWidget(WidgetNode node) {
    switch (node.type) {
      case 'Container':
        return _generateContainer(node);
      case 'Text':
        return _generateText(node);
      case 'Row':
        return _generateRow(node);
      case 'Column':
        return _generateColumn(node);
      case 'Button':
        return _generateButton(node);
      case 'TextField':
        return _generateTextField(node);
      case 'Image':
        return _generateImage(node);
      default:
        return 'const SizedBox()';
    }
  }

  static String _generateContainer(WidgetNode node) {
    return '''Container(
          width: ${node.width.value},
          height: ${node.height.value},
          decoration: BoxDecoration(
            color: Color(0x${node.color.value.value.toRadixString(16).padLeft(8, '0')}),
            borderRadius: BorderRadius.circular(${node.borderRadius.value}),
          ),
          child: ${node.children.isEmpty ? 'null' : _generateWidget(node.children.first)},
        )''';
  }

  static String _generateText(WidgetNode node) {
    return '''Text(
          '${node.content.value}',
          style: TextStyle(
            fontSize: ${node.fontSize.value},
            color: Color(0x${node.color.value.value.toRadixString(16).padLeft(8, '0')}),
            fontWeight: FontWeight.w${node.fontWeight.value.toString().replaceAll('FontWeight.w', '')},
          ),
        )''';
  }

  static String _generateRow(WidgetNode node) {
    return '''Row(
          mainAxisAlignment: ${node.mainAxisAlignment.value},
          crossAxisAlignment: ${node.crossAxisAlignment.value},
          children: [
            ${node.children.map(_generateWidget).join(',\n            ')}
          ],
        )''';
  }

  static String _generateColumn(WidgetNode node) {
    return '''Column(
          mainAxisAlignment: ${node.mainAxisAlignment.value},
          crossAxisAlignment: ${node.crossAxisAlignment.value},
          children: [
            ${node.children.map(_generateWidget).join(',\n            ')}
          ],
        )''';
  }

  static String _generateButton(WidgetNode node) {
    return '''Padding(
          padding: EdgeInsets.only(
            left: ${node.padding.value.left},
            top: ${node.padding.value.top},
            right: ${node.padding.value.right},
            bottom: ${node.padding.value.bottom},
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0x${node.color.value.value.toRadixString(16).padLeft(8, '0')}),
              foregroundColor: Color(0x${node.textColor.value.value.toRadixString(16).padLeft(8, '0')}),
              minimumSize: Size(${node.width.value}, ${node.height.value}),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(${node.borderRadius.value}),
              ),
            ),
            child: Text('${node.content.value}'),
          ),
        )''';
  }

  static String _generateTextField(WidgetNode node) {
    return '''SizedBox(
          width: ${node.width.value},
          height: ${node.height.value},
          child: TextField(
            decoration: InputDecoration(
              hintText: '${node.content.value}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        )''';
  }

  static String _generateImage(WidgetNode node) {
    return '''Container(
          width: ${node.width.value},
          height: ${node.height.value},
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('${node.content.value}'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(${node.borderRadius.value}),
          ),
        )''';
  }
}
