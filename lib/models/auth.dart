class User {
  final String? name;
  final String? email;

  User({this.name, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
      };
}

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final String? tokenType;
  final User? user;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Common API response shapes
    final token =
        (json['access_token'] ?? json['token'] ?? json['accessToken']) as String?;
    final refresh = json['refresh_token'] as String?;
    final type = json['token_type'] as String?;

    // Try to infer user object if present
    final userJson = (json['user'] is Map)
        ? json['user'] as Map<String, dynamic>
        : <String, dynamic>{
            'name': json['name'],
            'email': json['email'],
          };

    return AuthResponse(
      accessToken: token ?? '',
      refreshToken: refresh,
      tokenType: type,
      user: (userJson.values.any((e) => e != null)) ? User.fromJson(userJson) : null,
    );
  }
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  AuthException(this.message, {this.statusCode});

  @override
  String toString() => 'AuthException($statusCode): $message';
}
