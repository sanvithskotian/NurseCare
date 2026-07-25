import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'register_screen.dart';
import '../patient/patient_dashboard.dart';
import '../nurse/nurse_dashboard.dart';
import '../doctor/doctor_dashboard.dart';
import '../management/management_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({
    super.key,
    required this.role,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordHidden = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter email and password"),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception("Login failed. User account was not found.");
      }

      final userDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDocument.exists) {
        await FirebaseAuth.instance.signOut();

        throw Exception(
          "User profile not found in Firestore.",
        );
      }

      final userData = userDocument.data();

      if (userData == null || userData['role'] == null) {
        await FirebaseAuth.instance.signOut();

        throw Exception(
          "User role not found in Firestore.",
        );
      }

      final databaseRole =
          userData['role'].toString().trim().toLowerCase();

      final selectedPortalRole =
          widget.role.trim().toLowerCase();

      if (databaseRole != selectedPortalRole) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Access denied. This account belongs to the "
              "$databaseRole portal.",
            ),
          ),
        );

        return;
      }

      if (!mounted) return;

      switch (databaseRole) {
        case 'patient':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const PatientDashboard(),
            ),
          );
          break;

        case 'doctor':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DoctorDashboard(),
            ),
          );
          break;

        case 'nurse':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const NurseDashboard(),
            ),
          );
          break;

        case 'management':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ManagementDashboard(),
            ),
          );
          break;

        default:
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid user role"),
            ),
          );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      String message;

      switch (error.code) {
        case 'invalid-email':
          message = "Please enter a valid email address.";
          break;

        case 'user-not-found':
        case 'invalid-credential':
          message = "Incorrect email or password.";
          break;

        case 'wrong-password':
          message = "Incorrect email or password.";
          break;

        case 'user-disabled':
          message = "This account has been disabled.";
          break;

        case 'too-many-requests':
          message = "Too many attempts. Please try again later.";
          break;

        case 'network-request-failed':
          message = "Please check your internet connection.";
          break;

        default:
          message = "Login failed: ${error.message ?? error.code}";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    } catch (error) {
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
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.role} Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Icon(
              Icons.local_hospital,
              size: 90,
              color: Colors.teal,
            ),

            const SizedBox(height: 20),

            const Text(
              'MediConnect',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${widget.role} Portal',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 35),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: isPasswordHidden,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                if (!isLoading) {
                  loginUser();
                }
              },
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordHidden
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordHidden = !isPasswordHidden;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Forgot Password?'),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : loginUser,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            if (widget.role == "Patient")
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}