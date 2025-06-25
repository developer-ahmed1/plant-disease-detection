import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:io';

const apiKey = 'AIzaSyCgwSbq863fmjEO_tlf5Op60QgW2fL_GOw';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Gemini.init(apiKey: apiKey, enableDebugging: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plant Disease Detection',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  String _diseaseLabel = "";
  double _confidence = 0.0;
  String? _selectedImagePath;
  File? filePath;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }

  Future<void> pickImageGallery() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image from the gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    var imageMap = File(image.path);
    setState(() {
      filePath = imageMap;
      _selectedImagePath = image.path;
    });

    // Run TFLite model on the selected image
    var result = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.5,
      imageMean: 0.0,
      imageStd: 255.0,
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _diseaseLabel = result[0]["label"];
        _confidence = result[0]["confidence"];
      });
    }
  }

  Future<void> pickImageCamera() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image from the camera
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    var imageMap = File(image.path);
    setState(() {
      filePath = imageMap;
      _selectedImagePath = image.path;
    });

    // Run TFLite model on the selected image
    var result = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.5,
      imageMean: 0.0,
      imageStd: 255.0,
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _diseaseLabel = result[0]["label"];
        _confidence = result[0]["confidence"];
      });
    }
  }

  void _navigateToSolutionScreen(String language) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolutionScreen(
          diseaseLabel: _diseaseLabel,
          language: language,
        ),
      ),
    );
  }

  @override
  void dispose() {
    Tflite.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Plant Disease Detection',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview Container
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: _selectedImagePath != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(_selectedImagePath!),
                    fit: BoxFit.cover,
                  ),
                )
                    : Center(
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Camera and Gallery Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => pickImageCamera(),
                  ),
                  _buildImageSourceButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => pickImageGallery(),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Results Section
              if (_diseaseLabel.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detection Results',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Disease:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_diseaseLabel),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Confidence:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${(_confidence * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => _navigateToSolutionScreen('English'),
                              child: Text('English Solution'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => _navigateToSolutionScreen('Urdu'),
                              child: Text('Urdu Solution'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 150,
            padding: EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 30),
                SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SolutionScreen extends StatefulWidget {
  final String diseaseLabel;
  final String language;

  const SolutionScreen({
    Key? key,
    required this.diseaseLabel,
    required this.language,
  }) : super(key: key);

  @override
  _SolutionScreenState createState() => _SolutionScreenState();
}

class _SolutionScreenState extends State<SolutionScreen> {
  String solution = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchSolution();
  }

  Future<void> _fetchSolution() async {
    String prompt = 'Provide a solution for the plant disease: ${widget.diseaseLabel}';
    if (widget.language == 'Urdu') {
      prompt += ' in Urdu';
    }

    try {
      final gemini = Gemini.instance;
      final response = await gemini.text(prompt);
      setState(() {
        solution = response?.content?.parts?.firstOrNull?.text ?? "No solution available.";
      });
    } catch (e) {
      setState(() {
        solution = "Error: Couldn't fetch solution. $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solution'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_florist),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.diseaseLabel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Recommended Solution:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    solution,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}