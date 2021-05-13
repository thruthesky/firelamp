class ApiSearchKeyStat {
  ApiSearchKeyStat({
    this.keyword,
    this.count,
  });

  String? keyword;
  String? count;

  factory ApiSearchKeyStat.fromJson(MapEntry mapEntry) {
    return ApiSearchKeyStat(keyword: mapEntry.key, count: mapEntry.value);
  }
}
