import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import '../patient/patient_dashboard.dart';
import '../nurse/nurse_dashboard.dart';
import '../doctor/doctor_dashboard.dart';
import '../management/management_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      final email = FirebaseAuth.instance.currentUser!.email!;

final query = await FirebaseFirestore.instance
    .collection('users')
    .where('email', isEqualTo: email)
    .get();

if (query.docs.isEmpty) {
  throw Exception("User role not found");
}

final role = query.docs.first['role'];

if (role == "patient" && widget.role == "Patient") {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const PatientDashboard(),
    ),
  );
} else if (role == "doctor" && widget.role == "Doctor") {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const DoctorDashboard(),
    ),
  );
} else if (role == "nurse" && widget.role == "Nurse") {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const NurseDashboard(),
    ),
  );
} else if (role == "management" &&
    widget.role == "Management") {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const ManagementDashboard(),
    ),
  );
} else {
  await FirebaseAuth.instance.signOut();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        "Access denied for this portal",
      ),
    ),
  );
}
     } on FirebaseAuthException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Error: ${e.code}"),
    ),
  );
}
     finally {
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
                    ? const CircularProgressIndicator(color: Colors.white)
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