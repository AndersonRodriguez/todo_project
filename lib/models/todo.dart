import 'package:firebase_database/firebase_database.dart';

class Todo {
  String key;
  String subject;
  bool completed;
  String userId;

  Todo(this.subject, this.userId, this.completed);

  Todo.fromSnapshot(DataSnapshot snapshot) :
    key = snapshot.key,
    subject = snapshot.value['subject'],
    completed = snapshot.value['completed'],
    userId = snapshot.value['userId'];

  toJson() {
    return {
      'subject': subject,
      'completed': completed,
      'userId': userId
    };
  }


}