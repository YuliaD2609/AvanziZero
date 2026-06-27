class UserModel {
  final String id;
  final String email;
  final String name;
  final List<String>
      groupIds; // Definisce le case dell'utente
  final List<String>
      pendingGroupIds; // Definisce le richieste in sospeso

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.groupIds,
    this.pendingGroupIds = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      groupIds: List<String>.from(data['groupIds'] ?? []),
      pendingGroupIds: List<String>.from(data['pendingGroupIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'groupIds': groupIds,
      'pendingGroupIds': pendingGroupIds,
    };
  }
}
