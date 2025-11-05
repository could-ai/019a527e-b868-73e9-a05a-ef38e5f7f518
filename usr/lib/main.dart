import 'package:flutter/material.dart';
import 'package:three_dart/three_dart.dart' as THREE;
import 'dart:math' as Math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quantum Weaver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const QuantumWeaverGame(),
    );
  }
}

class QuantumWeaverGame extends StatefulWidget {
  const QuantumWeaverGame({super.key});

  @override
  State<QuantumWeaverGame> createState() => _QuantumWeaverGameState();
}

class _QuantumWeaverGameState extends State<QuantumWeaverGame> {
  late THREE.Scene scene;
  late THREE.PerspectiveCamera camera;
  late THREE.WebGLRenderer renderer;
  late THREE.Mesh player;
  late THREE.Mesh target;
  late THREE.Group quantumThreads;
  late THREE.AnimationMixer mixer;
  late THREE.Clock clock;

  double time = 0.0;
  bool isWeaving = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    initThreeJS();
  }

  void initThreeJS() {
    scene = THREE.Scene();
    camera = THREE.PerspectiveCamera(75, 1.0, 0.1, 1000);
    camera.position.set(0, 0, 5);

    renderer = THREE.WebGLRenderer({'antialias': true});
    renderer.setSize(400, 400);
    renderer.shadowMap.enabled = true;

    // Player (quantum particle)
    var playerGeometry = THREE.SphereGeometry(0.1);
    var playerMaterial = THREE.MeshPhongMaterial({'color': 0x00ff00});
    player = THREE.Mesh(playerGeometry, playerMaterial);
    player.position.set(0, 0, 0);
    scene.add(player);

    // Target (decohering particle)
    var targetGeometry = THREE.OctahedronGeometry(0.3);
    var targetMaterial = THREE.MeshPhongMaterial({'color': 0xff0000});
    target = THREE.Mesh(targetGeometry, targetMaterial);
    target.position.set(Math.Random().nextDouble() * 4 - 2, Math.Random().nextDouble() * 4 - 2, Math.Random().nextDouble() * 4 - 2);
    scene.add(target);

    // Quantum threads group
    quantumThreads = THREE.Group();
    scene.add(quantumThreads);

    // Lighting
    var ambientLight = THREE.AmbientLight(0x404040);
    scene.add(ambientLight);
    var directionalLight = THREE.DirectionalLight(0xffffff, 1.0);
    directionalLight.position.set(1, 1, 1);
    scene.add(directionalLight);

    // Background fractal-like environment
    createFractalEnvironment();

    clock = THREE.Clock();
    mixer = THREE.AnimationMixer(scene);

    // Animation loop
    animate();
  }

  void createFractalEnvironment() {
    // Create fractal-like 3D structures using recursive geometry
    for (int i = 0; i < 50; i++) {
      var fractalGeometry = THREE.BoxGeometry(0.1, 0.1, 0.1);
      var fractalMaterial = THREE.MeshLambertMaterial({'color': THREE.MathUtils.randInt(0x000000, 0xffffff)});
      var fractal = THREE.Mesh(fractalGeometry, fractalMaterial);
      fractal.position.set(
        Math.Random().nextDouble() * 10 - 5,
        Math.Random().nextDouble() * 10 - 5,
        Math.Random().nextDouble() * 10 - 5
      );
      fractal.rotation.set(
        Math.Random().nextDouble() * Math.pi,
        Math.Random().nextDouble() * Math.pi,
        Math.Random().nextDouble() * Math.pi
      );
      scene.add(fractal);
    }
  }

  void animate() {
    // Smooth animation loop
    Future.delayed(Duration(milliseconds: 16), () {
      if (mounted) {
        setState(() {
          time += 0.02;
          // Update player position based on time (simulating movement)
          player.position.x = Math.sin(time) * 2;
          player.position.y = Math.cos(time * 0.7) * 1.5;
          player.position.z = Math.sin(time * 0.5) * 3;

          // Rotate target
          target.rotation.x += 0.01;
          target.rotation.y += 0.01;

          // Animate fractal environment
          scene.children.where((child) => child is THREE.Mesh && child != player && child != target)
            .forEach((fractal) {
              fractal.rotation.x += 0.005;
              fractal.rotation.y += 0.003;
            });

          // Check collision
          var distance = player.position.distanceTo(target.position);
          if (distance < 0.4) {
            score += 10;
            target.position.set(
              Math.Random().nextDouble() * 4 - 2,
              Math.Random().nextDouble() * 4 - 2,
              Math.Random().nextDouble() * 4 - 2
            );
          }

          mixer.update(clock.getDelta());
          renderer.render(scene, camera);
        });
        animate();
      }
    });
  }

  void onWeavePressed() {
    setState(() {
      isWeaving = !isWeaving;
      if (isWeaving) {
        // Create quantum thread
        var threadGeometry = THREE.CylinderGeometry(0.01, 0.01, 1);
        var threadMaterial = THREE.MeshBasicMaterial({'color': 0x0000ff});
        var thread = THREE.Mesh(threadGeometry, threadMaterial);
        thread.position.copy(player.position);
        quantumThreads.add(thread);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quantum Weaver'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black,
              child: Center(
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: HtmlElementView(viewType: 'three-canvas'),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Column(
              children: [
                Text('Score: $score', style: const TextStyle(color: Colors.white, fontSize: 20)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: onWeavePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWeaving ? Colors.blue : Colors.green,
                  ),
                  child: Text(isWeaving ? 'Stop Weaving' : 'Start Weaving'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Navigate through quantum space, weave threads to stabilize particles, and avoid decoherence!',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // Cleanup resources
  }
}
