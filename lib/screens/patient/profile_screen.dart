import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text("John Doe"),
                ),
                ListTile(
                  leading: Icon(Icons.cake),
                  title: Text("Age: 25"),
                ),
                ListTile(
                  leading: Icon(Icons.bloodtype),
                  title: Text("Blood Group: O+"),
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text("+91 9876543210"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
