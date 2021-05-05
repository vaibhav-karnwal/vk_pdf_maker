import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:another_flushbar/flushbar.dart';


void main() =>runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    )
);
class Home extends StatefulWidget{
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final picker = ImagePicker();
  final pdf = pw.Document();
  List<File> _image=[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: Text('VK PDF Maker'),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: getImageFromGallery,
          )
        ],
      ),
      body:_image !=null ? ListView.builder(
          itemCount: _image.length,
          itemBuilder: (context, index)=>Container(
              width:double.infinity,
              height: 400,
              margin: EdgeInsets.all(8),
              child: Image.file(
                _image[index],
                fit: BoxFit.cover,
              )),
      ):Container(),

      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            createPDF();
            savePDF();
          },
          icon: Icon(Icons.picture_as_pdf),
          label: Text("Create"),
      ),
    );
  }

  getImageFromGallery() async{
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState((){
      if(pickedFile!=null){
        _image.add(File(pickedFile.path));
      } else {
        print("No image selected");
      }
    });
  }

  createPDF() async{
    for(var img in _image) {
      final image = pw.MemoryImage(img.readAsBytesSync());

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context){
            return pw.Center(child: pw.Image(image));
          }));
    }
  }

  savePDF() async{
    try{
      final dir = await getExternalStorageDirectory();
      final file = File('${dir.path}/filename.pdf');
      await file.writeAsBytes(await pdf.save());
      showPrintedMessage('success', 'saved to documents');
    } catch(e) {
      showPrintedMessage('error',e.toString());
    }
  }

  showPrintedMessage(String title, String msg){
    Flushbar(
      title:title,
      message: msg,
      duration: Duration(seconds:3),
      icon: Icon(
        Icons.info,
        color: Colors.blue,
      ),
    )..show(context);
  }
}
