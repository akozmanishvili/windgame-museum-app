class AuthConfig {
  AuthConfig._();

  static const List<String> allowedEmailDomains = ['hendrix.edu'];

  static const int minPasswordLength = 8;

  static String get allowedDomainsLabel =>
      allowedEmailDomains.map((d) => '@$d').join(' or ');

  static bool isAllowedStaffEmail(String email) {
    if (allowedEmailDomains.isEmpty) return true;
    final normalized = email.trim().toLowerCase();
    final at = normalized.lastIndexOf('@');
    if (at <= 0 || at == normalized.length - 1) return false;
    final domain = normalized.substring(at + 1);
    return allowedEmailDomains.contains(domain);
  }
}
