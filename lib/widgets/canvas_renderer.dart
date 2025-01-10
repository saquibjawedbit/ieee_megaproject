import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../controllers/hierarchy_controller.dart';
import '../models/widget_node.dart';
import '../utils/code_generator.dart';

class CanvasRenderer extends StatelessWidget {
  final controller = Get.find<HierarchyController>();

  CanvasRenderer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Canvas', style: TextStyle(fontSize: 16)),
            ),
            IconButton(
              icon: const Icon(Icons.code),
              tooltip: 'Generate Code',
              onPressed: () {
                final code = CodeGenerator.generate(controller.nodes);
                Clipboard.setData(ClipboardData(text: code));
                Get.snackbar(
                  'Success',
                  'Code copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
        const Divider(),
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.grey[850]!, width: 12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 9 / 16, // Mobile screen ratio
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.grey[900],
                    child: Obx(() => _buildPreview()),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      color: Colors.grey[850],
      padding: const EdgeInsets.all(16),
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: 0.1,
        maxScale: 2.0,
        child: SizedBox(
          width: 1000,
          height: 2000,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Grid background
              CustomPaint(
                size: const Size(1000, 2000),
                painter: GridPainter(),
              ),
              // Widgets
              ...controller.nodes.map((node) => _renderWidget(node)),
              // Selection overlay
              if (controller.selected.value != null)
                _buildSelectionOverlay(controller.selected.value!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderWidget(WidgetNode node) {
    Widget child;
    switch (node.type) {
      case 'Container':
        child = Container(
          width: node.width.value,
          height: node.height.value,
          decoration: BoxDecoration(
            color: node.color.value,
            border: Border.all(
              color: controller.selected.value?.id == node.id
                  ? Colors.blue
                  : Colors.grey[600]!,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: node.children.isEmpty
              ? null
              : Stack(
                  clipBehavior: Clip.none,
                  children: node.children.map(_renderWidget).toList(),
                ),
        );
        break;

      case 'Text':
        child = Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.selected.value?.id == node.id
                    ? Colors.blue
                    : Colors.transparent,
              ),
            ),
            child: Text(
              node.content.value,
              style: TextStyle(
                color: Colors.white,
                fontSize: node.fontSize.value,
              ),
            ),
          ),
        );
        break;

      case 'Row':
      case 'Column':
        final isRow = node.type == 'Row';
        child = Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.selected.value?.id == node.id
                    ? Colors.blue
                    : Colors.grey[600]!.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isRow
                ? Row(
                    mainAxisAlignment: node.mainAxisAlignment.value,
                    crossAxisAlignment: node.crossAxisAlignment.value,
                    children: node.children.map(_renderWidget).toList(),
                  )
                : Column(
                    mainAxisAlignment: node.mainAxisAlignment.value,
                    crossAxisAlignment: node.crossAxisAlignment.value,
                    children: node.children.map(_renderWidget).toList(),
                  ),
          ),
        );
        break;

      default:
        child = const SizedBox();
    }

    return Positioned(
      left: node.x.value,
      top: node.y.value,
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: GestureDetector(
          onTap: () => controller.selectNode(node),
          onPanUpdate: (details) {
            controller.updateNodePosition(
              node,
              node.x.value + details.delta.dx,
              node.y.value + details.delta.dy,
            );
          },
          child: child,
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay(WidgetNode node) {
    return Positioned(
      left: node.x.value,
      top: node.y.value,
      child: IgnorePointer(
        child: Container(
          width: node.width.value,
          height: node.height.value,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!.withOpacity(0.2)
      ..strokeWidth = 1;

    const spacing = 20.0;
    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
