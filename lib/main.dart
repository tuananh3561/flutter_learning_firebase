import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// Import the firebase_core and cloud_firestore plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

bool shouldUseFirestoreEmulator = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Learning Firebase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UploadFilePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<ListResult> futureFile;
  Map<int, double> downloadProgress = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    futureFile = FirebaseStorage.instance.ref('/files').listAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download File'),
      ),
      body: FutureBuilder<ListResult>(
        future: futureFile,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final files = snapshot.data!.items;
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                double? progress = downloadProgress[index];
                return ListTile(
                  title: Text(file.name),
                  subtitle: progress != null
                      ? LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black26,
                        )
                      : null,
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.download,
                      color: Colors.black,
                    ),
                    onPressed: () => downloadFile(file, index),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error occured"),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future downloadFile(Reference ref, int index) async {
    /// Not visible for user
    // final dir = await getApplicationDocumentsDirectory();
    // final file = File('${dir.path}/${ref.name}');
    //
    // await ref.writeToFile(file);

    final url = await ref.getDownloadURL();

    final tempDir = await getTemporaryDirectory();
    final path = "${tempDir.path}/${ref.name}";

    await Dio().download(url, path, onReceiveProgress: (received, total) {
      double progress = received / total;
      setState(() {
        downloadProgress[index] = progress;
      });
    });

    if (url.contains('.mp4')) {
      await GallerySaver.saveVideo(path, toDcim: true);
    } else if (url.contains('.jpg')) {
      await GallerySaver.saveImage(path, toDcim: true);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download ${ref.name}')),
    );
  }
}

class UploadFilePage extends StatefulWidget {
  const UploadFilePage({Key? key}) : super(key: key);

  @override
  State<UploadFilePage> createState() => _UploadFilePageState();
}

class _UploadFilePageState extends State<UploadFilePage> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future uploadFile() async {
    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState((){
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download link:  $urlDownload');
    setState((){
      uploadTask = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload File'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (pickedFile != null)
              Expanded(
                child: Container(
                  color: Colors.blue[100],
                  child: Center(child: buildFile()),
                ),
              ),
            ElevatedButton(
              onPressed: selectFile,
              child: const Text('Select File'),
            ),
            const SizedBox(
              height: 32,
            ),
            ElevatedButton(
              onPressed: uploadFile,
              child: const Text('Upload File'),
            ),
            const SizedBox(
              height: 32,
            ),
            buildProgress(),
          ],
        ),
      ),
    );
  }

  Widget buildFile() {
    if (pickedFile!.extension! == "mp4") {
      return Text(pickedFile!.name);
      // return Video.file(
      //   File(pickedFile!.path!),
      //   width: double.infinity,
      //   fit: BoxFit.cover,
      // );
    } else if (pickedFile!.extension! == "png" ||
        pickedFile!.extension! == "jpg") {
      return Image.file(
        File(pickedFile!.path!),
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Text(pickedFile!.name);
    }
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;
          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.black26,
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          );
        } else {
          return const SizedBox(
            height: 50,
          );
        }
      });
}
