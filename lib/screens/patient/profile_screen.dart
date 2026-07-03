import 'package:flutter/material.dart';
import '../../services/dummy_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patient = DummyData.patient;

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
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: Text("Patient ID: ${patient.id}"),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(patient.name),
                ),
                ListTile(
                  leading: const Icon(Icons.cake),
                  title: Text("Age: ${patient.age}"),
                ),
                ListTile(
                  leading: const Icon(Icons.male),
                  title: Text("Gender: ${patient.gender}"),
                ),
                ListTile(
                  leading: const Icon(Icons.bloodtype),
                  title: Text("Blood Group: ${patient.bloodGroup}"),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text("+91 ${patient.phone}"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}