import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import '../models/widget_node.dart';

class HierarchyController extends GetxController {
  final nodes = <WidgetNode>[].obs;
  final selected = Rx<WidgetNode?>(null);
  final _uuid = const Uuid();

  final availableWidgets = [
    'Container',
    'Text',
    'Button',
    'TextField',
    'Image',
    'Row',
    'Column',
  ];

  // Grid settings for snap positioning
  final double gridSize = 10.0;
  final RxInt lastX = 20.obs;
  final RxInt lastY = 20.obs;

  // Add snap to grid toggle
  final RxBool shouldSnapToGrid = false.obs;

  void addNode(String type, {WidgetNode? parent}) {
    final newNode = WidgetNode(
      id: _uuid.v4(),
      name: type,
      type: type,
      parent: parent,
    );

    // Calculate next position in grid
    _calculateNextPosition(type);
    newNode.x.value = lastX.value.toDouble();
    newNode.y.value = lastY.value.toDouble();

    // Set default properties based on widget type
    switch (type) {
      case 'Container':
        newNode.width.value = 200;
        newNode.height.value = 200;
        newNode.color.value = const Color(0xFF2196F3).withOpacity(0.3);
        newNode.borderRadius.value = 8.0;
        break;

      case 'Text':
        newNode.content.value = 'New Text';
        newNode.fontSize.value = 16;
        newNode.color.value = Colors.black87;
        newNode.width.value = 100;
        newNode.height.value = 40;
        break;

      case 'Button':
        newNode.content.value = 'Button';
        newNode.width.value = 120;
        newNode.height.value = 40;
        newNode.color.value = Colors.blue;
        newNode.textColor.value = Colors.white; // Set default text color
        newNode.borderRadius.value = 4.0;
        break;

      case 'TextField':
        newNode.width.value = 200;
        newNode.height.value = 50;
        newNode.content.value = 'Hint text...';
        break;

      case 'Image':
        newNode.width.value = 150;
        newNode.height.value = 150;
        newNode.content.value = 'assets/placeholder.png';
        newNode.borderRadius.value = 8.0;
        break;

      case 'Row':
      case 'Column':
        newNode.width.value = 300;
        newNode.height.value = 100;
        break;
    }

    if (parent == null) {
      nodes.add(newNode);
    } else {
      parent.children.add(newNode);
      parent.children.refresh();
    }
    nodes.refresh();
  }

  void _calculateNextPosition(String type) {
    // Update position for next widget
    lastX.value += 20;
    if (lastX.value > 300) {
      // Max width threshold
      lastX.value = 20;
      lastY.value += 50; // Move to next row
    }
    if (lastY.value > 500) {
      // Max height threshold
      lastX.value = 20;
      lastY.value = 20; // Reset to top
    }
  }

  void snapToGrid(WidgetNode node) {
    node.x.value = (node.x.value / gridSize).round() * gridSize;
    node.y.value = (node.y.value / gridSize).round() * gridSize;
    nodes.refresh();
  }

  void addChildToSelected(String type) {
    if (selected.value != null) {
      final newNode = WidgetNode(
        id: _uuid.v4(),
        name: type,
        type: type,
        parent: selected.value,
      );

      selected.value!.children.add(newNode);
      selected.value!.children.refresh();
      nodes.refresh();
    }
  }

  bool canAddChildren(String type) {
    return [
      'Scaffold',
      'AppBar',
      'Container',
      'Row',
      'Column',
      'Card',
      'ListView',
      'Center',
      'Padding'
    ].contains(type);
  }

  void deleteNode(String id) {
    if (selected.value?.id == id) {
      selected.value = null;
    }

    nodes.removeWhere((node) => node.id == id);
    for (var node in nodes) {
      node.children.removeWhere((child) => child.id == id);
      node.children.refresh();
    }
    nodes.refresh();
  }

  void selectNode(WidgetNode node) {
    if (selected.value?.id == node.id) {
      selected.value = null;
    } else {
      selected.value = node;
    }
    nodes.refresh();
  }

  void toggleNodeExpansion(WidgetNode node) {
    node.isExpanded.value = !node.isExpanded.value;
    nodes.refresh();
  }

  void updateNodePosition(WidgetNode node, double x, double y) {
    // Ensure positions are not negative
    x = x.clamp(0, double.infinity);
    y = y.clamp(0, double.infinity);

    // Snap to grid if enabled
    if (shouldSnapToGrid.value) {
      x = (x / gridSize).round() * gridSize;
      y = (y / gridSize).round() * gridSize;
    }

    node.x.value = x;
    node.y.value = y;
    nodes.refresh();
  }

  void toggleSnapToGrid() {
    shouldSnapToGrid.toggle();
    if (shouldSnapToGrid.value && selected.value != null) {
      snapToGrid(selected.value!);
    }
  }

  void alignSelected(Alignment alignment) {
    if (selected.value == null) return;

    final node = selected.value!;
    double x = node.x.value;

    switch (alignment) {
      case Alignment.centerLeft:
        x = 0;
        break;
      case Alignment.center:
        x = 400 - (node.width.value / 2); // Assuming canvas width is 800
        break;
      case Alignment.centerRight:
        x = 800 - node.width.value; // Assuming canvas width is 800
        break;
      default:
        break;
    }

    updateNodePosition(node, x, node.y.value);
  }

  void updateNodeSize(WidgetNode node, double width, double height) {
    node.width.value = width;
    node.height.value = height;
    nodes.refresh();
  }

  void updateNodeColor(WidgetNode node, Color color) {
    node.color.value = color;
    nodes.refresh();
  }

  void updateTextContent(WidgetNode node, String content) {
    node.content.value = content;
    nodes.refresh();
  }

  void updateFontSize(WidgetNode node, double size) {
    node.fontSize.value = size;
    nodes.refresh();
  }

  void updateFontWeight(WidgetNode node, FontWeight weight) {
    node.fontWeight.value = weight;
    nodes.refresh();
  }

  void updateAlignment(
    WidgetNode node, {
    MainAxisAlignment? main,
    CrossAxisAlignment? cross,
  }) {
    if (main != null) node.mainAxisAlignment.value = main;
    if (cross != null) node.crossAxisAlignment.value = cross;
    nodes.refresh();
  }

  void updateBorderRadius(WidgetNode node, double radius) {
    node.borderRadius.value = radius;
    nodes.refresh();
  }

  Future<void> pickAndUpdateImage(WidgetNode node) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        node.content.value = url;
        nodes.refresh();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void updateTextColor(WidgetNode node, Color color) {
    node.textColor.value = color;
    nodes.refresh();
  }
}
