import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RemoteObject()
    );
  }
}

class RemoteObject extends StatefulWidget {
  @override
  _RemoteObjectState createState() => _RemoteObjectState();
}

class _RemoteObjectState extends State<RemoteObject> {
  ArCoreController arCoreController;

  String objectSelected;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Object on plane detected'),
        ),
        body: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
          enableTapRecognizer: true,
          type: ArCoreViewType.AUGMENTEDIMAGES
        )
      )
    );
  }

  Future<void> _onArCoreViewCreated(ArCoreController controller) async {
    arCoreController = controller;
    // arCoreController.onNodeTap = (name) => onTapHandler(name);
    // arCoreController.onPlaneTap = _handleOnPlaneTap;

    final ByteData bytes = await rootBundle.load('assets/images/semel.jpg');
    arCoreController.loadSingleAugmentedImage(bytes: bytes.buffer.asUint8List());
    arCoreController.onTrackingImage = _imageTrackingHandler;
  }

  void _imageTrackingHandler(ArCoreAugmentedImage image) {
    if (image != null) {
      final ArCoreReferenceNode node = ArCoreReferenceNode(
        name: "Toucano",
        objectUrl: 
        'https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF/Duck.gltf'/* "https://raw.githubusercontent.com/agnoam/ar_flutter_poc/master/assets/objects/untitled.gltf" */
        // scale: vector.Vector3(0.1, 0.1, 0.1)
      );

      arCoreController.removeNodeWithIndex(0);
      arCoreController.addArCoreNodeToAugmentedImage(node, image.index);
    }
  }

  void _addToucano(ArCoreHitTestResult plane) {
    final toucanNode = ArCoreReferenceNode(
      name: "Toucano",
      objectUrl:
      "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF/Duck.gltf",
      position: plane.pose.translation,
      rotation: plane.pose.rotation
    );

    arCoreController.addArCoreNodeWithAnchor(toucanNode);
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;
    _addToucano(hit);
  }

  void onTapHandler(String name) {
    print("Flutter: onNodeTap");
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Row(
          children: <Widget>[
            Text('Remove $name?'),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  arCoreController.removeNode(nodeName: name);
                  Navigator.pop(context);
                })
          ]
        )
      )
    );
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}