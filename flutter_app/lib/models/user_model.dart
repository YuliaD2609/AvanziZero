class UserModel {
  final String id;
  final String email;
  final String name;
  final List<String> groupIds; // Elenco degli ID delle case a cui appartiene l'utente

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.groupIds,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      groupIds: List<String>.from(data['groupIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'groupIds': groupIds,
    };
  }
}
