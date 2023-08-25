import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class LoginPage extends StatefulWidget {

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  String authText = '';

  Future<MySqlConnection> _connectToDatabase() async {
    final settings = ConnectionSettings(
      host: 'srv901.hstgr.io', // Replace with your MySQL host
      port: 3306, // Replace with your MySQL port (default is 3306)
      user: 'u714842824_rodney', // Replace with your MySQL username
      password: 'Rodney123', // Replace with your MySQL password
      db: 'u714842824_rodney', // Replace with your MySQL database name
    );
    return await MySqlConnection.connect(settings);
  }

  void auth(String u, String p, BuildContext context) async {
    final connection = await _connectToDatabase();
    late String name;
    late String number;
    late String id;

    final results = await connection.query('SELECT * FROM details');
    bool redirect = false;

    for (var row in results) {
      // Access data in each row using row[columnName]
      var username = row['username'];
      var password = row['password'];

      if(username == u.trim() && password == p.trim()){
        id = row['id'].toString();
        name = row['name'];
        number = row['number'];
        redirect = true;
        break;
      }
    }

    if(redirect){
      Navigator.pushReplacementNamed(context, '/home', arguments: {
        'id': id,
        'name': name,
        'number': number
      });
      // return true;
    }
    else{
      // Navigator.pushReplacementNamed(context, '/home');
      print("Incorrect password");
      setState(() {
        authText = 'Incorrect Useername or Password';
      });
      // return false;
    }

    await connection.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage('assets/sellit.png'),
                      backgroundColor: Colors.transparent,
                      radius: 50,
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Text(
                      authText,
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 15
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        // Perform login action here
                        // Navigator.pushReplacementNamed(context, '/home');
                        String username = usernameController.text;
                        String password = passwordController.text;

                        auth(username, password, context);
                      },
                      child: const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to the registration page
                        Navigator.pushNamed(context,'/createAccount');
                      },
                      child: const Text('Create an account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    }
}
