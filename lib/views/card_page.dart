import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miragem_firebase/common/alert.dart';
import 'package:miragem_firebase/common/custom_colors.dart';
import 'package:miragem_firebase/components/add_button.dart';
import 'package:miragem_firebase/components/custom_button.dart';
import 'package:miragem_firebase/enums/idiom_enum.dart';
import 'package:miragem_firebase/enums/quality_enum.dart';

import '../components/custom_imagepicker.dart';
import '../components/custom_textfield.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class CardPage extends StatefulWidget {
  final String collectionId;
  final String collectionName;

  const CardPage(this.collectionId, this.collectionName, {super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseAuthService authService = FirebaseAuthService();
  final FirestoreService firestoreService = FirestoreService();

  Map<String, dynamic> collectionData = {};

  String collectionName = "";
  List cards = [];
  Idiom cardIdiom = Idiom.PT;
  Quality cardQuality = Quality.NM;
  String cardName = "";
  String cardImage = "";
  String cardQuantity = "";

  bool editing = false;
  bool bottomSheetOnScreen = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController qntController = TextEditingController();

  Widget builtCards = Container();

  int cardsAdded = 0;

  @override
  void initState() {
    super.initState();

    collectionName = widget.collectionName;
    getAllCards();
  }

  void getAllCards() async {
    collectionData = await firestoreService.getCollection(widget.collectionId);
    setState(() {
      cards = collectionData['cards'];
      builtCards = buildCards(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: 100.0,
        backgroundColor: Colors.transparent,
        flexibleSpace: const Image(
          image: AssetImage('assets/imgs/appbarBG.jpg'),
          fit: BoxFit.cover,
        ),
        title: Text(
          collectionName,
          style: TextStyle(color: CustomColors.dark, fontSize: 32.0),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: CustomColors.background,
      floatingActionButton: AddButton(onPressed: (context) {
        bottomSheetOnScreen = true;
        addCard(context, -1);
      }),
      body: builtCards,
    );
  }

  void addCard(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Map<dynamic, dynamic> card =
                ((index == -1) ? {} : cards[index]) as Map<dynamic, dynamic>;
            if (bottomSheetOnScreen && (index != -1) && !editing) {
              cardImage = card['img'];
              cardIdiom = Idiom.fromValue(card['idiom']);
              cardQuality = Quality.fromValue(card['quality']);
              cardQuantity = card['quantity'].toString();
              cardName = card['name'];
              nameController.text = cardName;
              qntController.text = cardQuantity;
              editing = true;
            } else if (bottomSheetOnScreen && !editing) {
              cardImage = "";
              cardIdiom = Idiom.PT;
              cardQuality = Quality.NM;
              cardQuantity = "";
              cardName = "";
              nameController.text = cardName;
              qntController.text = cardQuantity;
              editing = true;
            }
            return BottomSheet(
              onClosing: () {
                cardIdiom = Idiom.PT;
                cardQuality = Quality.NM;
                cardImage = "";
                cardQuantity = "";
                cardName = "";
                editing = false;
              },
              backgroundColor: CustomColors.highlight,
              builder: (context) {
                const double height = 60.0;

                List<Widget> buttons = [
                  CustomButton(
                    height: height,
                    width: 100.0,
                    text: "Salvar",
                    textColor: CustomColors.dark,
                    onTap: () {
                      if (cardName == "") {
                        customAlert(
                          context,
                          "O campo nome da carta é obrigatório",
                          25.0,
                          "Insira um nome para salvar",
                          20.0,
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
                                    color: CustomColors.light, fontSize: 16.0),
                              ),
                            )
                          ],
                        );
                      } else {
                        Map<String, dynamic> newCard = {};
                        newCard['name'] = cardName;
                        newCard['quality'] = cardQuality.value;
                        newCard['quantity'] =
                            cardQuantity == "" ? 0 : int.parse(cardQuantity);
                        newCard['idiom'] = cardIdiom.value;
                        newCard['img'] = cardImage;
                        if (index != -1) {
                          firestoreService.updateCard(
                              widget.collectionId, card, newCard);
                        } else {
                          firestoreService.addCard(
                              widget.collectionId, newCard);
                        }
                        getAllCards();
                        editing = false;
                        Navigator.pop(context);
                      }
                    },
                  ),
                ];
                if (index != -1) {
                  buttons.add(
                    CustomButton(
                      height: height,
                      width: 100.0,
                      text: "Excluir",
                      textColor: Colors.red,
                      onTap: () {
                        customAlert(
                          context,
                          "Tem certeza?",
                          24.0,
                          "Você tem certeza que quer excluir a carta ${cards[index]['name']}?\nEste processo não pode ser revertido!",
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
                                firestoreService.removeCard(
                                    widget.collectionId, cards[index]);
                                getAllCards();
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
                    ),
                  );
                }
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: CustomTextField(
                        controller: nameController,
                        height: height,
                        width: MediaQuery.of(context).size.width * 0.9,
                        hintText: "Nome da carta",
                        obscureText: false,
                        onChanged: (value) {
                          cardName = value;
                        },
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: SizedBox(
                        height: height,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: height,
                              width: MediaQuery.of(context).size.width * 0.425,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: CustomColors.light,
                              ),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<Quality>(
                                        value: cardQuality,
                                        items: const [
                                          DropdownMenuItem(
                                              value: Quality.M,
                                              child: Text("M")),
                                          DropdownMenuItem(
                                              value: Quality.NM,
                                              child: Text("NM")),
                                          DropdownMenuItem(
                                              value: Quality.SP,
                                              child: Text("SP")),
                                          DropdownMenuItem(
                                              value: Quality.MP,
                                              child: Text("MP")),
                                          DropdownMenuItem(
                                              value: Quality.HP,
                                              child: Text("HP")),
                                          DropdownMenuItem(
                                              value: Quality.D,
                                              child: Text("D")),
                                        ],
                                        onChanged: (choice) {
                                          setState(() {
                                            cardQuality = (choice == null)
                                                ? Quality.M
                                                : choice;
                                          });
                                        },
                                        dropdownColor: CustomColors.light,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.05),
                            CustomTextField(
                              controller: qntController,
                              height: height,
                              width: MediaQuery.of(context).size.width * 0.425,
                              hintText: "Quantidade",
                              obscureText: false,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                cardQuantity = value;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: SizedBox(
                        height: height,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: height,
                              width: MediaQuery.of(context).size.width * 0.425,
                              decoration: BoxDecoration(
                                color: CustomColors.light,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: DropdownButton<Idiom>(
                                      alignment: Alignment.centerRight,
                                      value: cardIdiom,
                                      items: const [
                                        DropdownMenuItem(
                                            value: Idiom.PT, child: Text("PT")),
                                        DropdownMenuItem(
                                            value: Idiom.EN, child: Text("EN")),
                                        DropdownMenuItem(
                                            value: Idiom.JP, child: Text("JP")),
                                      ],
                                      onChanged: (choice) {
                                        setState(() {
                                          cardIdiom = (choice == null)
                                              ? Idiom.PT
                                              : choice;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.05),
                            CustomImagePicker(
                              onTap: () {
                                return ImagePicker()
                                    .pickImage(source: ImageSource.gallery)
                                    .then((file) {
                                  if (file != null) {
                                    setState(() {
                                      cardImage = file.path;
                                    });
                                    return file.path;
                                  }
                                });
                              },
                              height: height,
                              width: MediaQuery.of(context).size.width * 0.425,
                              image: cardImage,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: buttons,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    ).then((value) {
      setState(() {
        editing = false;
        bottomSheetOnScreen = false;
      });
    });
  }

  Widget buildCards(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(15.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15.0,
        mainAxisSpacing: 15.0,
        childAspectRatio: 63.0 / 88.0,
      ),
      itemCount: cards.length + 1,
      itemBuilder: (context, index) {
        if (index == cards.length) {
          return GestureDetector(
            onTap: () {
              bottomSheetOnScreen = true;
              addCard(context, -1);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: CustomColors.highlight,
              ),
              child: const Icon(
                Icons.add,
                color: CustomColors.dark,
                size: 65.0,
              ),
            ),
          );
        } else {
          Map<String, dynamic> card = cards[index];
          return GestureDetector(
            onTap: () {
              bottomSheetOnScreen = true;
              addCard(context, index);
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    backgroundColor: Colors.transparent,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Image.file(
                          File(card['img']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: card['img'] != ""
                          ? FileImage(File(card['img']))
                          : const AssetImage("assets/imgs/questionMark.png")
                              as ImageProvider,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                Positioned(
                  bottom: 10.0,
                  right: 0.0,
                  child: Container(
                    color: CustomColors.light,
                    child: Text(
                      "${card['quantity']}x",
                      style: const TextStyle(
                        fontSize: 22.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
