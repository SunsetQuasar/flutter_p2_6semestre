import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_f/models/tarefa.dart';
import 'package:flutter_f/models/usuario.dart';
import 'package:flutter_f/services/db.dart';

FirebaseAuth auth = FirebaseAuth.instance;

Usuario? usuario;

class AuthResult {
  AuthResult({required this.uid, required this.error}) {
    //um dos dois tem que ter algum valor (ideal era pra essa classe ser uma união uid | error)
    assert((uid == null) == !(error == null));
  }
  final String? uid;
  final String? error;
}

sealed class Auth {
  Auth._();

  static Future<Usuario?> getUsuario(User user) {
    DatabaseReference ref = database.ref('users/${user.uid}');
    return ref.once().then((event) {
      if (event.snapshot.exists) {
        Map map = event.snapshot.value as Map;
        usuario = Usuario(
          uid: map["uid"],
          nome: map["nome"],
          email: map["email"],
        );
      } else {
        usuario = null;
      }
      return usuario;
    });
  }

  static void escutarAlteracoes() {
    auth.authStateChanges().listen((u) {
      if (u != null) {
        getUsuario(u);
        //atualiza as tarefas e começa a escutar a do novo usuário
        Tarefa.updateTarefas();
        Tarefa.escutarAlteracoes(u);
      } else {
        Tarefa.updateTarefas();
        Tarefa.pararDeEscutar();
      }
    });
  }

  static Future<AuthResult> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Usuário logado: ${userCredential.user?.uid}');
      return AuthResult(uid: userCredential.user?.uid, error: null);
    } on FirebaseAuthException catch (e) {
      print('Erro de login: ${e.message}');
      return AuthResult(uid: null, error: e.message);
    }
  }

  static Future<AuthResult> createUserWithEmailPassword(
    String email,
    String password,
    String nome,
  ) async {

      try {
        UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        print('Usuário criado: ${userCredential.user?.uid}');
        if (userCredential.user?.uid != null) {
          Usuario novo = Usuario(
            uid: userCredential.user!.uid,
            email: email,
            nome: nome,
          );
          novo.write();
          usuario = novo;
          return AuthResult(uid: userCredential.user?.uid, error: null);
        }
      } on FirebaseAuthException catch (e) {
        print('Erro ao criar: ${e.code}');
        return AuthResult(uid: null, error: e.message);
      } 
    return AuthResult(uid: null, error: "desconhecido");
  }

  // Logout
  static Future<bool> signOut() async {
    bool caught = false;
    try {
      await auth.signOut();
    } catch (e) {
      caught = true;
    }

    if (caught) {
      print('Erro ao deslogar.');
    } else {
      print('Usuário deslogado.');
    }

    return !caught;
  }
}
