export '../data/local/database.dart' show AppLog;

class AppLogCategory {
  AppLogCategory._();

  static const info = 'INFO';
  static const warning = 'WARNING';
  static const error = 'ERROR';
  static const sync = 'SYNC';
  static const upload = 'UPLOAD';
  static const firebase = 'FIREBASE';
  static const auth = 'AUTH';
  static const network = 'NETWORK';

  static const values = [
    info,
    warning,
    error,
    sync,
    upload,
    firebase,
    auth,
    network,
  ];
}

class AppLogLevel {
  AppLogLevel._();

  static const info = 'INFO';
  static const warning = 'WARNING';
  static const error = 'ERROR';
}
