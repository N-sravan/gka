import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';


class CameraWidget extends StatefulWidget {
  const CameraWidget({
    required this.saveCapturedPhoto,
    Key? key
  }) : super(key: key);

  final Function saveCapturedPhoto;

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  final ImagePicker _picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async{
        int? userChoice = await imageUploadTypeAlertDialog();
        if (userChoice != null) {
          XFile? photo;
          if (userChoice == 1) {
            photo = await _picker.pickImage(source: ImageSource.camera);
          } else {
            photo = await _picker.pickImage(source: ImageSource.gallery);
          }
          Uint8List data = await photo!.readAsBytes();
          final directory = await getApplicationDocumentsDirectory();

          String basename = '${const Uuid().v1()}.png';
          await photo.saveTo('${directory.path}/$basename');
          widget.saveCapturedPhoto(photo);
        }
      },
      /*style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(constants.continueButtonColor),
        elevation: MaterialStateProperty.all(4.0),
      ),*/
      icon: const Icon(
        Icons.upload,
        color:  Color(0xFF4BA164),
      ),
    );
  }

  Future<int?> imageUploadTypeAlertDialog() async{
    int? value = await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color(0xFF4BA164)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ))
                    ),
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                        ),
                        Text(
                          'Click from Camera',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                          )
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(const Color(0xFF4BA164)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ))
                      ),
                      onPressed: () {
                        Navigator.pop(context, 2);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.photo,
                            color: Colors.white,
                          ),
                          Text(
                            'Click from Gallery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            )
                          ),
                        ],
                      )
                  )
                ],
              ),
            ),
          );
        }
    );
    return value;
  }

  Future<int?> imageUploadTypeBottomSheet() async{
    int? value = await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text("Click from Camera"),
                  onTap: () {
                    Navigator.pop(context, 1);
                  }
              ),
              ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Select from Gallery"),
                  onTap: () {
                    Navigator.pop(context, 2);
                  }
              )
            ],
          );
        }
    );
    return value;
  }
}
