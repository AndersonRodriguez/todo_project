import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_project/screens/login/login_screen.dart';
import 'package:todo_project/utils/load_screen.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;

  String _userId = '';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getCurretUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }

        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;

        print('Estado de autenticacion $authStatus');
      });
    });
  }

  // Esta funcion verifica que existe un usuario logeado
  Future<FirebaseUser> getCurretUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return LoadScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return LoginScreen();
        break;
      case AuthStatus.LOGGED_IN:
        return Container();
        break;
      default: 
        return Container();
        break;
    }
  }
}
