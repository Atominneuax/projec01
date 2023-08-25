import 'package:flutter/material.dart';
import 'package:hello_world/createAccount.dart';
import 'package:hello_world/login.dart';
import 'package:hello_world/home.dart';
import 'package:hello_world/buysell.dart';
import 'package:hello_world/editDetails.dart';
import 'package:firebase_core/firebase_core.dart';
import 'api/firebase_api.dart';

// void main() => runApp(MaterialApp(
//   initialRoute: '/',
//   routes: {
//     '/': (context){return LoginPage();},
//     '/createAccount': (context){return CreateAccountPage();},
//     '/home': (context){return Home();},
//     '/buysell': (context){return Buysell();},
//     '/editDetails': (context){return EditDetailsPage();},
//   },
// ));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  return runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context){return LoginPage();},
      '/createAccount': (context){return CreateAccountPage();},
      '/home': (context){return Home();},
      '/buysell': (context){return Buysell();},
      '/editDetails': (context){return EditDetailsPage();},
    },
  ));
}

