import 'dart:convert';

class Band {
  final String id;
  final String name;
  final int votes;

  Band({required this.id, required this.name, required this.votes})
      : assert(id != null, name != null),
        assert(votes != null);

  factory Band.fromMap(Map<String, dynamic> obj) =>
      Band(id: obj['id'], name: obj['name'], votes: obj['votes']);
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'votes': votes};
  }
}
