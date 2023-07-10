import 'package:clg_mat/constants/const_colors.dart';
import 'package:clg_mat/widgets/alert_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class FileList extends StatefulWidget {
  String fileId;

  FileList({
    required this.fileId
});

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("files").doc(widget.fileId).snapshots(),
        builder: (context, fileSnapshot) {

          String fileName = fileSnapshot.data!["fileName"];
          String fileDisplayName = fileSnapshot.data!["fileDisplayName"];
          String fileDescription = fileSnapshot.data!["fileDescription"];
          String docLink = fileSnapshot.data!["docLink"];

          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //icon
              const Padding(
                padding:
                EdgeInsets
                    .symmetric(
                    horizontal:
                    10),
                child: Icon(Icons
                    .picture_as_pdf_outlined),
              ),

              //name and description
              InkWell(
                onTap: (){
                  openFile(docUrl:docLink,fileName: fileName);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // file_name
                    Container(
                      height: 20,
                      child: Text(
                        fileDisplayName,
                        style:
                        const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ConstColor.fontBlackk,
                          overflow:
                          TextOverflow
                              .fade,
                        ),
                      ),
                    ),

                    // file_description
                    Container(
                      width: MediaQuery.of(context).size.width/1.5,
                      height: 200,

                      child: Text(
                        fileDescription,
                        style:
                        const TextStyle(
                          fontWeight: FontWeight.normal,
                          overflow:
                          TextOverflow
                              .fade,
                        ),
                      ),
                    ),

                    //photo of file
                    
                  ],
                ),
              )
            ],
          );
        }
    );
  }

  Future openFile({required String docUrl,required String fileName}) async{
    final path = await downloadFile(docUrl, fileName);

    if(path==null){
      AlertMessage(context, Text("file is empty"));
    }else{
      OpenFile.open(path);
    }

  }


  Future<String?> downloadFile(String docUrl, String fileName) async{

    final tempStorage = await getTemporaryDirectory();
    final path = '${tempStorage.path}/$fileName';

    try{
      await Dio().download(docUrl, path);
      return path;
    }catch(error){
      AlertMessage(context, Text(error.toString()));
    }
    return null;
  }
  
  
}
