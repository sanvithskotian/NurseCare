import '../models/patient.dart';
import '../models/doctor.dart';
import '../models/nurse.dart';
import '../models/appointment.dart';
import '../models/prescription.dart';
import '../models/nursing_note.dart';
import '../models/diagnosis.dart';
import '../models/task.dart';

class DummyData {
  static Patient patient = Patient(
    id: "P001",
    name: "John Doe",
    age: 25,
    gender: "Male",
    bloodGroup: "O+",
    phone: "9876543210",
  );

  static Doctor doctor = Doctor(
    id: "D001",
    name: "Dr. Smith",
    specialization: "Cardiology",
  );

  static Nurse nurse = Nurse(
    id: "N001",
    name: "Mary Johnson",
    department: "ICU",
  );

  static List<Appointment> appointments = [
    Appointment(
      id: "A001",
      patientName: "John Doe",
      doctorName: "Dr. Smith",
      date: "1 July 2026",
      status: "Confirmed",
    ),
  ];

  static final List<Prescription> prescriptions = [
    Prescription(
      id: "PR001",
      doctorName: "Dr. Smith",
      medicine: "Paracetamol",
      dosage: "500mg Twice Daily",
      duration: "5 Days",
   ),
  ];

  static final List<NursingNote> nursingNotes = [
    NursingNote(
      id: "NN001",
      nurseName: "Mary Johnson",
      patientName: "John Doe",
      note: "Patient is stable. Vitals are normal.",
      date: "1 July 2026",
   ),
 ];

  static final List<Diagnosis> diagnoses = [
   Diagnosis(
    id: "D001",
    doctorName: "Dr. Smith",
    patientName: "John Doe",
    diagnosis: "Viral Fever",
    date: "1 July 2026",
   ),
  ];
  static final List<Task> tasks = [
   Task(
    id: "T001",
    title: "Check Blood Pressure",
    completed: false,
   ),
   Task(
    id: "T002",
    title: "Give Paracetamol",
    completed: false,
   ),
  ];
}  