class User {
  int? userId;
  String? userName;
  String? userPassword;

  User({this.userId, this.userName, this.userPassword});

  User.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    userPassword = json['userPassword'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['userName'] = userName;
    data['userPassword'] = userPassword;
    return data;
  }

  @override
  String toString() {
    return userName!;
  }
}
