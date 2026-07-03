import '../models/patient.dart';
import '../models/doctor.dart';
import '../models/nurse.dart';
import '../models/appointment.dart';

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
      date: "10 July 2026",
      status: "Confirmed",
    ),
  ];
}