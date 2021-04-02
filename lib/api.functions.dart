part of 'firelamp.dart';

extension StringExtension on String {
  int get toInt {
    return int.parse(this);
  }
}

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

/// 예/아니오를 선택하게 하는 다이얼로그를 표시한다.
///
/// 예를 선택하면 true, 아니오를 선택하면 false 를 리턴한다.
Future<bool> confirm(String title, String message) async {
  return await showDialog(
    context: Get.context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                key: ValueKey(FirelampKeys.button.confirmYes),
                onPressed: () => Get.back(result: true),
                child: Text('yes'.tr),
              ),
              TextButton(
                key: ValueKey(FirelampKeys.button.confirmNo),
                onPressed: () => Get.back(result: false),
                child: Text('no'.tr),
              ),
            ],
          )
        ],
      ),
    ),
  );
}

/// Alert message
Future alert(String message) async {
  await Get.defaultDialog(
    title: '알림',
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
    textConfirm: '확인',
    onConfirm: () => Get.back(),
    confirmTextColor: Colors.white,
  );
}

String moneyFormat(dynamic no) {
  return NumberFormat.currency(locale: 'ko_KR', symbol: '').format(no);
}

int discount(int price, int rate) {
  return (price * (100 - rate) / 100).round();
}

bool isImageUrl(t) {
  if (t == null || t == '') return false;
  if (t.startsWith('http://') || t.startsWith('https://')) {
    if (t.endsWith('.jpg') || t.endsWith('.jpeg') || t.endsWith('.gif') || t.endsWith('.png')) {
      return true;
    }
  }
  return false;
}

/// The [birthdate] must be in 'YYMMDD' format. ie) 001122
age(String birthdate) {
  if (birthdate == null || birthdate == '' || birthdate.length != 6) return '0';
  final _yy = int.parse(birthdate.substring(0, 2));
  final _mm = int.parse(birthdate.substring(2, 4));
  final _dd = int.parse(birthdate.substring(4, 6));

  DateTime birthday = DateTime(_yy < 20 ? 2000 + _yy : 1900 + _yy, _mm, _dd);

  DateTime today = DateTime.now();

  AgeDuration _age;

  // Set the age of the user
  _age = Age.dateDifference(fromDate: birthday, toDate: today, includeToDate: false);

  return _age.years.toString();
}

calAge(String birthdate) => age(birthdate);
