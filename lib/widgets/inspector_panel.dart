import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../controllers/hierarchy_controller.dart';
import '../models/widget_node.dart';

class InspectorPanel extends StatelessWidget {
  final controller = Get.find<HierarchyController>();

  InspectorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Inspector', style: TextStyle(fontSize: 16)),
        ),
        const Divider(),
        Expanded(
          child: Obx(() {
            final selectedNode = controller.selected.value;
            if (selectedNode == null) {
              return const Center(
                child: Text('No item selected',
                    style: TextStyle(color: Colors.grey)),
              );
            }
            return _buildProperties(selectedNode);
          }),
        ),
      ],
    );
  }

  Widget _buildProperties(WidgetNode node) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        _buildPropertyItem('Type', node.type),
        _buildTextField('Name', node.name, (value) {
          node.name = value;
          controller.nodes.refresh();
        }),
        _buildPropertyItem('ID', node.id),
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Widget Properties',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        if (node.type == 'Container') ...[
          _buildNumberInput(node),
          _buildColorInput(node),
        ] else if (node.type == 'Text') ...[
          _buildTextInput(node),
        ] else if (node.type == 'Row' || node.type == 'Column') ...[
          _buildAlignmentInputs(node),
        ],
      ],
    );
  }

  Widget _buildNumberInput(WidgetNode node) {
    return Column(
      children: [
        GetBuilder<HierarchyController>(
          builder: (controller) => _buildNumberField(
            'Width',
            node.width.value.toString(),
            (newValue) {
              if (newValue.isNotEmpty) {
                final value = double.tryParse(newValue);
                if (value != null) {
                  controller.updateNodeSize(node, value, node.height.value);
                }
              }
            },
          ),
        ),
        GetBuilder<HierarchyController>(
          builder: (controller) => _buildNumberField(
            'Height',
            node.height.value.toString(),
            (newValue) {
              if (newValue.isNotEmpty) {
                final value = double.tryParse(newValue);
                if (value != null) {
                  controller.updateNodeSize(node, node.width.value, value);
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorInput(WidgetNode node) {
    return GetBuilder<HierarchyController>(
      builder: (controller) => _buildColorPicker(
        'Color',
        node.color.value,
        (newColor) {
          controller.updateNodeColor(node, newColor);
        },
      ),
    );
  }

  Widget _buildTextInput(WidgetNode node) {
    return Column(
      children: [
        GetBuilder<HierarchyController>(
          builder: (controller) => _buildTextField(
            'Content',
            node.content.value,
            (newValue) {
              controller.updateTextContent(node, newValue);
            },
          ),
        ),
        GetBuilder<HierarchyController>(
          builder: (controller) => _buildNumberField(
            'Font size',
            node.fontSize.value.toString(),
            (newValue) {
              if (newValue.isNotEmpty) {
                final value = double.tryParse(newValue);
                if (value != null) {
                  controller.updateFontSize(node, value);
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlignmentInputs(WidgetNode node) {
    return Column(
      children: [
        GetBuilder<HierarchyController>(
          builder: (controller) => _buildDropdown(
            'Main Alignment',
            node.mainAxisAlignment.value.toString().split('.').last,
            [
              'start',
              'center',
              'end',
              'spaceBetween',
              'spaceAround',
              'spaceEvenly'
            ],
            (newValue) {
              if (newValue != null) {
                final alignment = MainAxisAlignment.values.firstWhere(
                    (e) => e.toString().split('.').last == newValue);
                controller.updateAlignment(node, main: alignment);
              }
            },
          ),
        ),
        GetBuilder<HierarchyController>(
          builder: (controller) => _buildDropdown(
            'Cross Alignment',
            node.crossAxisAlignment.value.toString().split('.').last,
            ['start', 'center', 'end', 'stretch', 'baseline'],
            (newValue) {
              if (newValue != null) {
                final alignment = CrossAxisAlignment.values.firstWhere(
                    (e) => e.toString().split('.').last == newValue);
                controller.updateAlignment(node, cross: alignment);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, String initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          TextField(
            controller: TextEditingController(text: initialValue),
            onChanged: onChanged,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              filled: true,
              fillColor: Colors.grey[850],
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField(
      String label, String initialValue, Function(String) onChanged) {
    return _buildTextField(label, initialValue, (value) {
      if (value.isEmpty || double.tryParse(value) != null) {
        onChanged(value);
      }
    });
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: Colors.grey[850],
              underline: const SizedBox(),
              style: const TextStyle(fontSize: 13, color: Colors.white),
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(
      String label, Color color, Function(Color) onColorChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          InkWell(
            onTap: () {
              showDialog(
                context: Get.context!,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Pick a color'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: color,
                        onColorChanged: onColorChanged,
                        pickerAreaHeightPercent: 0.8,
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Done'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[700]!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
