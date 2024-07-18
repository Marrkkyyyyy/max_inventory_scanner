class UserModel {
  final String? userID;
  final String? name;
  final String? location;

  UserModel({
    this.userID,
    this.name,
    this.location,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userID: json['userID'],
      name: json['name'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'name': name,
      'location': location,
    };
  }

  UserModel copyWith({
    String? userID,
    String? name,
    String? location,
  }) {
    return UserModel(
      userID: userID ?? this.userID,
      name: name ?? this.name,
      location: location ?? this.location,
    );
  }
}
