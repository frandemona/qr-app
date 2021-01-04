import 'services.dart';

/// Static global state. Immutable services that do not care about build context.
class Global {
  // App Data
  static final String title = 'QR Navidad';

  // Data Models
  static final Map models = {
    Attendee: (data, id) => Attendee.fromMap(data, id),
  };

  // Firestore References for Writes
  static final Collection<Attendee> attendeesRef =
      Collection<Attendee>(path: 'attendees');
  static Document<Attendee> attendeeRef(String id) =>
      Document<Attendee>(path: 'attendees/$id');
}
