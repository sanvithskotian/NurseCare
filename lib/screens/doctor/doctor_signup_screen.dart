import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'doctor_dashboard.dart';

class DoctorSignupScreen extends StatefulWidget {
  const DoctorSignupScreen({super.key});

  @override
  State<DoctorSignupScreen> createState() =>
      _DoctorSignupScreenState();
}

class _DoctorSignupScreenState
    extends State<DoctorSignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  bool _emailVerified = false;
  bool _isVerifying = false;
  bool _isCreatingAccount = false;

  String? _doctorName;
  String? _specialization;

  DocumentSnapshot<Map<String, dynamic>>? _staffDocument;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> verifyEmail() async {
  final email = _emailController.text.trim().toLowerCase();

  setState(() {
    _emailVerified = false;
    _doctorName = null;
    _specialization = null;
    _staffDocument = null;
  });

  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please enter your approved email."),
      ),
    );
    return;
  }

  setState(() {
    _isVerifying = true;
  });

  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('staff_registrations')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception(
        "This email has not been approved by Management.",
      );
    }

    final staffDoc = querySnapshot.docs.first;
    final data = staffDoc.data();

    if (data['role'] != 'doctor') {
      throw Exception(
        "This email is not approved as a Doctor account.",
      );
    }

    if (data['status'] != 'pending') {
      throw Exception(
        "This account has already been registered. Please login instead.",
      );
    }

    setState(() {
      _emailVerified = true;
      _doctorName = data['name'];
      _specialization = data['specialization'];
      _staffDocument = staffDoc;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Email verified successfully."),
      ),
    );
  } catch (error) {
  if (!mounted) return;

  setState(() {
    _emailVerified = false;
    _doctorName = null;
    _specialization = null;
    _staffDocument = null;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        error.toString().replaceFirst('Exception: ', ''),
      ),
    ),
  );
} finally {
    if (mounted) {
      setState(() {
        _isVerifying = false;
      });
    }
  }
}

Future<void> createDoctorAccount() async {
  final email = _emailController.text.trim().toLowerCase();
  final password = _passwordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();

  if (!_emailVerified || _staffDocument == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please verify your approved email first."),
      ),
    );
    return;
  }

  if (password.isEmpty || confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please enter and confirm your password."),
      ),
    );
    return;
  }

  if (password.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password must contain at least 6 characters."),
      ),
    );
    return;
  }

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Passwords do not match."),
      ),
    );
    return;
  }

  setState(() {
    _isCreatingAccount = true;
  });

  User? createdUser;

  try {
    final staffReference = _staffDocument!.reference;

    // Re-check the approval document before creating the account.
    final latestStaffDocument = await staffReference.get();

    if (!latestStaffDocument.exists) {
      throw Exception(
        "Your staff approval record was not found. Please contact Management.",
      );
    }

    final latestData =
        latestStaffDocument.data() as Map<String, dynamic>?;

    if (latestData == null) {
      throw Exception("Staff approval details could not be read.");
    }

    final latestEmail =
        latestData['email']?.toString().trim().toLowerCase();

    final latestRole =
        latestData['role']?.toString().trim().toLowerCase();

    final latestStatus =
        latestData['status']?.toString().trim().toLowerCase();

    if (latestEmail != email) {
      throw Exception(
        "The verified email has changed. Please verify it again.",
      );
    }

    if (latestRole != 'doctor') {
      throw Exception(
        "This email is not approved as a Doctor account.",
      );
    }

    if (latestStatus != 'pending') {
      throw Exception(
        "This account has already been registered. Please login instead.",
      );
    }

    final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    createdUser = userCredential.user;

    if (createdUser == null) {
      throw Exception("The doctor account could not be created.");
    }

    final userReference = FirebaseFirestore.instance
        .collection('users')
        .doc(createdUser.uid);

    final batch = FirebaseFirestore.instance.batch();

    batch.set(userReference, {
      'uid': createdUser.uid,
      'name': latestData['name'],
      'email': email,
      'phone': latestData['phone'] ?? '',
      'role': 'doctor',
      'specialization': latestData['specialization'] ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(staffReference, {
      'status': 'registered',
      'registeredAt': FieldValue.serverTimestamp(),
      'userId': createdUser.uid,
    });

    await batch.commit();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Doctor account created successfully."),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const DoctorDashboard(),
      ),
      (route) => false,
    );
  } on FirebaseAuthException catch (error) {
    if (!mounted) return;

    String message;

    switch (error.code) {
      case 'email-already-in-use':
        message =
            "An account already exists with this email. Please login instead.";
        break;

      case 'invalid-email':
        message = "The approved email address is invalid.";
        break;

      case 'weak-password':
        message = "Please choose a stronger password.";
        break;

      case 'network-request-failed':
        message = "Please check your internet connection.";
        break;

      case 'operation-not-allowed':
        message = "Email and password registration is not enabled.";
        break;

      default:
        message =
            "Account creation failed: ${error.message ?? error.code}";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (error) {
    // Remove the Authentication account if Firestore saving failed.
    if (createdUser != null) {
      try {
        await createdUser.delete();
      } catch (_) {
        // Ignore rollback errors here.
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString().replaceFirst('Exception: ', ''),
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isCreatingAccount = false;
      });
    }
  }
}

  InputDecoration inputDecoration(
      String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Sign Up"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
  controller: _emailController,
  enabled: !_emailVerified && !_isVerifying,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.done,
  autocorrect: false,
  decoration: inputDecoration(
    "Approved Email",
    Icons.email,
  ),
),

const SizedBox(height: 8),

const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    "Use the email approved by the hospital management.",
    style: TextStyle(
      fontSize: 13,
      color: Colors.grey,
    ),
  ),
),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
  onPressed: _isVerifying ? null : verifyEmail,
  child: _isVerifying
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
      : const Text("Verify Email"),
),
            ),

            if (_emailVerified) ...[

              const SizedBox(height: 30),

              TextFormField(
                initialValue: _doctorName,
                enabled: false,
                decoration: inputDecoration(
                  "Doctor Name",
                  Icons.person,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                initialValue: _specialization,
                enabled: false,
                decoration: inputDecoration(
                  "Specialization",
                  Icons.medical_services,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: inputDecoration(
                  "Password",
                  Icons.lock,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: inputDecoration(
                  "Confirm Password",
                  Icons.lock_outline,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: SizedBox(
  width: double.infinity,
  height: 52,
  child: ElevatedButton(
    onPressed:
        _isCreatingAccount ? null : createDoctorAccount,
    child: _isCreatingAccount
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Text(
            "Create Account",
            style: TextStyle(fontSize: 17),
          ),
  ),
),
              ),
            ]
          ],
        ),
      ),
    );
  }
}