import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _numberController = TextEditingController();

  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _middleNameController = TextEditingController();

  final TextEditingController _lastNameController = TextEditingController();

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

  Future<void> insertData(String firstName, String number, String middleName, String lastName) async {
    final connection = await _connectToDatabase();

    try {
      const query = '''
      INSERT INTO details (name, number, username, password)
      VALUES (?, ?, ?, ?)
    ''';

      final result = await connection.query(query, [firstName.trim(), number.trim(), middleName.trim(), lastName.trim()]);

      print('Inserted data successfully! ID: ${result.insertId}');
    } catch (e) {
      print('Error inserting data: $e');
    } finally {
      await connection.close();
    }
  }

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Account'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Enter Name'),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _numberController,
                  decoration: const InputDecoration(labelText: 'Enter Number'),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _middleNameController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _lastNameController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Enter Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    // Perform account creation here using the input values
                    String firstName = _firstNameController.text;
                    String number = _numberController.text;
                    String middleName = _middleNameController.text;
                    String lastName = _lastNameController.text;

                    // You can add your logic to create the account with the data.
                    // For example, you can save the data to a database, send it to an API, etc.

                    insertData(firstName, number, middleName, lastName);
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ),
        );
    }
}
