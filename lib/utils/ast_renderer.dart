import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import '../models/widget_node.dart';

class AstRenderer {
  static Widget renderFromNode(WidgetNode node) {
    final code = _generateWidgetCode(node);
    final ast = parseString(content: code);
    final compilation = ast.unit as CompilationUnit;

    return _renderAst(compilation, node);
  }

  static String _generateWidgetCode(WidgetNode node) {
    return '''
    import 'package:flutter/material.dart';
    
    Widget build() {
      return ${_generateWidgetTree(node)};
    }
    ''';
  }

  static String _generateWidgetTree(WidgetNode node) {
    switch (node.type) {
      case 'Container':
        return '''Container(
          width: ${node.width.value},
          height: ${node.height.value},
          decoration: BoxDecoration(
            color: Color(0x${node.color.value.value.toRadixString(16).padLeft(8, '0')}),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ${node.children.isEmpty ? 'null' : _generateWidgetTree(node.children.first)},
        )''';

      case 'Text':
        return '''Text(
          '${node.content.value}',
          style: TextStyle(
            fontSize: ${node.fontSize.value},
            color: Color(0x${node.color.value.value.toRadixString(16).padLeft(8, '0')}),
            fontWeight: ${_getFontWeightString(node.fontWeight.value)},
          ),
        )''';

      case 'Row':
        return '''Row(
          mainAxisAlignment: ${node.mainAxisAlignment.value},
          crossAxisAlignment: ${node.crossAxisAlignment.value},
          children: [
            ${node.children.map(_generateWidgetTree).join(',\n')}
          ],
        )''';

      case 'Column':
        return '''Column(
          mainAxisAlignment: ${node.mainAxisAlignment.value},
          crossAxisAlignment: ${node.crossAxisAlignment.value},
          children: [
            ${node.children.map(_generateWidgetTree).join(',\n')}
          ],
        )''';

      default:
        return 'Container()';
    }
  }

  static String _getFontWeightString(FontWeight weight) {
    switch (weight) {
      case FontWeight.w100:
        return 'FontWeight.w100';
      case FontWeight.w200:
        return 'FontWeight.w200';
      case FontWeight.w300:
        return 'FontWeight.w300';
      case FontWeight.w400:
        return 'FontWeight.w400';
      case FontWeight.w500:
        return 'FontWeight.w500';
      case FontWeight.w600:
        return 'FontWeight.w600';
      case FontWeight.w700:
        return 'FontWeight.w700';
      case FontWeight.w800:
        return 'FontWeight.w800';
      case FontWeight.w900:
        return 'FontWeight.w900';
      case FontWeight.bold:
        return 'FontWeight.bold';
      case FontWeight.normal:
      default:
        return 'FontWeight.normal';
    }
  }

  static Widget _renderAst(CompilationUnit unit, WidgetNode node) {
    try {
      switch (node.type) {
        // case 'Scaffold':
        //   return Scaffold(
        //     appBar: AppBar(
        //       title: const Text('Preview'),
        //     ),
        //     body: Container(
        //       color: Colors.white,
        //       child: node.children.isEmpty
        //           ? const Center(child: Text('Add widgets here'))
        //           : Stack(
        //               fit: StackFit.expand,
        //               children: node.children
        //                   .map((child) => _renderAst(unit, child))
        //                   .toList(),
        //             ),
        //     ),
        //   );

        case 'Container':
          return Container(
            width: node.width.value,
            height: node.height.value,
            decoration: BoxDecoration(
              color: node.color.value,
              borderRadius: BorderRadius.circular(8),
            ),
            child: node.children.isEmpty
                ? null
                : _renderAst(unit, node.children.first),
          );

        case 'Text':
          return Text(
            node.content.value,
            style: TextStyle(
              fontSize: node.fontSize.value,
              color: node.color.value, // Use the color property
              fontWeight: node.fontWeight.value, // Add this line
            ),
          );

        case 'Row':
          return Row(
            mainAxisAlignment: node.mainAxisAlignment.value,
            crossAxisAlignment: node.crossAxisAlignment.value,
            children:
                node.children.map((child) => _renderAst(unit, child)).toList(),
          );

        case 'Column':
          return Column(
            mainAxisAlignment: node.mainAxisAlignment.value,
            crossAxisAlignment: node.crossAxisAlignment.value,
            children:
                node.children.map((child) => _renderAst(unit, child)).toList(),
          );

        default:
          return const SizedBox();
      }
    } catch (e) {
      debugPrint('Error rendering widget: $e');
      return const SizedBox();
    }
  }
}
