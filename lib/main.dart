// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'imageEntity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MaterialApp(home: Logbook()));
}

class Logbook extends StatefulWidget {
  const Logbook({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LogbookState();
}

class _LogbookState extends State<Logbook> {
  TextEditingController controller = TextEditingController();

  int current_index = 0;

  List<ImageEntity> images = [];

  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: const Text("Logbook"),
      ),
      body: Column(
        children: [
          StreamBuilder<List<ImageEntity>>(
              stream: getImages(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Error getting snapshots $snapshot"));
                } else if (snapshot.hasData) {
                  images = snapshot.data!;
                  return imageView(images, current_index);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        if (current_index > 0) {
                          current_index--;
                        }
                      });
                    },
                    child: const Icon(Icons.arrow_back)),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        if (current_index < images.length - 1) {
                          current_index++;
                        }
                      });
                    },
                    child: const Icon(Icons.arrow_forward)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: GestureDetector(
              onTap: showAddDialog,
              child: Card(
                color: const Color.fromARGB(255, 10, 124, 255),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text("Add Image"),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    ));
  }

  Future<bool> addImage() async {
    if (_formKey.currentState!.validate()) {
      var image = ImageEntity.newImage(controller.text);
      await FirebaseFirestore.instance.collection("Images").add(image.toJson());
      return true;
    }
    return false;
  }

  showAddDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Add new Image"),
            content: Form(
                key: _formKey,
                child: TextFormField(
                  validator: urlValidator,
                  controller: controller,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.link),
                      labelText: "Url",
                      border: OutlineInputBorder()),
                )),
            actions: [
              TextButton(
                  onPressed: () {
                    controller.text = "";
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () async {
                    if (await addImage()) {
                      controller.text = "";
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add Image")),
            ],
          );
        });
  }

  static String? urlValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "This field cannot be empty";
    } else if (!Uri.parse(value).isAbsolute) {
      return "Invalid URL";
    } else if (!value.endsWith(".jpg")) {
      return "Not an image url!";
    }

    return null;
  }

  //https://docs.flutter.dev/cookbook/images/network-image
  imageView(List<ImageEntity> images, int index) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Image.network(images[index].url,
          width: double.infinity, height: 400, fit: BoxFit.cover),
    );
  }

  getImages() {
    return FirebaseFirestore.instance.collection("Images").snapshots().map(
        (querySnap) => querySnap.docs
            .map((doc) => ImageEntity.fromJson(doc.id, doc.data()))
            .toList());
  }
}
