import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class EditDetailsPage extends StatefulWidget {
  @override
  State<EditDetailsPage> createState() => _EditDetailsPageState();
}

class _EditDetailsPageState extends State<EditDetailsPage> {
  late final TextEditingController _numberController = TextEditingController();

  late final TextEditingController _firstNameController = TextEditingController();

  late final TextEditingController _middleNameController = TextEditingController();

  late final TextEditingController _lastNameController = TextEditingController();

  Map data = {};

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

  Future<void> getDetails (String id) async {
    final connection = await _connectToDatabase();

    final results = await connection.query('SELECT * FROM details WHERE id="$id"');

    for(var row in results){
      _firstNameController.text = row['name'];
      _numberController.text = row['number'];
      _middleNameController.text = row['username'];
    }
  }

  Future<void> updateData(BuildContext context, String id, String firstName, String number, String middleName, String lastName) async {
    final connection = await _connectToDatabase();
    bool redirect = false;

    String query;

    if(lastName == ''){
      query = "UPDATE details SET name='$firstName', number='$number', username='$middleName' WHERE id='$id'";
    }

    else{
      query = "UPDATE details SET name='$firstName', number='$number', username='$middleName', password='$lastName' WHERE id='$id'";
    }

    try {
      // final query = "UPDATE details SET name='$firstName', number='$number', username='$middleName' WHERE id='$id'";

      final result = await connection.query(query);

      print('Updated data successfully! ID: ${result.insertId}');
      redirect = true;
    } catch (e) {
      print('Error inserting data: $e');
    } finally {
      await connection.close();
    }

    if(redirect == true){
      Navigator.pop(context, {
        'name': firstName,
        'number': number,
        'username': middleName,
      });
    }
  }

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    getDetails(data['id']);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account Details'),
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

                updateData(context, data['id'], firstName, number, middleName, lastName);
              },
              child: const Text('Edit Account'),
            ),
          ],
        ),
      ),
    );
  }
}
