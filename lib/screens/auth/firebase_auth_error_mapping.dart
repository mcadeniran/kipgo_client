import 'package:firebase_auth/firebase_auth.dart';
import 'package:kipgo/l10n/app_localizations.dart';

extension FirebaseAuthErrorMapping on FirebaseAuthException {
  String toReadableMessage(AppLocalizations loc) {
    switch (code) {
      case 'invalid-email':
        return loc.invalidEmailAddress;
      case 'user-disabled':
        return loc.accountHasBeenDisabled;
      case 'user-not-found':
        return loc.noAccountExists;
      case 'wrong-password':
        return loc.incorrectPasswordError;
      case 'email-already-in-use':
        return loc.anAccountAlreadyExists;
      case 'weak-password':
        return loc.thePasswordIsTooWeak;
      case 'operation-not-allowed':
        return loc.operationNotAllowed;
      case 'too-many-requests':
        return loc.tooManyRequests;
      case 'invalid-credential':
        return loc.invalidCredentials;
      case 'network-request-failed':
        return loc.networkRequestFailed;
      default:
        return message ?? loc.authenticationErrorOccurred;
    }
  }
}
