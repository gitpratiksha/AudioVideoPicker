import 'dart:io';
import 'package:audio_video_picker/player_widget.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_multimedia_picker/fullter_multimedia_picker.dart';
import 'package:flutter_multimedia_picker/data/MediaFile.dart';
import 'package:flutter_multimedia_picker/widget/PickerWidget.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class MyImageApp extends StatefulWidget {
  @override
  _MyImageAppState createState() => _MyImageAppState();
}

class _MyImageAppState extends State<MyImageApp> {
  String selectText = "";
  String kUrl = 'https://luan.xyz/files/audio/ambient_c_motion.mp3';
  AudioCache audioCache = AudioCache();
  AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
  File audiofile;
int result;
int counter=0;
  String localFilePath;
  
  Future _loadFile() async {
    final bytes = await readBytes(kUrl);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/audio.mp3');
    print(file);
     await file.writeAsBytes(bytes);
     
    if (await file.exists()) {
      setState(() {
        localFilePath = file.path;
        print(localFilePath);
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _checkPermission().then((granted) {
      if (!granted) return;
    });
  }

  Future<bool> _checkPermission() async {
    final permissionStorageGroup =
        Platform.isIOS ? PermissionGroup.photos : PermissionGroup.storage;
    Map<PermissionGroup, PermissionStatus> res =
        await PermissionHandler().requestPermissions([
      permissionStorageGroup,
    ]);
    return res[permissionStorageGroup] == PermissionStatus.granted;
  }

Future<void> getaudio()
async {
    audiofile = await FilePicker.getFile(type: FileType.AUDIO);
   
}

play()
async {
result = await audioPlayer.play(audiofile.path);
      print(result);
      if (result == 1) {
  // success
  print('success');
 }
}
stop()
async {
 result = await audioPlayer.stop();
  print(result);
}

pause()
async {
result = await audioPlayer.pause();
 print(result);
}
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getMedia() async {
    try {
      //File audiofile = await FilePicker.getFile(type: FileType.AUDIO);
      // print(audiofile);
      List<MediaFile> imageMediaFileList =
          await FlutterMultiMediaPicker.getImage();

      List<MediaFile> videoMediaFileList =
          await FlutterMultiMediaPicker.getVideo();

      List<MediaFile> allMediaFileList = await FlutterMultiMediaPicker.getAll();
     

      if (imageMediaFileList.length > 0) {
        MediaFile imageMedia = await FlutterMultiMediaPicker.getMediaFile(
            fileId: imageMediaFileList[0].id, type: MediaType.IMAGE);
      }
       

      if (videoMediaFileList.length > 0) {
        MediaFile videoMedia = await FlutterMultiMediaPicker.getMediaFile(
            fileId: videoMediaFileList[0].id, type: MediaType.VIDEO);
      }

      if (imageMediaFileList.length > 0) {
        String imageMedia = await FlutterMultiMediaPicker.getThumbnail(
            fileId: imageMediaFileList[0].id, type: MediaType.IMAGE);
      }

      if (videoMediaFileList.length > 0) {
        String videoMedia = await FlutterMultiMediaPicker.getThumbnail(
            fileId: videoMediaFileList[0].id, type: MediaType.VIDEO);
      }
    } on Exception {
      print("Exception");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              
              RaisedButton(
                  child: const Text("Show All Media"),
                  onPressed: () {
                    FlutterMultiMediaPicker.getAll().then((mediaFiles) {
                      //print(mediaFiles);
                      _awaitReturnValueFromSecondScreen(context, mediaFiles);
                    });
                  }),
              RaisedButton(
                  child: const Text("Show Image Media"),
                  onPressed: () {
                    FlutterMultiMediaPicker.getImage().then((mediaFiles) {
                      //print(mediaFiles);
                      _awaitReturnValueFromSecondScreen(context, mediaFiles);
                    });
                  }),
              RaisedButton(
                  child: const Text("Show Video Media"),
                  onPressed: () {
                    FlutterMultiMediaPicker.getVideo().then((mediaFiles) {
                      //print(mediaFiles);
                      _awaitReturnValueFromSecondScreen(context, mediaFiles);
                    });
                  }),
              RaisedButton(
                  child: const Text("show audio"),
                  onPressed: () {
                     getaudio();
                   
                   
                  }),
                  Row(children: <Widget>[
                       RaisedButton(
                  child: const Text("play"),
                  onPressed: () {
                    play();
                //      Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) =>PlaySong(result: "$result",)),
                // );
                  }),
                   RaisedButton(
                  child: const Text("pause"),
                  onPressed: () {
                    pause();
                  }),
                   RaisedButton(
                  child: const Text("stop"),
                  onPressed: () {
                    stop();
                  }),
                  ],),
              Text("$selectText"),
              Container(
                height: 300,
                width: 400,
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(6.0),
                    boxShadow: [BoxShadow(color: Colors.blueAccent)]),
                padding: EdgeInsets.all(20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _awaitReturnValueFromSecondScreen(
      BuildContext context, List<MediaFile> mediaFiles) async {
    // start the SecondScreen and wait for it to finish with a result
    Set<MediaFile> result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PickerScreen(mediaFiles),
        ));

    // after the SecondScreen result comes back update the Text widget with it

    if (result == null) {
      return;
    }

    setState(() {
      int size = result.length;
      selectText = "Selected Media Size $size";
    });
  }
}

class PickerScreen extends StatefulWidget {
  List<MediaFile> mediaFiles;

  PickerScreen(this.mediaFiles);

  @override
  _PickerScreenState createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Media Picker"),
        ),
        body: Center(
          child: PickerWidget(widget.mediaFiles, onDone, onCancel),
        ));
  }

  onDone(Set<MediaFile> selectedFiles) {
    Navigator.pop(context, selectedFiles);
  }

  onCancel() {
    Navigator.pop(context);
  }
}


