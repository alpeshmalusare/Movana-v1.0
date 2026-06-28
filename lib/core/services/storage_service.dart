import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadUserFile({required String userId, required File file, required String fileName}) async {
    final ref = _storage.ref('users/$userId/$fileName');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }

  Future<String> uploadAdminAsset({required File file, required String fileName}) async {
    final ref = _storage.ref('public/admin/$fileName');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }
}