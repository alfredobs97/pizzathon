import 'package:firebase_auth/firebase_auth.dart';

extension UserExtension on User {
  bool get isAdmin {
    final adminEmails = [
      'baldizzone42@gmail.com',
      'alfredobautista1@gmail.com',
      'salvajeguerrero@gmail.com',
      'salvapizzalover@gmail.com',
    ];
    return adminEmails.contains(email);
  }

  String get nameToSave {
    if (displayName == email) {
      return email?.split('@').firstOrNull ?? "";
    }

    return displayName ?? "";
  }
}
