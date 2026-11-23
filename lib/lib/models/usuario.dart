import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_f/services/db.dart';

class Usuario {
  final String uid, nome, email;
  const Usuario({required this.uid, required this.nome, required this.email});

  void write() async {
    DatabaseReference ref = database.ref('users/$uid');
    try {
      await ref.set(toMap());
    } catch (error) {
      print(error);
    }
  }

  Map toMap() {
    return {"uid": uid, "nome": nome, "email": email};
  }

  factory Usuario.fromMap(Map map) {
    return Usuario(uid: map["uid"], nome: map["nome"], email: map["email"]);
  }

  static Future<Usuario?> read(String uid) async {
    DatabaseReference ref = database.ref('users/$uid');
    DatabaseEvent event = await ref.once();
    if (event.snapshot.exists) {
      Map map = event.snapshot.value as Map;
      map["uid"] = uid;
      return Usuario.fromMap(map);
    } else {
      print("nenhum dado encontrado em 'users/$uid'");
      return null;
    }
  }
}
