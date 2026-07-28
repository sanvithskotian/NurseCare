import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  String? selectedGender;
  String? selectedBloodGroup;
  DateTime? selectedDateOfBirth;

  final List<String> genders = [
    "Male",
    "Female",
    "Other",
  ];

  final List<String> bloodGroups = [
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",
  ];

  Future<void> pickDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDateOfBirth = picked;
        dobController.text =
            DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool validateFields() {
    if (nameController.text.trim().isEmpty) {
      showMessage("Please enter your full name");
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      showMessage("Please enter your email");
      return false;
    }

    if (passwordController.text.length < 6) {
      showMessage(
          "Password must contain at least 6 characters");
      return false;
    }

    if (passwordController.text !=
        confirmPasswordController.text) {
      showMessage("Passwords do not match");
      return false;
    }

    if (phoneController.text.length != 10) {
      showMessage("Enter a valid phone number");
      return false;
    }

    if (selectedGender == null) {
      showMessage("Please select gender");
      return false;
    }

    if (selectedBloodGroup == null) {
      showMessage("Please select blood group");
      return false;
    }

    if (selectedDateOfBirth == null) {
      showMessage("Please select date of birth");
      return false;
    }

    if (addressController.text.trim().isEmpty) {
      showMessage("Please enter address");
      return false;
    }

    return true;
  }

  Future<String> generatePatientId() async {
  final counterRef = FirebaseFirestore.instance
      .collection('counters')
      .doc('patientCounter');

  return FirebaseFirestore.instance
      .runTransaction((transaction) async {
    final snapshot = await transaction.get(counterRef);

    int lastNumber = 0;

    if (snapshot.exists) {
      lastNumber = snapshot['lastNumber'];
    }

    lastNumber++;

    transaction.update(counterRef, {
      'lastNumber': lastNumber,
    });

    return "PAT-${lastNumber.toString().padLeft(5, '0')}";
  });
}

  Future<void> registerPatient() async {
    if (!validateFields()) return;

    try {
      setState(() {
        isLoading = true;
      });

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final patientId = await generatePatientId();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'patientId': patientId,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'patient',
        'phone': phoneController.text.trim(),
        'gender': selectedGender,
        'bloodGroup': selectedBloodGroup,
        'dateOfBirth':
            Timestamp.fromDate(selectedDateOfBirth!),
        'address': addressController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showMessage("Patient registered successfully");

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = "Registration failed";

      if (e.code == "email-already-in-use") {
        message = "Email already registered";
      } else if (e.code == "weak-password") {
        message = "Password is too weak";
      } else if (e.code == "invalid-email") {
        message = "Invalid email address";
      }

      showMessage(message);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    dobController.dispose();
    super.dispose();
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Registration"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              const Icon(
                Icons.person_add_alt_1,
                size: 80,
                color: Colors.teal,
              ),

              const SizedBox(height: 15),

              const Text(
                "Create Patient Account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Fill in your details below",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: confirmPasswordController,
                obscureText: hideConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      hideConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        hideConfirmPassword =
                            !hideConfirmPassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: const InputDecoration(
                  labelText: "Gender",
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                items: genders.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedBloodGroup,
                decoration: const InputDecoration(
                  labelText: "Blood Group",
                  prefixIcon: Icon(Icons.bloodtype),
                  border: OutlineInputBorder(),
                ),
                items: bloodGroups.map((group) {
                  return DropdownMenuItem(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBloodGroup = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextField(
                controller: dobController,
                readOnly: true,
                onTap: pickDateOfBirth,
                decoration: const InputDecoration(
                  labelText: "Date of Birth",
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Address",
                  prefixIcon: Icon(Icons.home),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : registerPatient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Register Patient",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}