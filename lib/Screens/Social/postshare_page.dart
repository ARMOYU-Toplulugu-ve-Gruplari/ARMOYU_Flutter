// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:ARMOYU/Core/AppCore.dart';
import 'package:ARMOYU/Screens/Utility/fullscreenimage_page.dart';
import 'package:ARMOYU/Widgets/buttons.dart';
import 'package:ARMOYU/Functions/API_Functions/posts.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostSharePage extends StatefulWidget {
  final bool appbar;

  const PostSharePage({super.key, required this.appbar});

  @override
  State<PostSharePage> createState() => _PostSharePageState();
}

class _PostSharePageState extends State<PostSharePage>
    with AutomaticKeepAliveClientMixin<PostSharePage> {
  @override
  bool get wantKeepAlive => true;

  TextEditingController textController = TextEditingController();
  TextEditingController postsharetext = TextEditingController();
  List<XFile> imagePath = [];
  bool postshareProccess = false;

  Future<void> sharePost() async {
    if (postshareProccess) {
      return;
    }

    postshareProccess = true;
    FunctionsPosts funct = FunctionsPosts();
    Map<String, dynamic> response =
        await funct.share(textController.text, imagePath);
    if (response["durum"] == 0) {
      postsharetext.text = response["aciklama"].toString();
      postshareProccess = false;
      return;
    }

    if (response["durum"] == 1) {
      postsharetext.text = response["aciklama"].toString();
      postshareProccess = false;

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: widget.appbar
          ? AppBar(
              backgroundColor: Colors.black,
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              // height: 30,
              child: Column(
                children: [
                  TextField(
                    controller: textController,
                    decoration:
                        const InputDecoration(hintText: "Bir şeyler yaz..."),
                    maxLines: null,
                  ),
                  ElevatedButton(
                    // Görsel ekleme alanı

                    onPressed: () async {
                      List<XFile> selectedImages = await AppCore.pickImages();
                      if (selectedImages.isNotEmpty) {
                        setState(() {
                          imagePath.addAll(selectedImages);
                        });
                      }
                    },
                    child: const Text("Görsel Ekle"),
                  ),

                  // Görsellerin önizlemesi
                  if (imagePath.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imagePath.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => FullScreenImagePage(
                                    images: [imagePath[index].path],
                                    initialIndex: 0,
                                    isFile: true,
                                  ),
                                ));
                              },
                              child: Image.file(
                                File(imagePath[index].path),
                                width: 100,
                                height: 100,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: Column(
                children: [
                  CustomButtons()
                      .costum1("Paylaş", sharePost, postshareProccess),
                  const SizedBox(height: 10),
                  Text(postsharetext.text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
