import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:tflite_audio/tflite_audio.dart';

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

  get recognition => null;

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

  void getResult() async {
    if (_inputFile != null) {
      String filePath = _inputFile!.path!;
      var modelOutput = await TfliteAudio.startFileRecognition(
        audioDirectory: filePath,
        sampleRate: 16000,
      );
      modelOutput.listen((event) {
        var recognition = event["recognitionResult"];
      });
      setState(() {
        String recognition = _sound;
      });
      print("File is processed");
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
                  final inputfile = await FilePicker.platform.pickFiles();
                  if (inputfile != null && inputfile.files.isNotEmpty) {
                    setState(() {
                      _inputFile = inputfile.files.first;
                    });
                    openFile(_inputFile!.path);
                  }
                },
              ),
              ElevatedButton(
                child: Text('Run through model'),
                onPressed: getResult,
              ),
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
