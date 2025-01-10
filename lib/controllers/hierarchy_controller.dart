import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/widget_node.dart';

class HierarchyController extends GetxController {
  final nodes = <WidgetNode>[].obs;
  final selected = Rx<WidgetNode?>(null);
  final _uuid = const Uuid();

  final availableWidgets = [
    'Scaffold',
    'AppBar',
    'Container',
    'Row',
    'Column',
    'Text',
    'Button',
    'Card',
    'ListView',
    'Center',
    'Padding',
  ];

  void addNode(String type, {WidgetNode? parent}) {
    final newNode = WidgetNode(
      id: _uuid.v4(),
      name: type,
      type: type,
      parent: parent,
    );

    // Set default sizes based on widget type
    switch (type) {
      case 'Container':
        newNode.width.value = 200;
        newNode.height.value = 200;
        newNode.color.value = const Color.fromARGB(255, 39, 138, 220);
        break;
      case 'Text':
        newNode.content.value = 'New Text';
        newNode.fontSize.value = 16;
        newNode.color.value = const Color.fromARGB(255, 11, 11, 11);
        break;
      case 'Row':
      case 'Column':
        newNode.width.value = 300;
        newNode.height.value = 100;
        break;
    }

    // Set initial position at the center of canvas
    newNode.x.value = 100;
    newNode.y.value = 100;

    if (parent == null) {
      nodes.add(newNode);
    } else {
      final parentIndex = nodes.indexWhere((node) => node.id == parent.id);
      if (parentIndex != -1) {
        nodes[parentIndex].children.add(newNode);
        nodes.refresh();
      }
    }
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
    node.x.value = x;
    node.y.value = y;
    nodes.refresh();
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
}
