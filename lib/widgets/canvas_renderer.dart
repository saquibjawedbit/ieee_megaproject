import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../controllers/hierarchy_controller.dart';
import '../models/widget_node.dart';
import '../utils/code_generator.dart';
import '../utils/ast_renderer.dart';

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
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 9 / 20, // Mobile screen ratio
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      // image: const DecorationImage(
                      //   // image: AssetImage('assets/frame.png'),
                      //   fit: BoxFit.fill,
                      // ),
                    ),
                    child: Obx(
                      () => _buildPreview(),
                    ),
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
      color: Colors.white,
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
    try {
      // Use AST renderer
      child = AstRenderer.renderFromNode(node);
    } catch (e) {
      debugPrint('Error rendering widget: $e');
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
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: controller.selected.value?.id == node.id
                      ? Colors.blue
                      : Colors.transparent,
                ),
              ),
              child: child,
            ),
          ),
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
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
