
class AppUser {
  String id;
  String userName;
  String mail;
  String password;  
  String? profileImageUrl;

  AppUser({
    required this.userName,
    required this.mail,
    required this.password,
    required this.id,
    required this.profileImageUrl,
  });

  static Map<String, dynamic> toJson(AppUser user) {
    return {
      'userName': user.userName,
      'mail': user.mail,
      'password': user.password,
      'user_id': user.id,
      'profileImageUrl': user.profileImageUrl,
    };
  }
  
  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      userName: json['userName'] as String,
      mail: json['mail'] as String,
      password: json['password'] as String,
      id: json['user_id'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}
