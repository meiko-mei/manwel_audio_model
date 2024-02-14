import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:open_file/open_file.dart';
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

Future<void> createDirectory() async {
  final directory =
      await getApplicationDocumentsDirectory(); // Use getExternalStorageDirectory() for external storage
  final myDir = Directory('${directory.path}/myCustomDir');
  if (!await myDir.exists()) {
    await myDir.create(
        recursive:
            true); // Creates the directory and any non-existent parent directories
    print('created directory');
  } else
    () {
      print('error creating directory');
    };
}

class FileOpener {
  static const platform =
      MethodChannel('com.example.audio_recognition_appliction');

  static Future<void> openFile(String filePath) async {
    try {
      await platform.invokeMethod('openFile', {'filePath': filePath});
    } on PlatformException catch (e) {
      print("Failed to open file: '${e.message}'.");
    }
  }
}

class _MyHomePageState extends State<MyHomePage> {
  String _sound = "Press the button to start";
  String? fileLocation;

  get path => null;

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
    createDirectory();
  }

  // Future<File?> savePermanently(PlatformFile inputfile) async {
  //   try {
  //     final appStorage = await getApplicationDocumentsDirectory();
  //     final newInputFile = File('${appStorage.path}${inputfile.name}');
  //     print('APP STORAGE PATH: ${appStorage.path}');

  //     final copiedFile = await File(inputfile.path!).copy(newInputFile.path);
  //     print('LOCATION: ${appStorage.path}${inputfile.name}');
  //     print('LOCATION COPIED FILE: ${copiedFile.path}');

  //     return copiedFile;
  //   } catch (e) {
  //     print('Error saving file: $e');
  //   }
  //   return null;
  // }

  Future<void> getResult(String fileLocation) async {
    try {
      print("File File location: $fileLocation");
      if (fileLocation.isNotEmpty) {
        var modelOutput = await TfliteAudio.startFileRecognition(
          audioDirectory: fileLocation,
          sampleRate: 16000,
        );

        modelOutput.listen((event) {
          var recognition = event["recognitionResult"].toString();
          print('Output: $recognition');
          // setState(() {
          //   _sound = recognition.toString();
        });
        // });
        //   print("File is processed");
        // } else {
        //   print('File is null');
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
              // ElevatedButton(
              //   child: Text('Pick File'),
              //   onPressed: () async {
              //     try {
              //       final pickedFile = await FilePicker.platform.pickFiles();
              //       if (pickedFile != null) {
              //         final directory =
              //             await getApplicationDocumentsDirectory();
              //         print('File saved to $directory');
              //       }
              //     } catch (e) {
              //       print('Error picking file: $e');
              //     }
              //   },
              // ),

              ElevatedButton(
                child: Text('Pick File'),
                onPressed: () async {
                  try {
                    final pickedFile = await FilePicker.platform.pickFiles();
                    if (pickedFile != null) {
                      fileLocation = pickedFile
                          .files.single.path; // Save the file location
                      print('File location: $fileLocation');
                      print('Test Path: ${pickedFile.paths}');
                    }
                  } catch (e) {
                    print('Error picking file: $e');
                  }
                },
              ),
              ElevatedButton(
                  child: Text('Use File Location'),
                  onPressed: () {
                    if (fileLocation != null) {
                      print(
                          'File location from previous selection: $fileLocation');
                      getResult(fileLocation!);
                      // Use the file location here or perform any other action
                    } else {
                      print('No file location available.');
                    }
                  }),
              ElevatedButton(
                  child: Text('Run'),
                  onPressed: () {
                    createDirectory();
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
