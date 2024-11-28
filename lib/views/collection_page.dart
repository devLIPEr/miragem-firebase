import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miragem_firebase/common/alert.dart';
import 'package:miragem_firebase/common/custom_colors.dart';
import 'package:miragem_firebase/components/add_button.dart';
import 'package:miragem_firebase/components/custom_button.dart';
import 'package:miragem_firebase/components/custom_imagepicker.dart';
import 'package:miragem_firebase/components/custom_textfield.dart';
import 'package:miragem_firebase/services/firebase_auth_service.dart';
import 'package:miragem_firebase/services/firestore_service.dart';
import 'package:miragem_firebase/views/card_page.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseAuthService authService = FirebaseAuthService();
  final FirestoreService firestoreService = FirestoreService();
  TextEditingController nameController = TextEditingController();
  bool collectionEdited = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100.0,
        backgroundColor: Colors.transparent,
        flexibleSpace: const Image(
          image: AssetImage('assets/imgs/appbarBG.jpg'),
          fit: BoxFit.cover,
        ),
        title: const Text(
          "COLEÇÕES",
          style: TextStyle(color: CustomColors.dark, fontSize: 32.0),
        ),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
              onPressed: authService.signOut, icon: const Icon(Icons.logout, color: CustomColors.dark,))
        ],
      ),
      floatingActionButton: AddButton(
        onPressed: showOpts,
      ),
      body: WillPopScope(
        onWillPop: () async => false,
        child: Container(
          color: CustomColors.background,
          child: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.read(user!.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List collections = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: collections.length,
                  itemBuilder: (context, index) =>
                      collectionCard(context, collections[index]),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget collectionCard(BuildContext context, DocumentSnapshot collection) {
    Map<String, dynamic> data = collection.data() as Map<String, dynamic>;
    return GestureDetector(
      onTap: () {
        showEditOpts(context, collection);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        color: CustomColors.highlight,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: data['img'] != ''
                        ? FileImage(File(data['img']))
                        : const AssetImage("assets/imgs/questionMark.png")
                            as ImageProvider,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8 - 100.0,
                      child: Text(
                        data['name'],
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: CustomColors.light,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      "${data['quantity']} Cartas",
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: CustomColors.light,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showEditOpts(BuildContext context, DocumentSnapshot collection) {
    Map<String, dynamic> data = collection.data() as Map<String, dynamic>;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              color: CustomColors.highlight,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomButton(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardPage(
                            collection.id,
                            data['name'],
                          ),
                        ),
                      );

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    height: 60.0,
                    width: MediaQuery.of(context).size.width * 0.9,
                    text: "Visualizar",
                    textColor: CustomColors.dark,
                  ),
                  const SizedBox(height: 16.0),
                  CustomButton(
                    onTap: () {
                      Navigator.pop(context);
                      showOpts(context, collection: collection);
                    },
                    height: 60.0,
                    width: MediaQuery.of(context).size.width * 0.9,
                    text: "Editar",
                    textColor: CustomColors.dark,
                  ),
                  const SizedBox(height: 16.0),
                  CustomButton(
                    onTap: () {
                      customAlert(
                        context,
                        "Tem certeza?",
                        24.0,
                        "Você tem certeza que quer excluir a coleção ${data['name']}?\nEste processo não pode ser revertido!",
                        20.0,
                        [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.dark),
                            child: const Text(
                              "Cancelar",
                              style: TextStyle(
                                color: CustomColors.light,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              firestoreService.delete(collection.id);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.alert),
                            child: const Text(
                              "Deletar",
                              style: TextStyle(
                                color: CustomColors.light,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    height: 60.0,
                    width: MediaQuery.of(context).size.width * 0.9,
                    text: "Deletar",
                    textColor: CustomColors.dark,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showOpts(BuildContext context, {DocumentSnapshot? collection}) {
    String name = "";
    String img = "";
    nameController.text = "";
    if (collection != null) {
      Map<String, dynamic> data = collection.data() as Map<String, dynamic>;
      nameController.text = data['name'];
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return SingleChildScrollView(
              child: Padding(
                // https://stackoverflow.com/questions/53869078/how-to-move-bottomsheet-along-with-keyboard-which-has-textfieldautofocused-is-t
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  color: CustomColors.highlight,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        controller: nameController,
                        hintText: "Nome da Coleção...",
                        obscureText: false,
                        keyboardType: TextInputType.text,
                        height: 60.0,
                        width: MediaQuery.of(context).size.width * 0.9,
                        onChanged: (value) {
                          collectionEdited = true;
                          name = value;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      CustomImagePicker(
                        onTap: () {
                          return ImagePicker()
                              .pickImage(source: ImageSource.gallery)
                              .then(
                            (file) {
                              if (file != null) {
                                img = file.path;
                                return file.path;
                              }
                              return "";
                            },
                          );
                        },
                        height: 60.0,
                        width: MediaQuery.of(context).size.width * 0.9,
                        image: "",
                      ),
                      const SizedBox(height: 16.0),
                      CustomButton(
                        onTap: () async {
                          if (nameController.text.isNotEmpty) {
                            if (collection != null) {
                              await firestoreService.update(
                                  collection.id, name, img);
                            } else {
                              await firestoreService.create(
                                  name, img, user!.uid);
                            }
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                          } else {
                            customAlert(
                              context,
                              "O nome da coleção é obrigatório",
                              22.0,
                              "",
                              0,
                              [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: CustomColors.dark),
                                  child: const Text(
                                    "Ok!",
                                    style: TextStyle(
                                        color: CustomColors.light,
                                        fontSize: 16.0),
                                  ),
                                )
                              ],
                            );
                          }
                        },
                        height: 60.0,
                        width: 100.0,
                        text: "Salvar",
                        textColor: CustomColors.dark,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
