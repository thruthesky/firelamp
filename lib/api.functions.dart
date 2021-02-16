part of 'firelamp.dart';

/// Returns filename with extension.
///
/// @example
///   `/root/users/.../abc.jpg` returns `abc.jpg`
///
String getFilenameFromPath(String path) {
  return path.split('/').last;
}

/// Returns a random string
///
///
String getRandomString({int len = 16, String prefix}) {
  const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
  var t = '';
  for (var i = 0; i < len; i++) {
    t += charset[(Random().nextInt(charset.length))];
  }
  if (prefix != null && prefix.isNotEmpty) t = prefix + t;
  return t;
}

/// Returns absolute file path from the relative path.
/// [path] must include the file extension.
/// @example
/// ``` dart
/// localFilePath('photo/baby.jpg');
/// ```
Future<String> getAbsoluteTemporaryFilePath(String relativePath) async {
  var directory = await getTemporaryDirectory();
  return p.join(directory.path, relativePath);
}
