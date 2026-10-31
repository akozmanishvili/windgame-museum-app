class AppUser {
  const AppUser({required this.uid, required this.email, this.displayName});

  final String uid;
  final String email;
  final String? displayName;

  String get greetingName {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }
}
