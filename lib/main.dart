import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:tflite_audio/tflite_audio.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _sound = "Press the button to start";
  PlatformFile? _inputFile;

  @override
  void initState() {
    super.initState();
    TfliteAudio.loadModel(
      inputType: 'decodedWav',
      model: 'assets/saved_model.tflite',
      label: 'assets/labels.txt',
      numThreads: 1,
      isAsset: true,
    );
  }

  void openFile(String? filePath) {
    if (filePath != null) {
      OpenFile.open(filePath);
      print("File is playing");
    }
  }

  Future<File?> savePermanently(PlatformFile inputfile) async {
    try {
      final appStorage = await getApplicationDocumentsDirectory();
      final newInputFile = File('${appStorage.path}${inputfile.name}');
      print('APP STORAGE PATH: ${appStorage.path}');

      final copiedFile = await File(inputfile.path!).copy(newInputFile.path);
      print('LOCATION: ${appStorage.path}${inputfile.name}');
      print('LOCATION COPIED FILE: ${copiedFile.path}');

      return copiedFile;
    } catch (e) {
      print('Error saving file: $e');
      return null;
    }
  }

  Future<void> getResult(String filepath) async {
    try {
      if (filepath.isNotEmpty) {
        var modelOutput = await TfliteAudio.startFileRecognition(
          audioDirectory: filepath,
          sampleRate: 16000,
        );
        modelOutput.listen((event) {
          var recognition = event["recognitionResult"].toString();
          print('Output: $recognition');
          setState(() {
            _sound = recognition.toString();
          });
        });
        print("File is processed");
      } else {
        print('File is null');
      }
    } catch (e) {
      print('Error processing file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  "What's this sound?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 60,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              ElevatedButton(
                child: Text('Pick File'),
                onPressed: () async {
                  try {
                    final inputfile = await FilePicker.platform.pickFiles();
                    if (inputfile != null && inputfile.files.isNotEmpty) {
                      final firstFile = inputfile.files.first;
                      final newInputFile = await savePermanently(firstFile);
                      if (newInputFile != null) {
                        setState(() {
                          _inputFile = firstFile;
                        });
                        openFile(newInputFile.path);
                        print('Path: ${newInputFile.path}');
                        getResult(newInputFile
                            .path); // Call getResult with the newInputFile path
                      } else {
                        print('Error saving file');
                      }
                    }
                  } catch (e) {
                    print('Error picking file: $e');
                  }
                },
              ),
              ElevatedButton(
                child: Text('Run through model'),
                onPressed: () async {
                  if (_inputFile != null) {
                    final newInputFile = await savePermanently(_inputFile!);
                    getResult(
                        newInputFile!.path); // Ensure newInputFile is not null
                  } else {
                    print('File is null');
                  }
                },
              ),
              ElevatedButton(
                  child: Text('Run'),
                  onPressed: () {
                    print('Output: $_inputFile');
                  }),
              Text(
                '$_sound',
                style: Theme.of(context).textTheme.headline5!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
