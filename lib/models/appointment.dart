class Appointment {
  final String id;
  final String patientName;
  final String doctorName;
  final String date;
  String status;

  Appointment({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.date,
    required this.status,
  });
}