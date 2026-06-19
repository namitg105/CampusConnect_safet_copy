class Event {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final String location;
  final DateTime date;

  Event({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
  });

  factory Event.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Event(
      id: id,
      groupId: map['groupId'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      date: map['date'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'title': title,
      'description': description,
      'location': location,
      'date': date,
    };
  }
}
