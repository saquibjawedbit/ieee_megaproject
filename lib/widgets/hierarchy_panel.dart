import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/hierarchy_controller.dart';
import '../models/widget_node.dart';

class HierarchyPanel extends StatelessWidget {
  final controller = Get.put(HierarchyController());

  HierarchyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Hierarchy', style: TextStyle(fontSize: 16)),
        ),
        const Divider(),
        Row(
          children: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.add),
              itemBuilder: (context) => controller.availableWidgets
                  .map((type) => PopupMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onSelected: (type) => controller.addNode(type),
            ),
            Obx(() => controller.selected.value != null
                ? PopupMenuButton<String>(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Add child',
                    itemBuilder: (context) => controller.availableWidgets
                        .map((type) => PopupMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onSelected: (type) => controller.addChildToSelected(type),
                  )
                : const SizedBox()),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                if (controller.selected.value != null) {
                  controller.deleteNode(controller.selected.value!.id);
                }
              },
            ),
          ],
        ),
        Expanded(
          child: Obx(
            () => ListView.builder(
              itemCount: controller.nodes.length,
              itemBuilder: (context, index) {
                return _buildNodeTree(controller.nodes[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNodeTree(WidgetNode node, [int depth = 0]) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: depth * 20.0),
              child: Row(
                children: [
                  if (node.children.isNotEmpty)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => controller.toggleNodeExpansion(node),
                        child: Obx(() => Icon(
                              node.isExpanded.value
                                  ? Icons.arrow_drop_down
                                  : Icons.arrow_right,
                              size: 16,
                              color: Colors.grey[400],
                            )),
                      ),
                    ),
                  Expanded(
                    child: Obx(() => HierarchyItem(
                          node: node,
                          onTap: () => controller.selectNode(node),
                          isSelected: controller.selected.value?.id == node.id,
                          canAddChildren: controller.canAddChildren(node.type),
                        )),
                  ),
                ],
              ),
            ),
            if (node.isExpanded.value)
              ...node.children.map((child) => _buildNodeTree(child, depth + 1)),
          ],
        ));
  }
}

class HierarchyItem extends StatefulWidget {
  final WidgetNode node;
  final VoidCallback onTap;
  final bool isSelected;
  final bool canAddChildren;

  const HierarchyItem({
    super.key,
    required this.node,
    required this.onTap,
    required this.isSelected,
    required this.canAddChildren,
  });

  @override
  State<HierarchyItem> createState() => _HierarchyItemState();
}

class _HierarchyItemState extends State<HierarchyItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        height: 28,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Colors.blue.withOpacity(0.2)
              : isHovered
                  ? Colors.grey[800]
                  : null,
          border: Border(
            left: BorderSide(
              color: widget.isSelected
                  ? Colors.blue
                  : isHovered
                      ? Colors.grey[700]!
                      : Colors.transparent,
              width: 2,
            ),
          ),
          // Add gradient effect for selected item
          gradient: widget.isSelected
              ? LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.2),
                    Colors.blue.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                horizontalTitleGap: 8,
                leading: Icon(
                  Icons.widgets,
                  size: 16,
                  // Change icon color for selected item
                  color: widget.isSelected
                      ? Colors.blue[300]
                      : isHovered
                          ? Colors.grey[300]
                          : Colors.grey[500],
                ),
                title: Row(
                  children: [
                    Text(
                      widget.node.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: widget.isSelected
                            ? Colors.blue[300]
                            : isHovered
                                ? Colors.white
                                : Colors.grey[300],
                      ),
                    ),
                    if (widget.canAddChildren)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.schema,
                          size: 12,
                          color: widget.isSelected
                              ? Colors.blue[300]
                              : Colors.grey[400],
                        ),
                      ),
                  ],
                ),
                selected: widget.isSelected,
                onTap: widget.onTap,
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
