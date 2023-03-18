import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:dart_openai/openai.dart';
import 'second.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future main() async{
  await dotenv.load(fileName: '.env');
  OpenAI.apiKey = dotenv.get('API_KEY');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  XFile? image;
  final picker = ImagePicker();
  Text result = Text('');
  late OpenAI openAI;
  String answerText = '';
  bool ja_flag = true;
  bool en_flag = false;

  void flagChange_ja(bool? e)
  {
    setState(() {
      ja_flag = e!;
      en_flag = !e!;
    });
  }

  void flagChange_en(bool? e)
  {
    setState(() {
      en_flag = e!;
      ja_flag = !e!;
    });
  }

  Future cropImage(XFile img) async {
    final croppedFile = await ImageCropper().cropImage(
        sourcePath: img.path,
        );
        if (croppedFile != null) {
          this.image = XFile(croppedFile.path);
        }
      setState(() {
      });
    }

  // 画像をギャラリーから選ぶ関数
  Future pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    // 画像がnullの場合戻る
    if (image == null) return;

    final imageTemp = image;

    await cropImage(imageTemp);

    setState((){});
  }
  // カメラを使う関数
  Future pickImageCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    // 画像がnullの場合戻る
    if (image == null) return;

    final imageTemp = image;

    await cropImage(imageTemp);

    setState((){});
  }

  Future main(String mode) async{
    String? lang;
    if(ja_flag == true){
      lang = 'ja';
    }
    else{
      lang = 'en';
    }
    if(mode == "gallery"){
      await pickImage();
    }
    if(mode == "camera"){
      await pickImageCamera();
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NextPage(image,lang))
    );
  }

  // @override
  // void initState() {
  //   initChatGPT();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light, 
      )
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:true,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment:CrossAxisAlignment.center,
          children: <Widget>[
            const Text("画像と言語を選択してください"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children:<Widget> [
                    Text("日本語"),
                    Checkbox(
                    activeColor: Colors.blue, // Onになった時の色を指定
                    value: ja_flag, // チェックボックスのOn/Offを保持する値
                    onChanged: flagChange_ja, // チェックボックスを押下した際に行う処理
                    ),
                  ]
                ),
                SizedBox(
                  width: 60,
                ),
                Column(
                  children: <Widget>[
                    Text("英語"),
                    Checkbox(
                      activeColor: Colors.blue, // Onになった時の色を指定
                      value: en_flag, // チェックボックスのOn/Offを保持する値
                      onChanged: flagChange_en, // チェックボックスを押下した際に行う処理
                    )
                  ]
                )
              ],
            )
          ],
        )
      ),
      floatingActionButton: Column(
        verticalDirection: VerticalDirection.down,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 16.0),
            child: FloatingActionButton(
              heroTag: "hero1", // HeroTag設定
              onPressed: (){
                main("gallery");
              },
              child: Icon(Icons.photo_album),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 16.0),
            child: FloatingActionButton(
              heroTag: "hero2", // HeroTag設定
              onPressed: (){
                main("camera");
              },
              child: Icon(Icons.photo_camera),
            ),
          )
        ]
      )
    );
  }
}
