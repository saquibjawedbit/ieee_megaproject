import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './widgets/hierarchy_panel.dart';
import './widgets/inspector_panel.dart';
import './widgets/canvas_renderer.dart'; // Add this import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const Editor(),
    );
  }
}

class Editor extends StatelessWidget {
  const Editor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Hierarchy Panel
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[900],
              child: HierarchyPanel(),
            ),
          ),
          VerticalDivider(width: 1, color: Colors.grey[800]),
          // Canvas Renderer
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[850],
              child: CanvasRenderer(),
            ),
          ),
          VerticalDivider(width: 1, color: Colors.grey[800]),
          // Inspector Panel
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[900],
              child: InspectorPanel(),
            ),
          ),
        ],
      ),
    );
  }
}
