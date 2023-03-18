import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:dart_openai/openai.dart';

class NextPage extends StatefulWidget {
  NextPage(XFile? this.image,String? this.lang);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final XFile? image;
  String? lang;

  @override
  State<NextPage> createState() => _NextPageState(image,lang);
}

class _NextPageState extends State<NextPage>{
  _NextPageState(XFile? this.image,String? this.lang);
  XFile? image;
  String? lang;
  final picker = ImagePicker();
  Text result = Text('');
  late OpenAI openAI;
  String answerText = '';

  Future ocr_ja () async {
    final InputImage imageFile = InputImage.fromFilePath(image!.path);
    final textRecognizer =
        TextRecognizer(script: TextRecognitionScript.japanese);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(imageFile);
    String text = '';
    for(TextBlock block in recognizedText.blocks)
    {
      String temp = block.text;
      text = text + temp;
    }
    setState(() {
      result = Text(text.replaceAll('\n', ""));
    });
    textRecognizer.close();
  }

  Future ocr_en () async {
    final InputImage imageFile = InputImage.fromFilePath(image!.path);
    final textRecognizer =
        TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(imageFile);
    String text = '';
    for(TextBlock block in recognizedText.blocks)
    {
      String temp = block.text;
      text = text + temp;
    }
    setState(() {
      result = Text(text.replaceAll('\n', ""));
    });
    textRecognizer.close();
  }
  

  Future listenChatGPT(String message) async{
    answerText = '処理中';
    final chatCompletion = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
              content: "あなたはこれから入力される文章を日本語で要約してください",
              role: "system",
          ),
        OpenAIChatCompletionChoiceMessageModel(
              content: message,
              role: "user",
          ),
      ],
    );
    setState(() {
      answerText = chatCompletion.choices.first.message.toMap()['content'].toString();
    });
  }

  Future main() async{
    if(lang == 'ja'){
      await ocr_ja();
    }
    else{
      await ocr_en();
    }
    listenChatGPT(result.data!);
  }

  @override
  void initState() {
    // TODO: implement initState
    main();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light, 
      )
    );
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Image Picker Example"),
      // ),
      appBar: AppBar(
        automaticallyImplyLeading:true,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, //画面外タップを検知するために必要
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment:CrossAxisAlignment.center,
            children: <Widget>[
              if (image != null) 
                Container(
                  height: 350,
                  child: Image.file(File(image!.path))
                )
              else 
                Text("画像を選択してください",textAlign: TextAlign.center),
              SizedBox(
                height:20,
              ),
              if(result.data != '') Padding(
                padding: EdgeInsets.fromLTRB(20,0,20,0),
                child: TextField(
                  style: TextStyle(
                    fontSize: 12
                  ),
                  minLines: 2,
                  maxLines: 8,
                  controller: TextEditingController(text: result.data),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    labelText: '原文',
                  ),
                )
              ),
              SizedBox(
                height: 30,
              ),
              if(answerText != '') Padding(
                padding: EdgeInsets.fromLTRB(20,0,20,0),
                child: TextField(
                  style: TextStyle(
                    fontSize: 12
                  ),
                  minLines: 5,
                  maxLines: 11,
                  controller: TextEditingController(text: answerText),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(),
                    labelText: '要約',
                  ),
                )
              )
            ],
          ),
        )
      ),
    );
  }
}