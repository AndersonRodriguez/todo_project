import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:todo_project/models/todo.dart';
import 'package:todo_project/screens/root_screen/root_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({Key key, @required this.userId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Todo> _todoList;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final TextEditingController _textEditingController = TextEditingController();

  StreamSubscription<Event> _onTodoAddSubcription;
  StreamSubscription<Event> _onTodoChangeSubcription;

  Query _todoQuery;

  @override
  void initState() {
    super.initState();
    _todoList = List();

    _todoQuery = _database
        .reference()
        .child('todo')
        .orderByChild('userId')
        .equalTo(widget.userId);

    _onTodoAddSubcription = _todoQuery.onChildAdded.listen(onEntryAdd);

    _onTodoChangeSubcription = _todoQuery.onChildChanged.listen(onEntryChanged);
  }

  @override
  void dispose() {
    _onTodoAddSubcription.cancel();
    _onTodoChangeSubcription.cancel();
    super.dispose();
  }

  onEntryAdd(Event event) {
    setState(() {
      _todoList.add(Todo.fromSnapshot(event.snapshot));
    });
  }

  onEntryChanged(Event event) {
    var oldEntry = _todoList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _todoList[_todoList.indexOf(oldEntry)] =
          Todo.fromSnapshot(event.snapshot);
    });
  }

  // Elimina la sesion
  signOut() async {
    try {
      await _firebaseAuth.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RootScreen()),
      );
    } catch (e) {
      print(e);
    }
  }

  // Funcion para guardar en la base de datos
  addNewTodo(String todoItem) {
    if (todoItem.length > 0) {
      Todo todo = Todo(todoItem, widget.userId, false);
      _database.reference().child('todo').push().set(todo.toJson());
    }
  }

  // Funcion para editar
  updateTodo(Todo todo) {
    todo.completed = !todo.completed;
    if (todo != null) {
      _database.reference().child('todo').child(todo.key).set(todo.toJson());
    }
  }

  // Funcion para eliminar de la base de datos
  deleteTodo(String todoKey, int index) {
    _database.reference().child('todo').child(todoKey).remove().then((_) {
      setState(() {
        _todoList.removeAt(index);
      });
    });
  }

  // Dialogo para añadir Todo
  showAddTodoDialog(BuildContext context) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Agregar todo',
                    ),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancelar'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Guardar'),
                onPressed: () {
                  addNewTodo(_textEditingController.text.toString());
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 17.0,
                color: Colors.white,
              ),
            ),
            onPressed: signOut,
          )
        ],
      ),
      body: showTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddTodoDialog(context);
        },
        tooltip: 'Agregar a la lista',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget showTodoList() {
    if (_todoList.length > 0) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: _todoList.length,
        itemBuilder: (BuildContext context, int index) {
          String todoKey = _todoList[index].key;
          String todoSubject = _todoList[index].subject;
          bool todoCompleted = _todoList[index].completed;
          return Dismissible(
            key: Key(todoKey),
            background: Container(color: Colors.red),
            onDismissed: (direction) {
              deleteTodo(todoKey, index);
            },
            child: ListTile(
              title: Text(
                todoSubject,
                style: TextStyle(fontSize: 20.0),
              ),
              trailing: IconButton(
                icon: (todoCompleted)
                    ? Icon(
                        Icons.done_outline,
                        color: Colors.green,
                        size: 20.0,
                      )
                    : Icon(
                        Icons.done,
                        color: Colors.grey,
                        size: 20.0,
                      ),
                onPressed: () {
                  updateTodo(_todoList[index]);
                },
              ),
            ),
          );
        },
      );
    } else {
      return Center(
        child: Text(
          'No tienes tareas',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 35.0),
        ),
      );
    }
  }
}
