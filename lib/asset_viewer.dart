import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class AnimationScene extends StatefulWidget {
  const AnimationScene({super.key});

  @override
  State<AnimationScene> createState() => _AnimationSceneState();
}

class _AnimationSceneState extends State<AnimationScene> {
  late Flutter3DController controller1;
  late Flutter3DController controller2;

  // States for Model 1
  bool isRunning1 = false;
  bool isJumping1 = false;
  double scale1 = 1.0;

  // States for Model 2
  bool isRunning2 = false;
  bool isJumping2 = false;
  double scale2 = 1.0;

  final FocusNode _focusNode = FocusNode();

  // Camera control constants
  final double _defaultOrbitDistance = 100;
  final double _defaultOrbitHeight = 75;
  final double _defaultTargetY = 1.0;

  @override
  void initState() {
    super.initState();
    controller1 = Flutter3DController();
    controller2 = Flutter3DController();
  }

  // Camera Control Methods
  void setCameraFront(Flutter3DController controller) {
    controller.setCameraOrbit(0, _defaultOrbitHeight, _defaultOrbitDistance);
    controller.setCameraTarget(0, _defaultTargetY, 0);
  }

  void setCameraLeft(Flutter3DController controller) {
    controller.setCameraOrbit(90, _defaultOrbitHeight, _defaultOrbitDistance);
    controller.setCameraTarget(0, _defaultTargetY, 0);
  }

  void setCameraRight(Flutter3DController controller) {
    controller.setCameraOrbit(-90, _defaultOrbitHeight, _defaultOrbitDistance);
    controller.setCameraTarget(0, _defaultTargetY, 0);
  }

  void setCameraClose(Flutter3DController controller) {
    controller.setCameraOrbit(
        0, _defaultOrbitHeight, _defaultOrbitDistance * 0.6);
    controller.setCameraTarget(0, _defaultTargetY, 0);
  }

  // Animation Control Methods
  void handleRunning1() {
    setState(() => isRunning1 = !isRunning1);
    isRunning1
        ? controller1.playAnimation(animationName: "Running.001")
        : controller1.stopAnimation();
  }

  void handleJumping1() {
    if (!isJumping1) {
      setState(() => isJumping1 = true);
      controller1.playAnimation(animationName: "Jumping");
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => isJumping1 = false);
        isRunning1
            ? controller1.playAnimation(animationName: "Running")
            : controller1.stopAnimation();
      });
    }
  }

  void handleRunning2() {
    setState(() => isRunning2 = !isRunning2);
    isRunning2
        ? controller2.playAnimation(animationName: "Running2")
        : controller2.stopAnimation();
  }

  void handleJumping2() {
    if (!isJumping2) {
      setState(() => isJumping2 = true);
      controller2.playAnimation(animationName: "Jumping2");
      Future.delayed(const Duration(seconds: 1), () {
        setState(() => isJumping2 = false);
        isRunning2
            ? controller2.playAnimation(animationName: "Running2")
            : controller2.stopAnimation();
      });
    }
  }

  // UI Components
  Widget buildCameraControls(Flutter3DController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () => setCameraFront(controller),
          child: const Icon(Icons.center_focus_strong_outlined),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () => setCameraLeft(controller),
              child: const Icon(Icons.swipe_left),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: () => setCameraRight(controller),
              child: const Icon(Icons.swipe_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: () => setCameraClose(controller),
          child: const Icon(Icons.zoom_in),
        ),
      ],
    );
  }

  Widget buildControlPanel(
    String title,
    bool isRunning,
    VoidCallback onRun,
    VoidCallback onJump,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      // color: Colors.black54,
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onRun,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRunning ? Colors.red : Colors.blue,
                  ),
                  child: FittedBox(child: Text(isRunning ? "Stop" : 'Run')),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: onJump,
                  child: FittedBox(
                      child: const Text(
                    'Jump',
                  )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget buildModelView(
    Flutter3DController controller,
    String assetPath,
    String title,
    bool isRunning,
    VoidCallback onRun,
    VoidCallback onJump,
  ) {
    return Expanded(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                //  flex: 2,
                child: Flutter3DViewer(
                  controller: controller,
                  src: assetPath,
                ),
              ),
              buildControlPanel(
                title,
                isRunning,
                onRun,
                onJump,
              ),
            ],
          ),
          Positioned(
            bottom: MediaQuery.sizeOf(context).height * .15,
            left: 30,
            child: buildCameraControls(controller),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              handleRunning1();
            } else if (event.logicalKey == LogicalKeyboardKey.space) {
              handleJumping1();
            } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
              handleRunning2();
            } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
              handleJumping2();
            }
          }
        },
        child: Row(
          children: [
            buildModelView(
              controller1,
              'assets/avater1.glb',
              'Model 1',
              isRunning1,
              handleRunning1,
              handleJumping1,
            ),
            buildModelView(
              controller2,
              'assets/avatar2.glb',
              'Model 2',
              isRunning2,
              handleRunning2,
              handleJumping2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
