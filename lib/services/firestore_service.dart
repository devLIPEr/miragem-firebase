import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference collections =
      FirebaseFirestore.instance.collection('collections');

  Future<void> create(String name, String img, String uid) {
    return collections.add(
        {'name': name, 'img': img, 'quantity': 0, 'cards': [], 'userId': uid});
  }

  Stream<QuerySnapshot> read(String uid) {
    final collectionsStream =
        collections.where('userId', isEqualTo: uid).snapshots();
    return collectionsStream;
  }

  Future<void> update(String docId, String name, String img) {
    Map<String, String> updatedCollection = {};
    if (name.isNotEmpty) {
      updatedCollection['name'] = name;
    }
    if (img.isNotEmpty) {
      updatedCollection['img'] = img;
    }
    return collections.doc(docId).update(updatedCollection);
  }

  Future<Map<String, dynamic>> getCollection(String docId) {
    return collections
        .doc(docId)
        .get()
        .then((value) => value.data() as Map<String, dynamic>);
  }

  Future<List> getCards(String docId) {
    return collections.doc(docId).get().then((value) {
      Map<String, dynamic> data = value.data() as Map<String, dynamic>;
      return List.from(data['cards']);
    });
  }

  Future<void> addCard(String docId, Map<dynamic, dynamic> card) {
    return collections.doc(docId).update({
      'cards': FieldValue.arrayUnion([card]),
      'quantity': FieldValue.increment(card['quantity'])
    });
  }

  Future<void> removeCard(String docId, Map<dynamic, dynamic> card) {
    return collections.doc(docId).update({
      'cards': FieldValue.arrayRemove([card]),
      'quantity': FieldValue.increment(-card['quantity'])
    });
  }

  Future<void> updateCard(
      String docId, Map<dynamic, dynamic> card, Map<dynamic, dynamic> newCard) {
    removeCard(docId, card);
    return addCard(docId, newCard);
  }

  Future<void> delete(String docId) {
    return collections.doc(docId).delete();
  }
}
