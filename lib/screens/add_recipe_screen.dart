import 'dart:async'; 
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';
import '../database/db_helper.dart';


class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({Key? key}) : super(key: key);

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _audioFilePath;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isRecorderInitialized = false;


  
void _showRecordingBottomSheet(BuildContext context) async {
  bool isGranted = await requestMicPermission();
  if (!isGranted) {
    Fluttertoast.showToast(msg: "Microphone permission denied.");
    return;
  }

  Directory tempDir = await getTemporaryDirectory();
  String path = '${tempDir.path}/voice_recipe.aac';

  await _recorder.startRecorder(toFile: path);

  int secondsElapsed = 0;
  Timer? _timer;

  setState(() {
    _audioFilePath = path;
    _isRecording = true;
    


  });

  showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setBottomSheetState) {
          _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
            setBottomSheetState(() {
              secondsElapsed++;
            });
          });

          String formattedTime = "${(secondsElapsed ~/ 60).toString().padLeft(2, '0')}:${(secondsElapsed % 60).toString().padLeft(2, '0')}";

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🎙️ Mic + "Recording..." + Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic_rounded, color: Colors.green[700], size: 30),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Recording...",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // ✅ Save and ❌ Discard Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _stopRecording();
                        _timer?.cancel();
                        Navigator.pop(context);
                        Fluttertoast.showToast(msg: "Recording saved!");
                      },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text("Save", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _stopRecording();
                        if (_audioFilePath != null) {
                          File(_audioFilePath!).delete(); // Delete the file if discarding
                        }
                        _timer?.cancel();
                        Navigator.pop(context);
                        Fluttertoast.showToast(msg: "Recording discarded.");
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text("Discard", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  ).whenComplete(() {
    _timer?.cancel();
    _timer = null;
  });
}


  static const platform = MethodChannel("voicecook.speech.recognizer");

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await _recorder.openRecorder();

    setState(() {
    _isRecorderInitialized = true; // ✅ Mark as initialized
  });
    
  }

  Future<void> _startRecording() async {
  bool isGranted = await requestMicPermission();
  if (!isGranted) {
    Fluttertoast.showToast(msg: "Microphone permission denied.");
    return;
  }

  await _initRecorder();


  final directory = await getApplicationDocumentsDirectory();
  String filePath = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
  await _recorder.startRecorder(toFile: filePath);
  setState(() {
    _isRecording = true;
    _audioFilePath = filePath;
  });
}


  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    Fluttertoast.showToast(msg: "Audio saved to $_audioFilePath");

  }

  

  Future<void> _startVoiceToText(TextEditingController controller) async {
  try {
    final String result = await platform.invokeMethod('startSpeechRecognition');
    setState(() {
      controller.text = result;
    });
  } on PlatformException catch (e) {
    Fluttertoast.showToast(msg: "Speech recognition failed: ${e.message}");
  }
}

Future<bool> requestMicPermission() async {
  PermissionStatus status = await Permission.microphone.request();
  return status.isGranted;
}

Future<void> _pickImage(ImageSource source) async {
  final pickedFile = await _picker.pickImage(source: source);

  if (pickedFile != null) {
    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }
}



  @override
  void dispose() {
    _ingredientController.dispose();
    _titleController.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

Future<void> _saveRecipe() async {
  final String ingredients = _ingredientController.text.trim();
  final String title = _titleController.text.trim();
  if (ingredients.isEmpty) {
    Fluttertoast.showToast(msg: "Please enter ingredients.");
    return;
  }

  final recipe = Recipe(
    title: title,
    ingredients: ingredients,
    imagePath: _imageFile?.path ?? '',
    audioPath: _audioFilePath ?? '', 
    creatorId: 'user123', // required
  );

  await DatabaseHelper().insertRecipe(recipe);
  Fluttertoast.showToast(msg: "Recipe saved!");
  Navigator.pop(context);

  
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Recipe'),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Colors.orange[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row with camera and ingredients input
            Row(
              children: [
                GestureDetector(
                   onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext context) {
                        return Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Take Photo'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text('Choose from Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        );
                      },
                    );
                   },
                   child: Icon(Icons.camera_alt, size: 40, color: Colors.deepOrange),
            ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _ingredientController,
                        decoration: InputDecoration(
                          hintText: 'Enter ingredients... or tap mic',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: GestureDetector(
                            onTap: () => _startVoiceToText(_ingredientController),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(
                                'assets/images/voicecook_logo.png',
                                width: 28,
                                height: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Enter recipe title... or tap mic',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: GestureDetector(
                            onTap: () => _startVoiceToText(_titleController),
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Image.asset(
                                'assets/images/voicecook_logo.png',
                                width: 28,
                                height: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),


            // Voice recording logo (kept unchanged)
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onLongPress: () => _showRecordingBottomSheet(context),

                child: Image.asset(
                  'assets/images/voicecook_logo.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _saveRecipe,
              icon: const Icon(Icons.save),
              label: const Text("Save Recipe"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}  