import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  int calculateAge(DateTime dateOfBirth) {
    final today = DateTime.now();

    int age = today.year - dateOfBirth.year;

    final birthdayNotReached =
        today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month &&
            today.day < dateOfBirth.day);

    if (birthdayNotReached) {
      age--;
    }

    return age;
  }

  Widget buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.teal,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: currentUser == null
          ? const Center(
              child: Text("User is not logged in"),
            )
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Unable to load profile",
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return const Center(
                    child: Text(
                      "Patient profile not found",
                    ),
                  );
                }

                final patient = snapshot.data!.data()
                    as Map<String, dynamic>;

                final String name =
                    patient['name']?.toString() ??
                        'Not available';

                final String email =
                    patient['email']?.toString() ??
                        currentUser.email ??
                        'Not available';

                final String phone =
                    patient['phone']?.toString() ??
                        'Not available';

                final String gender =
                    patient['gender']?.toString() ??
                        'Not available';

                final String bloodGroup =
                    patient['bloodGroup']?.toString() ??
                        'Not available';

                final String address =
                    patient['address']?.toString() ??
                        'Not available';

                final String patientId =
                    patient['patientId']?.toString() ??
                        'Not assigned';

                String formattedDateOfBirth =
                    'Not available';

                String ageText = 'Not available';

                final dynamic dateValue =
                    patient['dateOfBirth'];

                if (dateValue is Timestamp) {
                  final DateTime dateOfBirth =
                      dateValue.toDate();

                  formattedDateOfBirth =
                      DateFormat('dd MMMM yyyy')
                          .format(dateOfBirth);

                  ageText =
                      '${calculateAge(dateOfBirth)} Years';
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 48,
                                backgroundColor:
                                    Colors.teal.shade100,
                                child: const Icon(
                                  Icons.person,
                                  size: 55,
                                  color: Colors.teal,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Patient",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.teal
                                      .withValues(
                                          alpha: 0.10),
                                  borderRadius:
                                      BorderRadius.circular(
                                    12,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      "Patient ID",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      patientId,
                                      style: const TextStyle(
                                        color: Colors.teal,
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildInfoTile(
                        icon: Icons.email_outlined,
                        title: "Email",
                        value: email,
                      ),
                      buildInfoTile(
                        icon: Icons.phone_outlined,
                        title: "Phone Number",
                        value: phone,
                      ),
                      buildInfoTile(
                        icon: Icons.person_outline,
                        title: "Gender",
                        value: gender,
                      ),
                      buildInfoTile(
                        icon: Icons.bloodtype_outlined,
                        title: "Blood Group",
                        value: bloodGroup,
                      ),
                      buildInfoTile(
                        icon: Icons.cake_outlined,
                        title: "Age",
                        value: ageText,
                      ),
                      buildInfoTile(
                        icon: Icons.calendar_month_outlined,
                        title: "Date of Birth",
                        value: formattedDateOfBirth,
                      ),
                      buildInfoTile(
                        icon: Icons.home_outlined,
                        title: "Address",
                        value: address,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
    );
  }
}