part of './firelamp.dart';

class Cart extends GetxController {
  ApiPost currentItem;
  List<ApiPost> items = [];

  setCurrentItem(ApiPost item) {
    currentItem = item;
    currentItem.addDefaultOption();
  }

  /// 현재 상품에 옵션을 추가한다.
  ///
  /// [ApiPost.addOption] 은 그냥 모데일이다. 이 함수에는 상태관리가 없어서, re-build 를 못한다.
  /// 그래서, [Cart] 에서 대신 currentItem.addOption() 을 호출하고, re-build 해 준다.
  addOption(String option) {
    currentItem.addOption(option);
    update();
  }

  save(ApiPost item) {
    items.add(item);
  }

  increase(ApiPost item, String option) {
    item.optionCount[option]++;
    update();
    print('count: ${item.optionCount[option]}');
  }

  decrease(ApiPost item, String option) {
    if (item.optionCount[option] > 1) {
      item.optionCount[option]--;
    } else {
      item.optionCount[option] = 1;
    }
    update();
  }

  delete(ApiPost item, String option) {
    // ? 기본 옵션을 삭제해야하나?
    item.optionCount.remove(option);
    update();
  }

  /// 카트에 저장된 전체 상품의 금액
  ///
  /// [item] 이 null 이면, 전체 총 주문 금액
  String price({ApiPost item}) {
    int _price = 0;
    if (item == null) {
      for (final item in items) {
        _price += item.priceWithOptions;
      }
    } else {
      _price = item.priceWithOptions;
    }
    return moneyFormat(_price);
  }

  @override
  String toString() {
    String str = '';
    for (final item in items) {
      str += '${item.id} => $item, ';
    }
    return str;
  }
}
