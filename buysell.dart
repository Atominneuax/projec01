import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class Buysell extends StatelessWidget {
  final TextEditingController textController = TextEditingController();
  late String action;
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

  Future<void> insertData(BuildContext context, String product_name, String id, double lat, double lng) async {
    final connection = await _connectToDatabase();

    try {
      const query = '''INSERT INTO sellers (seller_id, name, lat, lng) VALUES (?, ?, ?, ?) ''';

      final result = await connection.query(query, [id, product_name, lat, lng]);

      print('Inserted data successfully! ID: ${result.insertId}');
      Navigator.pop(context, {
        'item': textController.text,
      });
    } catch (e) {
      print('Error inserting data: $e');
    } finally {
      await connection.close();
    }
  }

  void search(BuildContext context, String product_name) async {
    final connection = await _connectToDatabase();
    Map sellers = {};
    final results = await connection.query('SELECT * FROM sellers WHERE name="$product_name"');
    final seller_details = await connection.query('SELECT * FROM details');

    String id = '';
    String seller_name = 'x';
    String seller_number = 'x';

    sellers['item'] = product_name;
    int counter = 0;

    for (var row in results) {
      for(var seller_row in seller_details) {
        // print("${row['seller_id']}_${seller_row['id']}");
        if(row['seller_id'].toString() == seller_row['id'].toString()) {
          seller_name = seller_row['name'];
          seller_name = seller_name[0].toUpperCase() + seller_name.substring(1);
          seller_number = seller_row['number'];
          sellers[counter] = "${seller_name}_${seller_number}_${row['lat']}_${row['lng']}";
          counter++;
        }
      }
    }

    Navigator.pop(context, sellers);

    await connection.close();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    action = data['action'];
    return Scaffold(
        appBar: AppBar(
          title: const Text("Buying and Selling"),
        ),
        body: Container(
          padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "What do you want to $action?",
                  style: const TextStyle(
                      fontSize: 20.0
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    prefixIcon: Icon(Icons.monetization_on_outlined),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    if(action == 'sell'){
                      insertData(context, textController.text.trim(),data['id'], data['lat'], data['lng']);
                    }
                    else if(action == 'buy'){
                      search(context, textController.text);
                    }
                  },
                  child: const Text('Go'),
                ),
              ],
            ),
        ),
      );
   }
}
