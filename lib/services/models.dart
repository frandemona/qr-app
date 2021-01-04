import 'package:cloud_firestore/cloud_firestore.dart';

class Attendee {
  String id;
  final String comentario;
  final String whatsapp;
  final String sexo;
  final bool qrSent;
  final bool scanned;
  final String qr;
  final String pagadoA;
  final String medioDePago;
  final String lastName;
  final String invitadoDe;
  final String firstName;
  final String email;
  final String dni;
  final String createdBy;
  final Timestamp createdAt;

  Attendee({
    this.id,
    this.comentario,
    this.whatsapp,
    this.sexo,
    this.qrSent,
    this.scanned,
    this.qr,
    this.pagadoA,
    this.medioDePago,
    this.lastName,
    this.invitadoDe,
    this.firstName,
    this.email,
    this.dni,
    this.createdBy,
    this.createdAt,
  });

  factory Attendee.fromMap(Map data, String id) {
    return Attendee(
      id: id ?? '',
      comentario: data['comentario'] ?? '',
      whatsapp: data['whatsapp'] ?? '',
      sexo: data['sexo'] ?? '',
      qrSent: data['qrSent'] ?? true,
      scanned: data['scanned'] ?? false,
      qr: data['qr'] ?? '',
      pagadoA: data['pagadoA'] ?? '',
      medioDePago: data['medioDePago'] ?? '',
      lastName: data['lastName'] ?? '',
      invitadoDe: data['invitadoDe'] ?? '',
      firstName: data['firstName'] ?? '',
      email: data['email'] ?? '',
      dni: data['dni'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
