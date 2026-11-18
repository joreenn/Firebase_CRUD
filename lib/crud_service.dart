import 'package:cloud_firestore/cloud_firestore.dart';

class CrudService {
  CrudService(FirebaseFirestore firestore)
    : _items = firestore.collection('items');

  final CollectionReference<Map<String, dynamic>> _items;

  Stream<QuerySnapshot<Map<String, dynamic>>> getItems() {
    return _items.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addItem(String name, int quantity) async {
    await _items.add({
      'name': name,
      'quantity': quantity,
      'createdAt': Timestamp.now(),
      'isFavorite': false,
    });
  }

  Future<void> updateItem(String id, String name, int quantity) {
    return _items.doc(id).update({'name': name, 'quantity': quantity});
  }

  Future<void> deleteItem(String id) {
    return _items.doc(id).delete();
  }

  Future<void> setFavorite(String id, bool isFavorite) {
    return _items.doc(id).update({'isFavorite': isFavorite});
  }
}
