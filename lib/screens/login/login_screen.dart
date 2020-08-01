import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_project/screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email;
  String _password;

  String _errorMessege;

  bool _isLoginForm;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _errorMessege = '';
    _isLoading = false;
    _isLoginForm = true;
  }

  // Reinicia el formulario
  void resetForm() {
    _formKey.currentState.reset();
    _errorMessege = '';
  }

  // Cambia el tipo de formulario
  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  // Validamos el formulario y hacemos el submit
  bool validateForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save(); // Realiza la asignacion a las variables email y password
      return true;
    }

    return false;
  }

  // Funcion de envio
  void submit() async {
    setState(() {
      _errorMessege = '';
      _isLoading = true;
    });

    if (validateForm()) {
      AuthResult user;
      String userId = '';

      try {
        if (_isLoginForm) {
          user = await _auth.signInWithEmailAndPassword(
              email: _email, password: _password);
          userId = user.user.uid;
          print('Inicio con: $userId');
        } else {
          user = await _auth.createUserWithEmailAndPassword(
              email: _email, password: _password);
          userId = user.user.uid;
          print('Usuario creado: $userId');
        }

        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userId: userId)),
          );
        }
      } catch (error) {
        print('Error: $error');
        setState(() {
          _isLoading = false;
          _errorMessege = error.message;
          _formKey.currentState.reset();
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Stack(
        children: <Widget>[
          _showForm(),
          _showCircularProggres(),
        ],
      ),
    );
  }

  Widget _showCircularProggres() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      height: 0,
      width: 0,
    );
  }

  Widget _showForm() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Hero(
              tag: 'hero',
              child: FlutterLogo(
                size: 150.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Correo',
                  icon: Icon(
                    Icons.mail,
                    color: Colors.grey,
                  ),
                ),
                validator: (value) => value.isEmpty ? 'Email incorrecto' : null,
                onSaved: (value) => _email = value.trim(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: TextFormField(
                maxLines: 1,
                obscureText: true,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  icon: Icon(
                    Icons.lock,
                    color: Colors.grey,
                  ),
                ),
                validator: (value) =>
                    value.isEmpty ? 'Contraseña incorrecta' : null,
                onSaved: (value) => _password = value.trim(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: SizedBox(
                height: 40.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  color: Colors.blue,
                  child: Text(
                    _isLoginForm ? 'Login' : 'Crear',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: submit,
                ),
              ),
            ),
            FlatButton(
              child: Text(
                _isLoginForm ? 'Crear cuenta' : 'Inicar sesión',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
              onPressed: toggleFormMode,
            ),
            (_errorMessege.length > 0 && _errorMessege != null)
                ? Text(
                    _errorMessege,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.red,
                      height: 1.0,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                : Container(
                    height: 0,
                  ),
          ],
        ),
      ),
    );
  }
}
