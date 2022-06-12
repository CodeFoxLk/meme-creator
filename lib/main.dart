import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:ui' as ui;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

Future<ui.Image> getImage(BuildContext context) async {
  NetworkImage assetImage = const NetworkImage("https://avatars.mds.yandex.net/i?id=84dbd50839c3d640ebfc0de20994c30d-4473719-images-taas-consumers&n=27&h=480&w=480");
  ImageStream stream = assetImage.resolve(createLocalImageConfiguration(context));
  Completer<ui.Image> completer = Completer();
  stream.addListener(ImageStreamListener((ImageInfo image, _) {
    return completer.complete(image.image);
  }));
  return completer.future;
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [IconButton(onPressed: () async{
        final image = await getImage(context);
        renderedScoreImage(image);
      }, icon: const Icon(Icons.print))],),
      body: 
      FutureBuilder(
      future: getImage(context),
      builder: (c, image) {
        if(image.data == null){
          return const SizedBox();
        }
        return CustomPaint(
          painter: ImageEditor(image: image.data as ui.Image),
        );
      },
    ));
  }
}

class ImageEditor extends CustomPainter {
  ImageEditor({
    required this.image,
  });

  final ui.Image image;

  final Paint painter = Paint();
  static Canvas? canvas;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, const Offset(0.0, 0.0), Paint());
    ImageEditor.canvas = canvas;
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  
}

  const double _overSampleScale = 4;
  Future<ui.Image> renderedScoreImage(ui.Image image) async {
    final recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    //const size = Size(200 * _overSampleScale, 200 * _overSampleScale);
    canvas.drawImage(image, const Offset(0.0, 0.0), Paint());
    canvas.save();
    canvas.scale(_overSampleScale);
    canvas.restore();
    final data = recorder.endRecording();
    final img = await data.toImage(image.width.floor(), image.height.floor());
    var pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    final uni8Data = pngBytes?.buffer.asUint8List();

    try {
       //File('${directory.path}/recorderfilename.png').writeAsBytesSync(pngBytes!.buffer.asInt8List());
       final saved = await ImageGallerySaver.saveImage(
        uni8Data!,
        quality: 100,
        name: '${DateTime.now().toIso8601String()}.png',
        isReturnImagePathOfIOS: true,
      );
    } catch (e) {
      print(e);
    }
   
    return img;
  }



