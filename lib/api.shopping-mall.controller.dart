part of './firelamp.dart';

class Receiver {
  String name;
  String phoneNo1;
  String phoneNo2;
  String phoneNo3;
  String address1;
  String address2;
  String memo;
}

class Cart extends GetxController {
  ApiPost currentItem;
  List<ApiPost> items = [];
  Receiver receiver = Receiver();

  empty() {
    items = [];
    update();
  }

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
    /// 아이템 복사. 카트에 들어간 아이템은 변경이 되면 안되고, 동일한 상품도 중복으로 넣을 수 있어야 히기 때문에, 현재 아이템을 복사해서 카트에 넣어야 한다.
    ApiPost clone = ApiPost.fromJson(item.data);
    item.options.keys.forEach((k) {
      /// ApiItemOption 도 레퍼런스로 연결되기 때문에, 복제를 해야 한다.
      clone.options[k] = ApiItemOption(
          count: item.options[k].count,
          discountRate: item.options[k].discountRate,
          price: item.options[k].price,
          text: item.options[k].text);
    });

    items.add(clone);
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

  /// 옵션 또는 상품 자체를 카트에서 삭제한다.
  ///
  /// 동일한 상품이 카트에 여러개 들어가 있을 수 있으니, 상품(글) 번호로 삭제를 하기 어려워서, 제목을 null 로 해 놓고, 삭제를 한다.
  delete(ApiPost item, [String option]) {
    if (option != null) {
      item.options[option].count = 0;
    } else {
      item.postTitle = null;
      items.removeWhere((i) => i.postTitle == null);
    }
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

  /// 호환성을 위해서 orderItems 를 입력 받음.
  ///
  /// orderItems 가 없으면, [items] 를 가지고 Json 문자열을 만드는데,
  /// toJson([item]) 와 같이 하나의 아이템만 전달해서, Json 문자열을 만들 수 있다. 특히, 바로 구매를 할 때 1개만 주문 할 때 편하다.
  toJson({List<ApiPost> orderItems}) {
    if (orderItems == null) orderItems = items;
    final List m = [];
    for (final item in orderItems) {
      // 상품 정보.
      // (게시글) 번호 및 상품에 대한 정보 저장.
      m.add(serializeItem(item));
    }
    return jsonEncode(m);
  }

  serializeItem(ApiPost item) {
    Map selected = {};
    // 주문 옵션. 기본 옵션을 추가한다.
    // '옵션에 금액 추가' 방식에서는 DEFAULT_OPTION 의 개 수가, 상품 구매 개수 이다. 이 때, 옵션을 선택하면, "해당 옵션 가격 * DEFAULT_OPTION 개 수" 를 하면 된다.
    for (final option in item.options.keys) {
      if (item.options[option].count == 0) continue;
      selected[option] = jsonEncode({
        'count': item.options[option].count,
        'price': item.options[option].price,
        'discountRate': item.options[option].discountRate,
      });
    }
    // 상품 정보.
    // (게시글) 번호 및 상품에 대한 정보 저장.
    return jsonEncode({
      'postId': item.id,
      'optionItemPrice': item.optionItemPrice,
      'postTitle': item.postTitle, // 상품 제목
      'price': item.price, // 해당 상품 가격
      'discountRate': item.discountRate, // 해당 상품의 할인 율
      'orderPrice': item.priceWithOptions, // 상품 별 옵션 포함 총 주문 가격
      'selectedOptions': selected,
    });
  }
}