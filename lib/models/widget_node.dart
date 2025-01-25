import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WidgetNode {
  String id;
  String name;
  String type;
  RxList<WidgetNode> children = RxList<WidgetNode>([]);
  RxBool isExpanded = true.obs;
  WidgetNode? parent;

  // Widget properties
  final RxDouble x = 0.0.obs;
  final RxDouble y = 0.0.obs;
  final RxDouble width = 100.0.obs;
  final RxDouble height = 100.0.obs;
  final Rx<Color> color = Colors.blue.withOpacity(0.3).obs;
  final RxString content = 'Text Widget'.obs;
  final RxDouble fontSize = 14.0.obs;
  final Rx<FontWeight> fontWeight = FontWeight.normal.obs;
  final Rx<MainAxisAlignment> mainAxisAlignment = MainAxisAlignment.start.obs;
  final Rx<CrossAxisAlignment> crossAxisAlignment =
      CrossAxisAlignment.center.obs;
  final RxDouble borderRadius = 8.0.obs; // Add this property
  final Rx<Color> textColor = Colors.white.obs; // Add this property
  final Rx<EdgeInsets> padding =
      Rx<EdgeInsets>(const EdgeInsets.all(8.0)); // Add this property

  WidgetNode({
    required this.id,
    required this.name,
    required this.type,
    this.parent,
  }) {
    children = <WidgetNode>[].obs;
    isExpanded = true.obs;
  }

  WidgetNode copyWith({
    String? id,
    String? name,
    String? type,
    List<WidgetNode>? children,
    WidgetNode? parent,
  }) {
    return WidgetNode(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parent: parent ?? this.parent,
    );
  }
}
