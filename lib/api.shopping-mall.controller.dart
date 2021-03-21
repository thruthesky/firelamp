part of './firelamp.dart';

class CartForm {
  String name;
  String phoneNo1;
  String phoneNo2;
  String phoneNo3;
  String address1;
  String address2;
  String memo;

  @override
  String toString() {
    return "name: $name, phone: $phoneNo1 $phoneNo2 $phoneNo3, address1: $address1, address2: $address2, memo: $memo";
  }

  Map<String, dynamic> get toMap {
    return {
      'name': name,
      'phoneNo': '$phoneNo1-$phoneNo2-$phoneNo3',
      'address1': address1,
      'address2': address2,
      'memo': memo,
    };
  }
}

class Cart extends GetxController {
  ApiPost currentItem;
  List<ApiPost> items = [];
  CartForm form = CartForm();

  int pointToUse = 0;
  int deliveryFeeFreeLimit = 0;
  int _deliveryFeePrice = 0;

  int get deliveryFeePrice => priceInt() >= deliveryFeeFreeLimit ? 0 : _deliveryFeePrice;

  /// 결제(구매) 페이지에서 최종 결제 금액 제시
  int get paymentAmount => priceInt() + deliveryFeePrice - pointToUse;

  // int get point => _point =

  @override
  void onInit() {
    super.onInit();
    loadOptions();
    // print('cartLoadOptions');
  }

  clear() {
    items = [];
    currentItem = null;
    update();
  }

  /// 상품 페이지를 열었을 때, 현재 상품을 지정한다. 상품 페이지를 열었을 때만(때 마다) 한번 사용.
  setCurrentItem(ApiPost item) {
    item.resetOptions();
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

  /// ! call by reference 로 인해서 items.add() 로 바로 하면 안되고, save() 를 통해서 저장해야한다.
  /// @todo ApiPost.itemClone() 함수를 만들 것.
  /// @todo 그래서, items 는 private 으로 되어야 한다.
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
  /// 옵션에 상품가격지정을 하는 경우, 옵션을 다 삭제했으면, 상품 자체를 카트에서 삭제한다.
  delete(ApiPost item, [String option]) {
    if (option != null) {
      item.options[option].count = 0;
      if (item.selectedOptions.length == 0) {
        items.removeWhere((item) => item.priceWithOptions == 0);
      }
    } else {
      item.title = null;
      items.removeWhere((i) => i.title == null);
    }
    update();
  }

  /// 카트에 저장된 전체 상품의 금액
  ///
  /// [item] 이 null 이면, 전체 총 주문 금액. 카트에 저장된 상품들의 금액. 배송비나 사용포인트는 적용되지 않은 금액.
  String price({ApiPost item}) {
    return moneyFormat(priceInt(item: item));
  }

  int priceInt({ApiPost item}) {
    int _price = 0;
    if (item != null) {
      _price = item.priceWithOptions;
    } else {
      for (final item in items) {
        _price += item.priceWithOptions;
      }
    }
    return _price;
  }

  int pointToSave({ApiPost item}) {
    int _point = 0;

    // _point = item.pointWithOptions(
    //   item.point,
    // );
    // point = _point;
    // return _point;

    if (item != null) {
      _point = item.pointWithOptions(item.point);
    } else {
      for (final item in items) {
        _point += item.pointWithOptions(item.point);
      }
    }
    return _point;
  }

  /// 포인트 사용
  ///
  /// * 포인트를 사용 한 다음, 회원 정보에서 포인트를 차감해 주어야 한다.
  usePoint(int point) {
    pointToUse = point;
    print('usePoint: $pointToUse');
    update();
  }

  //결제 금액 계산
  // caculateAmout() {
  //   int _deliveryFeePrice = priceInt() >= deliveryFeeFreeLimit ? 0 : deliveryFeePrice;

  //   paymentAmount = priceInt() + _deliveryFeePrice - pointToUse;
  // }

  loadOptions() async {
    try {
      final re = await Api.instance.request({'route': 'shopping-mall.options'});
      deliveryFeeFreeLimit = int.parse("${re['deliveryFeeFreeLimit']}");
      _deliveryFeePrice = int.parse("${re['deliveryFeePrice']}");
      // print('deliveryFeeFreeLimit: $deliveryFeeFreeLimit');
      // print('deliveryFeePrice: $_deliveryFeePrice');
      // print(re);

    } catch (e) {
      print('앗! 쇼핑몰 설정 정보를 가져오는데 실패했습니다. 에러메시지: ');
      print(e);
      rethrow;
    }
  }

  @override
  String toString() {
    String str = 'Cart.toString() :: ';
    for (final item in items) {
      str += '${item.idx} => $item, ';
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
    return m;
  }

  serializeItem(ApiPost item) {
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
    // 상품 정보.
    // (게시글) 번호 및 상품에 대한 정보 저장.
    return {
      'postIdx': item.idx,
      'optionItemPrice': item.optionItemPrice,
      'title': item.title, // 상품 제목
      'price': item.price, // 해당 상품 가격
      'discountRate': item.discountRate, // 해당 상품의 할인 율
      'orderPrice': item.priceWithOptions, // 상품 별 옵션 포함 총 주문 가격
      'selectedOptions': selected,
    };
  }
}
