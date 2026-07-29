import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() =>
      _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specializationController = TextEditingController();
  final _departmentController = TextEditingController();

  String _selectedRole = 'doctor';
  bool _isSaving = false;

  final List<String> doctorSpecializations = [
  'General Physician',
  'Cardiologist',
  'Dermatologist',
  'Neurologist',
  'Orthopedic',
  'Pediatrician',
  'Psychiatrist',
  'Gynecologist',
  'ENT Specialist',
  'Ophthalmologist',
];

final List<String> nurseDepartments = [
  'General Ward',
  'ICU',
  'Emergency',
  'Operation Theatre',
  'Pediatrics',
  'Maternity',
  'Cardiology',
  'Orthopedics',
];

String? _selectedSpecialization;
String? _selectedDepartment;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _saveStaffApproval() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final email = _emailController.text.trim().toLowerCase();

      // Prevent duplicate approved staff entries.
      final existingApproval = await FirebaseFirestore.instance
          .collection('staff_registrations')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (existingApproval.docs.isNotEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A staff approval already exists for this email.',
            ),
          ),
        );
        return;
      }

      // Prevent approval for an email already registered as a user.
      final existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'An account already exists with this email.',
            ),
          ),
        );
        return;
      }

      final currentUser = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('staff_registrations')
          .add({
        'name': _nameController.text.trim(),
        'email': email,
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
        'specialization': _selectedRole == 'doctor'
            ? _selectedSpecialization
            : null,
        'department': _selectedRole == 'nurse'
            ? _selectedDepartment
            : null,
        'status': 'pending',
        'createdBy': currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'registeredAt': null,
      });

      if (!mounted) return;

      _formKey.currentState!.reset();

      setState(() {
        _selectedRole = 'doctor';
        _selectedSpecialization = null;
        _selectedDepartment = null;
      });

      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _selectedSpecialization = null;
      _selectedDepartment = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Staff approval created successfully.',
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Unable to save staff approval.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
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
    final isDoctor = _selectedRole == 'doctor';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Staff Approval'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: _inputDecoration(
                  label: 'Staff Role',
                  icon: Icons.badge_outlined,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'doctor',
                    child: Text('Doctor'),
                  ),
                  DropdownMenuItem(
                    value: 'nurse',
                    child: Text('Nurse'),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedRole = value;
                        });
                      },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                enabled: !_isSaving,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  label: 'Full Name',
                  icon: Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the staff name.';
                  }

                  if (value.trim().length < 3) {
                    return 'Name must contain at least 3 characters.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                enabled: !_isSaving,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: _inputDecoration(
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return 'Please enter an email address.';
                  }

                  final emailPattern = RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                  );

                  if (!emailPattern.hasMatch(email)) {
                    return 'Please enter a valid email address.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                enabled: !_isSaving,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                ),
                validator: (value) {
                  final phone = value?.trim() ?? '';

                  if (phone.isEmpty) {
                    return 'Please enter a phone number.';
                  }

                  if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
                    return 'Please enter a valid 10-digit phone number.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (isDoctor)
                DropdownButtonFormField<String>(
  value: _selectedSpecialization,
  decoration: _inputDecoration(
    label: 'Specialization',
    icon: Icons.medical_services_outlined,
  ),
  items: doctorSpecializations.map((specialization) {
    return DropdownMenuItem(
      value: specialization,
      child: Text(specialization),
    );
  }).toList(),
  onChanged: _isSaving
      ? null
      : (value) {
          setState(() {
            _selectedSpecialization = value;
          });
        },
  validator: (value) {
    if (_selectedRole == 'doctor' && value == null) {
      return 'Please select a specialization.';
    }
    return null;
  },
),

              if (!isDoctor)
                DropdownButtonFormField<String>(
  value: _selectedDepartment,
  decoration: _inputDecoration(
    label: 'Ward / Department',
    icon: Icons.local_hospital_outlined,
  ),
  items: nurseDepartments.map((department) {
    return DropdownMenuItem(
      value: department,
      child: Text(department),
    );
  }).toList(),
  onChanged: _isSaving
      ? null
      : (value) {
          setState(() {
            _selectedDepartment = value;
          });
        },
  validator: (value) {
    if (_selectedRole == 'nurse' && value == null) {
      return 'Please select a ward/department.';
    }
    return null;
  },
),

              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed:
                      _isSaving ? null : _saveStaffApproval,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.person_add_alt_1),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : 'Approve Staff Registration',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'The staff member can use this approved email to complete '
                'their registration and create a password.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}