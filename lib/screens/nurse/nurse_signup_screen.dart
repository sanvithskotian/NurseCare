import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'nurse_dashboard.dart';

class NurseSignupScreen extends StatefulWidget {
  const NurseSignupScreen({super.key});

  @override
  State<NurseSignupScreen> createState() =>
      _NurseSignupScreenState();
}

class _NurseSignupScreenState
    extends State<NurseSignupScreen> {
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _emailVerified = false;
  bool _isVerifying = false;
  bool _isCreatingAccount = false;

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  String? _nurseName;
  String? _department;

  DocumentSnapshot<Map<String, dynamic>>? _staffDocument;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: const OutlineInputBorder(),
    );
  }

  void _resetVerification() {
    setState(() {
      _emailVerified = false;
      _nurseName = null;
      _department = null;
      _staffDocument = null;

      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> verifyEmail() async {
    final email =
        _emailController.text.trim().toLowerCase();

    _resetVerification();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your approved email.',
          ),
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
          'This email has not been approved by Management.',
        );
      }

      final staffDocument = querySnapshot.docs.first;
      final data = staffDocument.data();

      final role =
          data['role']?.toString().trim().toLowerCase();

      final status =
          data['status']?.toString().trim().toLowerCase();

      if (role != 'nurse') {
        throw Exception(
          'This email is not approved as a Nurse account.',
        );
      }

      if (status != 'pending') {
        throw Exception(
          'This account has already been registered. '
          'Please login instead.',
        );
      }

      if (!mounted) return;

      setState(() {
        _emailVerified = true;
        _nurseName =
            data['name']?.toString() ?? 'Nurse';

        // Supports either field name in Firestore.
        _department =
            data['department']?.toString() ??
            data['ward']?.toString() ??
            'Not assigned';

        _staffDocument = staffDocument;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email verified successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _resetVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst('Exception: ', ''),
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

  Future<void> createNurseAccount() async {
    final email =
        _emailController.text.trim().toLowerCase();

    final password =
        _passwordController.text.trim();

    final confirmPassword =
        _confirmPasswordController.text.trim();

    if (!_emailVerified || _staffDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please verify your approved email first.',
          ),
        ),
      );
      return;
    }

    if (password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter and confirm your password.',
          ),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password must contain at least 6 characters.',
          ),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
        ),
      );
      return;
    }

    setState(() {
      _isCreatingAccount = true;
    });

    User? createdUser;

    try {
      final staffReference =
          _staffDocument!.reference;

      // Fetch the latest approval data again before
      // creating the account.
      final latestStaffDocument =
          await staffReference.get();

      if (!latestStaffDocument.exists) {
        throw Exception(
          'Your staff approval record was not found. '
          'Please contact Management.',
        );
      }

      final latestData =
          latestStaffDocument.data();

      if (latestData == null) {
        throw Exception(
          'Staff approval details could not be read.',
        );
      }

      final latestEmail = latestData['email']
          ?.toString()
          .trim()
          .toLowerCase();

      final latestRole = latestData['role']
          ?.toString()
          .trim()
          .toLowerCase();

      final latestStatus = latestData['status']
          ?.toString()
          .trim()
          .toLowerCase();

      if (latestEmail != email) {
        throw Exception(
          'The verified email has changed. '
          'Please verify it again.',
        );
      }

      if (latestRole != 'nurse') {
        throw Exception(
          'This email is not approved as a Nurse account.',
        );
      }

      if (latestStatus != 'pending') {
        throw Exception(
          'This account has already been registered. '
          'Please login instead.',
        );
      }

      final userCredential = await FirebaseAuth
          .instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      createdUser = userCredential.user;

      if (createdUser == null) {
        throw Exception(
          'The nurse account could not be created.',
        );
      }

      final department =
          latestData['department']?.toString() ??
          latestData['ward']?.toString() ??
          '';

      final userReference = FirebaseFirestore
          .instance
          .collection('users')
          .doc(createdUser.uid);

      final batch =
          FirebaseFirestore.instance.batch();

      batch.set(userReference, {
        'uid': createdUser.uid,
        'name': latestData['name'] ?? '',
        'email': email,
        'phone': latestData['phone'] ?? '',
        'role': 'nurse',
        'department': department,
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.update(staffReference, {
        'status': 'registered',
        'registeredAt':
            FieldValue.serverTimestamp(),
        'userId': createdUser.uid,
      });

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nurse account created successfully.',
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const NurseDashboard(),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      String message;

      switch (error.code) {
        case 'email-already-in-use':
          message =
              'An account already exists with this email. '
              'Please login instead.';
          break;

        case 'invalid-email':
          message =
              'The approved email address is invalid.';
          break;

        case 'weak-password':
          message =
              'Please choose a stronger password.';
          break;

        case 'network-request-failed':
          message =
              'Please check your internet connection.';
          break;

        case 'operation-not-allowed':
          message =
              'Email and password registration is not enabled.';
          break;

        default:
          message =
              'Account creation failed: '
              '${error.message ?? error.code}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error) {
      // Delete the Authentication account if the
      // Firestore operation fails.
      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (_) {
          // Ignore rollback errors.
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst('Exception: ', ''),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nurse Registration'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.medical_services,
              size: 85,
              color: Colors.teal,
            ),

            const SizedBox(height: 16),

            const Text(
              'Create Nurse Account',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your email must first be approved by '
              'hospital management.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _emailController,
              enabled:
                  !_emailVerified && !_isVerifying,
              keyboardType:
                  TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              onSubmitted: (_) {
                if (!_isVerifying &&
                    !_emailVerified) {
                  verifyEmail();
                }
              },
              decoration: inputDecoration(
                'Approved Email',
                Icons.email,
              ),
            ),

            const SizedBox(height: 8),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Use the email approved by the '
                'hospital management for your nurse account.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (!_emailVerified)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isVerifying
                      ? null
                      : verifyEmail,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify Email',
                          style: TextStyle(fontSize: 17),
                        ),
                ),
              ),

            if (_emailVerified) ...[
              const SizedBox(height: 10),

              TextFormField(
                initialValue: _nurseName,
                readOnly: true,
                decoration: inputDecoration(
                  'Nurse Name',
                  Icons.person,
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                initialValue: _department,
                readOnly: true,
                decoration: inputDecoration(
                  'Ward / Department',
                  Icons.apartment,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                obscureText: _isPasswordHidden,
                textInputAction:
                    TextInputAction.next,
                decoration: inputDecoration(
                  'Password',
                  Icons.lock,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordHidden =
                            !_isPasswordHidden;
                      });
                    },
                    icon: Icon(
                      _isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller:
                    _confirmPasswordController,
                obscureText:
                    _isConfirmPasswordHidden,
                textInputAction:
                    TextInputAction.done,
                onSubmitted: (_) {
                  if (!_isCreatingAccount) {
                    createNurseAccount();
                  }
                },
                decoration: inputDecoration(
                  'Confirm Password',
                  Icons.lock_outline,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordHidden =
                            !_isConfirmPasswordHidden;
                      });
                    },
                    icon: Icon(
                      _isConfirmPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isCreatingAccount
                      ? null
                      : createNurseAccount,
                  child: _isCreatingAccount
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 17),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}