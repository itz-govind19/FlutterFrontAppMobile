class SignUpRequest {
  final String name;
  final String username;
  final String password;
  final String email;
  final String mobile;
  final List<String> roles;

  SignUpRequest({
    required this.name,
    required this.username,
    required this.password,
    required this.email,
    required this.mobile,
    this.roles = const ['USER'], // Default role
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'username': username,
    'password': password,
    'email': email,
    'mobile': mobile,
    'roles': roles,
  };
}
