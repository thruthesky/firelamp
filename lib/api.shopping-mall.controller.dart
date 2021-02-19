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
    item.options[option].count++;
    update();
    // print('count: ${item.options[option]}');
  }

  decrease(ApiPost item, String option) {
    if (item.options[option].count > 1) {
      item.options[option].count--;
    } else {
      item.options[option].count = 1;
    }
    update();
  }

  delete(ApiPost item, String option) {
    item.options[option].count = 0;
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

  Map<dynamic, dynamic> toMap() {
    final Map m = {};
    for (final item in items) {
      Map selected = {};
      // 주문 옵션. 기본 옵션을 추가한다.
      // '옵션에 금액 추가' 방식에서는 DEFAULT_OPTION 의 개 수가, 상품 구매 개수 이다. 이 때, 옵션을 선택하면, "해당 옵션 가격 * DEFAULT_OPTION 개 수" 를 하면 된다.
      for (final option in item.options.keys) {
        if (item.options[option].count == 0) continue;
        selected[option] = {
          'count': item.options[option].count,
          'price': item.options[option].price,
          'discountRate': item.options[option].discountRate,
        };
      }
      m[item.id] = {
        // 상품(게시글) 번호
        'postTitle': item.postTitle,
        'price': item.price, // 해당 상품 가격
        'discountRate': item.discountRate, // 해당 상품의 할인 율
        'orderPrice': item.priceWithOptions, // 상품 별 옵션 포함 총 주문 가격
        'selectedOptions': selected,
      };
    }
    return m;
  }
}
