import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateNurseTaskScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const CreateNurseTaskScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<CreateNurseTaskScreen> createState() =>
      _CreateNurseTaskScreenState();
}

class _CreateNurseTaskScreenState
    extends State<CreateNurseTaskScreen> {
  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _instructionsController =
      TextEditingController();

  bool _isLoadingNurses = true;
  bool _isCreatingTask = false;

  List<Map<String, String>> _assignedNurses = [];

  String? _selectedNurseId;
  String? _selectedNurseName;

  String _selectedPriority = 'medium';

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadAssignedNurses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignedNurses() async {
    try {
      final patientDocument = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.patientId)
          .get();

      if (!patientDocument.exists) {
        throw Exception('Patient record was not found.');
      }

      final patientData = patientDocument.data();

      if (patientData == null) {
        throw Exception('Patient data could not be read.');
      }

      final nurseIds = List<String>.from(
        patientData['assignedNurseIds'] ?? [],
      );

      if (nurseIds.isEmpty) {
        throw Exception(
          'No nurses are assigned to this patient.',
        );
      }

      final nurseList = <Map<String, String>>[];

      for (final nurseId in nurseIds) {
        final nurseDocument = await FirebaseFirestore.instance
            .collection('users')
            .doc(nurseId)
            .get();

        if (!nurseDocument.exists) {
          continue;
        }

        final nurseData = nurseDocument.data();

        if (nurseData == null) {
          continue;
        }

        final role = nurseData['role']
            ?.toString()
            .trim()
            .toLowerCase();

        if (role != 'nurse') {
          continue;
        }

        nurseList.add({
          'id': nurseId,
          'name':
              nurseData['name']?.toString() ?? 'Nurse',
        });
      }

      if (nurseList.isEmpty) {
        throw Exception(
          'Assigned nurse accounts could not be found.',
        );
      }

      if (!mounted) return;

      setState(() {
        _assignedNurses = nurseList;
        _isLoadingNurses = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingNurses = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      lastDate: now.add(
        const Duration(days: 365),
      ),
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  Future<void> _selectDueTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime:
          _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedTime = pickedTime;
    });
  }

  DateTime? _getCombinedDueDateTime() {
    if (_selectedDate == null ||
        _selectedTime == null) {
      return null;
    }

    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  Future<void> _createTask() async {
    final title = _titleController.text.trim();

    final instructions =
        _instructionsController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task title.'),
        ),
      );
      return;
    }

    if (instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter task instructions.',
          ),
        ),
      );
      return;
    }

    if (_selectedNurseId == null ||
        _selectedNurseName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select an assigned nurse.',
          ),
        ),
      );
      return;
    }

    final dueDateTime = _getCombinedDueDateTime();

    if (dueDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select both due date and due time.',
          ),
        ),
      );
      return;
    }

    if (dueDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Due date and time must be in the future.',
          ),
        ),
      );
      return;
    }

    final currentDoctor =
        FirebaseAuth.instance.currentUser;

    if (currentDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Doctor account is not signed in.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isCreatingTask = true;
    });

    try {
      final doctorDocument = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(currentDoctor.uid)
          .get();

      if (!doctorDocument.exists) {
        throw Exception(
          'Doctor profile was not found.',
        );
      }

      final doctorData = doctorDocument.data();

      if (doctorData == null) {
        throw Exception(
          'Doctor profile could not be read.',
        );
      }

      final doctorRole = doctorData['role']
          ?.toString()
          .trim()
          .toLowerCase();

      if (doctorRole != 'doctor') {
        throw Exception(
          'Only doctors can create nurse tasks.',
        );
      }

      final patientDocument = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(widget.patientId)
          .get();

      if (!patientDocument.exists) {
        throw Exception(
          'Patient record was not found.',
        );
      }

      final patientData = patientDocument.data();

      if (patientData == null) {
        throw Exception(
          'Patient data could not be read.',
        );
      }

      final assignedDoctorId =
          patientData['assignedDoctorId']
              ?.toString();

      if (assignedDoctorId != currentDoctor.uid) {
        throw Exception(
          'You are not assigned to this patient.',
        );
      }

      final assignedNurseIds = List<String>.from(
        patientData['assignedNurseIds'] ?? [],
      );

      if (!assignedNurseIds.contains(
        _selectedNurseId,
      )) {
        throw Exception(
          'The selected nurse is no longer assigned '
          'to this patient.',
        );
      }

      await FirebaseFirestore.instance
          .collection('nurse_tasks')
          .add({
        'title': title,
        'instructions': instructions,

        'patientId': widget.patientId,
        'patientName': widget.patientName,
        'patientCustomId':
            patientData['patientId']?.toString() ?? '',

        'nurseId': _selectedNurseId,
        'nurseName': _selectedNurseName,

        'doctorId': currentDoctor.uid,
        'doctorName':
            doctorData['name']?.toString() ?? 'Doctor',

        'priority': _selectedPriority,
        'status': 'pending',

        'dueAt': Timestamp.fromDate(dueDateTime),
        'createdAt': FieldValue.serverTimestamp(),
        'startedAt': null,
        'completedAt': null,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nurse task created successfully.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
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
          _isCreatingTask = false;
        });
      }
    }
  }

  String _formatSelectedDate() {
    if (_selectedDate == null) {
      return 'Select Due Date';
    }

    final day =
        _selectedDate!.day.toString().padLeft(2, '0');

    final month =
        _selectedDate!.month.toString().padLeft(2, '0');

    return '$day/$month/${_selectedDate!.year}';
  }

  String _formatSelectedTime() {
    if (_selectedTime == null) {
      return 'Select Due Time';
    }

    return _selectedTime!.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Nurse Task'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  widget.patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle:
                    const Text('Selected Patient'),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                prefixIcon:
                    Icon(Icons.assignment_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _instructionsController,
              minLines: 3,
              maxLines: 5,
              textInputAction:
                  TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Instructions',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            if (_isLoadingNurses)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedNurseId,
                decoration: const InputDecoration(
                  labelText: 'Assign Nurse',
                  prefixIcon:
                      Icon(Icons.local_hospital),
                  border: OutlineInputBorder(),
                ),
                items: _assignedNurses.map((nurse) {
                  return DropdownMenuItem<String>(
                    value: nurse['id'],
                    child: Text(
                      nurse['name'] ?? 'Nurse',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  final selectedNurse =
                      _assignedNurses.firstWhere(
                    (nurse) => nurse['id'] == value,
                  );

                  setState(() {
                    _selectedNurseId = value;
                    _selectedNurseName =
                        selectedNurse['name'];
                  });
                },
              ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'low',
                  child: Text('Low'),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: 'high',
                  child: Text('High'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedPriority = value;
                });
              },
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDueDate,
                    icon: const Icon(
                      Icons.calendar_today,
                    ),
                    label: Text(
                      _formatSelectedDate(),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDueTime,
                    icon:
                        const Icon(Icons.access_time),
                    label: Text(
                      _formatSelectedTime(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isCreatingTask
                    ? null
                    : _createTask,
                child: _isCreatingTask
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
                        'Create Task',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}