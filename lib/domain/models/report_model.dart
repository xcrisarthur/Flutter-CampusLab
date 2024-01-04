// report_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String nrpOrNim;
  final DateTime date;
  final String description;
  final String id;
  final String location;
  final String nama;

  Report({
    required this.nrpOrNim,
    required this.date,
    required this.description,
    required this.id,
    required this.location,
    required this.nama,
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      nrpOrNim: map['NRP/NIM'],
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'],
      id: map['id'],
      location: map['location'],
      nama: map['nama'],
    );
  }
}