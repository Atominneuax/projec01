import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class CustomDrawer extends StatefulWidget {

  late String id;
  late String name;
  late String number;
  late String username;

  CustomDrawer({required this.id, required this.name, required this.number, required this.username});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {

  late String name = widget.name;
  late String number = widget.number;
  late String username = widget.username;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 230,
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10,0,0,0),
              child: ListView(
                  children: <Widget>[
                    const Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: AssetImage('assets/sellit.png'),
                          backgroundColor: Colors.transparent,
                          radius: 30,
                        ),
                        Text(
                          "Sell It",
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      ]
                    ),
                    const SizedBox(height: 25.0),
                    Text(
                      "Name: $name",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white
                      ),
                    ),
                    Text(
                      "Number: $number",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white
                      ),
                    ),
                    Text(
                      "Username: $username",
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white
                      ),
                    ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Handle the Home menu item tap
              Navigator.pop(context); // Close the Drawer
              // Add navigation logic here
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Edit Details'),
            onTap: () async {
              dynamic result = await Navigator.pushNamed(context, '/editDetails', arguments: {
                'id': widget.id,
              });

              print(result);

              setState(() {
                name = result['name'];
                number = result['number'];
                username = result['username'];
              });

              // Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              // Handle the Settings menu item tap
              Navigator.pushReplacementNamed(context, '/'); // Close the Drawer
              // Add navigation logic here
            },
          ),
          // Add more menu items as needed
        ],
      ),
    );
  }
}
