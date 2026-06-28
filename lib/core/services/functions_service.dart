import 'package:firebase_functions/firebase_functions.dart';

class FunctionsService {
  FunctionsService({FirebaseFunctions? functions}) : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'asia-south1');

  final FirebaseFunctions _functions;

  Future<Map<String, dynamic>> tmdbProxy({required String path, Map<String, dynamic> query = const {}}) async {
    final callable = _functions.httpsCallable('tmdbCallable');
    final result = await callable.call<Map<String, dynamic>>({'path': path, 'query': query});
    return Map<String, dynamic>.from(result.data);
  }
}