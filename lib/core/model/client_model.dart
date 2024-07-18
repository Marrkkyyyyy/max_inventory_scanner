class ClientModel {
  String? clientID;
  String? name;
  String? accountID;

  ClientModel({
    this.clientID,
    this.name,
    this.accountID,
  });

  ClientModel.fromJson(Map<String, dynamic> json) {
    clientID = json['clientID'];
    name = json['name'];
    accountID = json['accountID'];
  }

  Map<String, dynamic> toJson() {
    return {
      'clientID': clientID,
      'name': name,
      'accountID': accountID,
    };
  }
}
