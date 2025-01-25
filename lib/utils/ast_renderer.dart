import 'package:flutter/material.dart';
import '../models/widget_node.dart';

class AstRenderer {
  static Widget renderFromNode(WidgetNode node) {
    return _renderWidget(node);
  }

  static Widget renderMultipleNodes(List<WidgetNode> nodes) {
    return Stack(
      children: nodes.map((node) => _renderPositionedWidget(node)).toList(),
    );
  }

  static Widget _renderPositionedWidget(WidgetNode node) {
    return Positioned(
      left: node.x.value,
      top: node.y.value,
      child: _renderWidget(node),
    );
  }

  static Widget _renderWidget(WidgetNode node) {
    try {
      switch (node.type) {
        case 'Button':
          return Padding(
            padding: node.padding.value,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: node.color.value,
                foregroundColor: node.textColor.value, // Add this line
                minimumSize: Size(node.width.value, node.height.value),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(node.borderRadius.value),
                ),
              ),
              child: Text(
                node.content.value,
                style: TextStyle(
                  fontSize: node.fontSize.value,
                  fontWeight: node.fontWeight.value,
                ),
              ),
            ),
          );

        case 'TextField':
          return SizedBox(
            width: node.width.value,
            height: node.height.value,
            child: TextField(
              decoration: InputDecoration(
                hintText: node.content.value,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );

        case 'Image':
          return Container(
            width: node.width.value,
            height: node.height.value,
            decoration: BoxDecoration(
              image: node.content.value.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(node.content.value),
                      fit: BoxFit.cover,
                    )
                  : null,
              borderRadius: BorderRadius.circular(node.borderRadius.value),
            ),
          );

        case 'Container':
          return Container(
            width: node.width.value,
            height: node.height.value,
            decoration: BoxDecoration(
              color: node.color.value,
              borderRadius: BorderRadius.circular(node.borderRadius.value),
            ),
            child: node.children.isEmpty
                ? null
                : _renderWidget(node.children.first),
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
                node.children.map((child) => _renderWidget(child)).toList(),
          );

        case 'Column':
          return Column(
            mainAxisAlignment: node.mainAxisAlignment.value,
            crossAxisAlignment: node.crossAxisAlignment.value,
            children:
                node.children.map((child) => _renderWidget(child)).toList(),
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
