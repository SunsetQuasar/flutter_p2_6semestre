import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

FirebaseApp firebaseApp = Firebase.app();
FirebaseDatabase database = FirebaseDatabase.instanceFor(app: firebaseApp, databaseURL: 'https://p2-6sem-un-default-rtdb.firebaseio.com/'); 

sealed class Database {
  Database._();

  static void init() {
    database.setPersistenceEnabled(true);
  }
}
