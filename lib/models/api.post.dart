part of '../firelamp.dart';

/// The [ApiItemOption] is for shopping mall function.
///
/// Option(or item) has its price and discount rate.
/// The [text] is a widget to display how to explain about the option.
///
/// @see https://docs.google.com/document/d/1JnEIoytM1MgS35emOju90qeDoIH963VeMHLaqvOhA7o/edit#heading=h.t9yy0z10h3rp
const String DEFAULT_OPTION = 'Default Option';

class ApiItemOption {
  ApiItemOption({
    this.count = 0,
    @required this.price,
    this.discountRate,
    @required this.text,
  });
  int count;
  int price;
  int discountRate;
  Widget text;
  @override
  String toString() {
    return "cont: $count, price: $price, discountRate: $discountRate";
  }
}

/// [ApiPost] is a model for a post.
///
/// Post can be used for many purpose like blog, messaging, shopping mall, etc.
class ApiPost {
  ApiPost({
    this.data,
    this.idx,
    this.title,
    this.content,
    this.comments,
    this.files,
    this.authorName,
    this.profilePhotoUrl,

    // updates
    this.userIdx,
    this.roodIdx,
    this.parentIdx,
    this.categoryIdx,
    this.subcategory,
    this.path,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,

    /// old
    // this.postAuthor,
    // this.postDate,
    // this.postModified,
    // this.postParent,
    // this.guid,
    // this.commentCount,
    // this.postCategory,
    // this.shortDateTime,
    // this.category,
    // this.featuredImageUrl,
    // this.featuredImageThumbnailUrl,
    // this.featuredImageId,

    // Shopping mall props
    this.shortTitle,
    this.price,
    this.optionItemPrice,
    this.discountRate,
    this.pause,
    this.point,
    this.volume,
    this.deliveryFee,
    this.storageMethod,
    this.expiry,
    this.primaryPhoto,
    this.widgetPhoto,
    this.detailPhoto,
    this.keywords,
    this.options,
  }) {
    if (files == null) files = [];
    if (title == null) title = '';
    if (content == null) content = '';
  }

  /// [data] is the original data for the post. When you need to access an extra meta property,
  /// you can access [data] directly.
  dynamic data;
  int idx;
  String title;
  String content;
  String authorName;
  String profilePhotoUrl;

  /// TODO:
  List<ApiFile> files;
  List<ApiComment> comments;

  /// updates
  String userIdx;
  String roodIdx;
  String parentIdx;
  String categoryIdx;
  String subcategory;
  String path;
  String createdAt;
  String updatedAt;
  String deletedAt;

  /// old
  // String postAuthor;
  // DateTime postDate;
  // DateTime postModified;
  // int postParent;
  // String guid;
  // int commentCount;
  // List<int> postCategory;
  // String shortDateTime;
  // String category;

  // String featuredImageUrl;
  // String featuredImageThumbnailUrl;
  // int featuredImageId;

  /// Upload file/image
  String thumbnailUrl(src,
      {int width = 320, int height = 320, int quality = 75, bool thumbnail = true}) {
    String url = Api.instance.thumbnailUrl;
    return url +
        '?src=$src&w=$width&h=$height&f=jpeg&q=$quality&thumbnail=' +
        (thumbnail ? 'Y' : 'N');
  }

  /// Widgets
  ///
  String get mobileForumListWidget => data['category_options'] == null
      ? null
      : data['category_options']['mobile_forum_list_widget'];

  ///
  String get mobileForumViewWidget => data['category_options'] == null
      ? null
      : data['category_options']['mobile_forum_view_widget'];

  /// Shopping mall properties
  ///
  String shortTitle;
  int price;
  bool optionItemPrice;
  int discountRate;

  /// 쇼핑 상품 일시 정지 상태인가?
  bool pause;
  int point;
  String volume;
  int deliveryFee;
  String storageMethod;
  String expiry;
  String primaryPhoto;
  String get primaryPhotoUrl => thumbnailUrl(primaryPhoto, thumbnail: false);
  String widgetPhoto;
  String get widgetPhotoUrl => thumbnailUrl(widgetPhoto);
  String detailPhoto;
  String get detailPhotoUrl => thumbnailUrl(detailPhoto, thumbnail: false);

  /// The [keywords] has multiple keywords separated by comma
  String keywords;

  /// [options] 는 백엔드로 부터 오는 값은 코마로 나누어진 옵션 문자열인데, Client 에서 파싱을 해서, 맵으로 보관한다.
  Map<String, ApiItemOption> options;
  int count(String option) {
    return options[option].count;
  }

  /// 여러 옵션 중에서 사용자가 선택한 옵션만 리턴한다. 기본 옵션은 제외.
  List<String> get selectedOptions {
    List<String> rets = [];
    for (String option in options.keys) {
      if (option != DEFAULT_OPTION && count(option) > 0) {
        rets.add(option);
      }
    }
    return rets;
  }

  /// 상품에 옵션이 있는가?
  bool get hasOption => data['options'] != null && data['options'] != '';

  /// [optionCount] 는 각 옵션 별로 몇 개를 구매하는지 개 수 정보를 가지고 있다.
  // Map<String, int> optionCount = {};

  /// EO Shopping Mall ----------------------------------------------------

  ///
  bool get isMine => userIdx == Api.instance.idx;
  bool get isNotMine => !isMine;

  /// Display options
  ///
  /// The [display] flag tells whether to show or hide the post in list.
  /// [display] 는 클라이언트에서만 사용되는 것으로, true 이면 글(내용)을 보여주는 것이다.
  bool display = false;

  /// Update mode
  ///
  /// The [mode] has one of the following status: null, 'edit'
  /// - when it is 'edit', the post is in edit mode.
  String mode;

  /// Get short name for display
  String get displayName {
    if (authorName == null) return '';
    return authorName.length <= 10 ? authorName : authorName.substring(0, 9);
  }

  ///
  insertOrUpdateComment(ApiComment comment) {
    // print(comment.commentParent);

    // find existing comment and update.
    int i = comments.indexWhere((c) => c.idx == comment.idx);
    if (i != -1) {
      comment.depth = comments[i].depth;
      comments[i] = comment;
      return;
    }

    // if it's new comment right under post, then add at bottom.
    if (comment.parentIdx == idx.toString()) {
      comments.add(comment);
      // print('parent id: 0, add at bottom');
      return;
    }

    // find parent and add below the parent.
    int p = comments.indexWhere((c) => c.idx.toString() == comment.parentIdx);
    if (p != -1) {
      comment.depth = comments[p].depth + 1;
      comments.insert(p + 1, comment);
      return;
    }

    // error. code should not come here.
    // print('error on comment add:');
  }

  /// Return [ApiPost] instance from json that comes from backend.
  ///
  /// ```dart
  /// ApiPost.fromJson({}) // This works for test
  /// ```
  ///
  /// You may want to clone a post. Then do the following;
  /// ```dart
  /// ApiPost clone = ApiPost.fromJson(this.posts.first.data);
  /// ```
  ///
  /// When you want to put a post into cart, the post must not be referenced. In that case,
  /// ```dart
  ///  / 아이템 복사. 카트에 들어간 아이템은 변경이 되면 안되고, 동일한 상품도 중복으로 넣을 수 있어야 히기 때문에, 현재 아이템을 복사해서 카트에 넣어야 한다.
  ///  ApiPost clone = ApiPost.fromJson(item.data);
  ///  item.options.keys.forEach((k) {
  ///  / ApiItemOption 도 레퍼런스로 연결되기 때문에, 복제를 해야 한다.
  ///    clone.options[k] = ApiItemOption(
  ///      count: item.options[k].count,
  ///      discountRate: item.options[k].discountRate,
  ///     price: item.options[k].price,
  ///     text: item.options[k].text);
  ///    });
  ///  }
  /// ```
  factory ApiPost.fromJson(Map<String, dynamic> json) {
    return ApiPost(
      data: json,
      idx: json["idx"] is String ? int.parse(json["idx"]) : json["idx"],
      authorName: json["authorName"] ?? '',
      title: json["title"] != '' ? json['title'] : 'No Title',
      content: json["content"] ?? '',
      profilePhotoUrl: json['profile_photo_url'],

      /// Updates
      userIdx: json['userIdx'],
      roodIdx: json['rootIdx'],
      parentIdx: json['parentIdx'],
      categoryIdx: json['categoryIdx'],
      subcategory: json['subcategory'],
      path: json['path'],
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
      deletedAt: json["deletedAt"],

      // TODO:
      files: json["files"] == null || json["files"] == ''
          ? []
          : List<ApiFile>.from(json["files"].map((x) => ApiFile.fromJson(x))),
      comments: json["comments"] == null
          ? []
          : List<ApiComment>.from(json["comments"].map((x) => ApiComment.fromJson(x))),

      /// Old
      // postAuthor: json["post_author"],
      // postDate: DateTime.parse(json["post_date"] ?? DateTime.now().toString()),
      // postModified: DateTime.parse(json["post_modified"] ?? DateTime.now().toString()),
      // postParent: json["post_parent"] ?? 0,
      // guid: json["guid"] ?? '',
      // commentCount: json["comment_count"] == null ? 0 : int.parse(json["comment_count"]),
      // postCategory:
      //     json["post_category"] == null ? [] : List<int>.from(json["post_category"].map((x) => x)),
      // authorName: json["author_name"] ?? '',
      // shortDateTime: json["short_date_time"] ?? '',
      // category: json["category"],
      // featuredImageUrl: json["featured_image_url"],
      // featuredImageThumbnailUrl: json["featured_image_thumbnail_url"],
      // featuredImageId: json["featured_image_ID"] == null
      //     ? 0
      //     : json["featured_image_ID"] is int
      //         ? json["featured_image_ID"]

      /// Fix bug here, parse and return int if not as int already.
      // : int.parse(json["featured_image_ID"]),

      /// Shopping Mall
      shortTitle: json["shortTitle"],
      price: _parseInt(json["price"]) ?? 0,
      optionItemPrice: json["optionItemPrice"] == 'Y' ? true : false,
      discountRate: _parseInt(json["discountRate"]),
      pause: json["pause"] == 'Y' ? true : false,
      point: json["point"] == null ? 0 : _parseInt(json["point"]),
      volume: json["volume"],
      deliveryFee: _parseInt(json["deliveryFee"]),
      storageMethod: json["storageMethod"],
      expiry: json["expiry"],
      primaryPhoto: json["primaryPhoto"],
      widgetPhoto: json["widgetPhoto"],
      detailPhoto: json["detailPhoto"],
      keywords: json['keywords'] ?? '',
      options: _prepareOptions(json['options'], json["optionItemPrice"] == 'Y' ? true : false),
    );
  }

  Map<String, dynamic> toJson() => {
        "idx": idx,
        // "post_author": postAuthor,
        // if (postDate != null) "post_date": postDate.toIso8601String(),
        // "content": content,
        // "title": title,
        // if (postModified != null) "post_modified": postModified.toIso8601String(),
        // "post_parent": postParent,
        // "guid": guid,
        // "comment_count": commentCount,
        // if (postCategory != null) "post_category": List<dynamic>.from(postCategory.map((x) => x)),
        // "files": List<dynamic>.from(files.map((x) => x.toJson().toString())),
        // "author_name": authorName,
        // "short_date_time": shortDateTime,
        // if (comments != null)
        //   "comments": List<dynamic>.from(comments.map((x) => x.toJson().toString())),
        // "category": category,
        // "featured_image_url": featuredImageUrl,
        // "featured_image_thumbnail_url": featuredImageThumbnailUrl,
        // "featured_image_ID": featuredImageId,
        "shortTitle": shortTitle,
        "price": price,
        "optionItemPrice": optionItemPrice.toString(),
        "discountRate": discountRate,
        "pause": pause,
        "point": point,
        "volume": volume,
        "deliveryFee": deliveryFee,
        "storageMethod": storageMethod,
        "expiry": expiry,
        "primaryPhoto": primaryPhoto,
        "widgetPhoto": widgetPhoto,
        "detailPhoto": detailPhoto,
        "keywords": keywords,
        "options": options.toString,
      };

  @override
  String toString() {
    return toJson().toString();
  }

  static int _parseInt(String n) {
    if (n is String) {
      if (n == null || n == '') return 0;
      return int.parse(n);
    }
    return 0;
  }

  /// 상품 가격을 할인하여 가격으로 리턴. '옵션에 추가금액지정' 방식에서만 사용 할 필요가 있다.
  int get discountedPrice {
    int discounted = price;
    if (discountRate > 0) {
      discounted = discount(price, discountRate);
    }
    return discounted;
  }

  /// '옵션에 상품가격지정' 방식에서, 옵션의 할인된 가격을 리턴한다.
  int optionDiscountedPrice(String option) {
    return options[option].count * discount(options[option].price, options[option].discountRate);
  }

  /// 상품의 옵션 정리(손질)
  ///
  /// [optionString] 은 DB(게시글)에 있는 옵션 문자열이다. 한 문자열에 여러개의 옵션이 들어가 있는데 이를 파싱하는 것이다.
  ///
  static Map<String, ApiItemOption> _prepareOptions(String optionString, bool optionItemPrice) {
    Map<String, ApiItemOption> _options = {};

    /// 옵션이 없는 경우, 기본(DEFAULT_OPTION) 옵션을 하나 두어서, 사용자가
    /// 옵션을 선택하지 않고 주문을 할 수 있도록 해 준다.
    /// 이 것은, 나중에 사용자가 상품 페이지를 볼 때, 해당 상품 주문 로직에서, 기본(DEFAULT_OPTION) 옵션을 하나 추가 해 주어야 한다.
    if (optionString == null || optionString.trim() == '') {
      _options[DEFAULT_OPTION] = ApiItemOption(price: 0, discountRate: 0, text: Text(''));
      return _options;
    }

    /// '옵션에 추가금액지정' 방식의 경우도 옵션이 없는 것과 마찬가지로 로직 처리.
    if (optionItemPrice == false) {
      _options[DEFAULT_OPTION] = ApiItemOption(price: 0, discountRate: 0, text: Text(''));
    }

    // 콤마로 분리
    List<String> options = optionString.split(',');
    // 여러개 옵션
    for (String option in options) {
      option = option.trim();
      if (option == '') continue;
      int discountRate = 0;
      int _price = 0;
      Widget text;
      // 옵션에 = 기호가 있으면,
      if (option.indexOf('=') > 0) {
        // = 로 분리
        List<String> kv = option.split('=');
        _price = int.parse(kv[1]);
        // 옵션 이름에 괄호가 있으면 할인율 지정, 없으면, 할인율 지정하지 않음.
        if (kv[0].indexOf('(') > 0) {
          // 할인율 지정
          String optionName = kv[0].split('(').first.trim(); // 옵션 이름

          // @todo 옵션 포멧을 잘못 지정한 경우 에러가는데, 핸들링을 해야 한다.
          discountRate = int.parse(kv[0].split('(').last.replaceAll(')', '').replaceAll('%', ''));

          String _discountedPrice = moneyFormat(discount(_price, discountRate));

          text = RichText(
              text: TextSpan(
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(text: "$optionName 할인 "),
              TextSpan(text: "($discountRate%)", style: TextStyle(color: Colors.red)),
              TextSpan(
                  text: " ${moneyFormat(_price)} ",
                  style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.red)),
              WidgetSpan(child: Icon(Icons.arrow_right_alt)),
              TextSpan(text: " => $_discountedPrice원"),
            ],
          ));
        } else {
          // 할인율 지정 없음
          if (optionItemPrice) {
            // 옵션이 완전한 개별 상품인 경우,
            text = Text("${kv[0]} ${moneyFormat(_price)}원");
          } else {
            // '옵션에 추가금액지정' 방식인 경우,
            text = Text("${kv[0]} +${moneyFormat(_price)}원 추가");
          }
        }
      } else {
        // 옵션에 = 기호가 없는 경우, 무료 옵션
        text = Text("$option");
      }
      _options[option] = ApiItemOption(discountRate: discountRate, price: _price, text: text);
    }
    return _options;
  }

  /// 사용자가 선택한 현재 상품(아이템)의 (옵션 포함) 주문 가격을 리턴한다.
  ///
  /// 예를 들어, 사용자가, 당근2박스 2만원과 선물포장 옵션 5천원을 선택했다면, 2만5천원이 리턴된다.
  /// 배송비나, 회원 포인트는 포함되어져 있지 않다.
  ///
  /// 현재 상품 페이지에서 주문 할 때 또는 장바구니에서 각 상품의 소계를 출력 할 때 사용 가능하다.
  int get priceWithOptions {
    int _price = 0;
    if (optionItemPrice) {
      // '옵션에 상품가격지정' 방식. 옵션마다 가격이 다르고, 옵션마다 각각의 할인율이 있다. 그래서 옵션별로 할인 계산을 따로 해야 한다.
      for (final option in options.keys) {
        _price += optionDiscountedPrice(option);
      }
    } else {
      // 기본 상품 가격에 옵션 가격을 추가하는 경우, 기본 옵션이 있어야 한다. 테스트 하는 경우에도 추가를 해 줘야 함.
      assert(options[DEFAULT_OPTION] != null, "Default Option not exists.");
      if (options[DEFAULT_OPTION] == null) return 0; // 에러. 기본 옵션이 존재해야 한다.

      for (final option in options.keys) {
        // 옵션이 선택된 경우, 구매 개수 만큼 곱해서, 옵션 가격 추가
        if (options[option].count == 1) {
          _price += options[option].price * options[DEFAULT_OPTION].count;
        }
      }
      _price += discountedPrice * options[DEFAULT_OPTION].count;
    }
    return _price;
  }

  /// 상품을 주문 할 때, 얼마의 포인트가 적립되는지, 그 포인트 적립금을 리턴한다.
  ///
  /// 상품 1개에 1천원의 포인트가 적립된다면, 그 상품을 5개 주문하면 5천 포인트가 리턴된다.
  /// 옵션에 상품가격지정 방식에서는 각각의 옵션 선택이 1개의 상품이 된다.
  int pointWithOptions(
    int itemPoint,
  ) {
    print('itemPoint: $itemPoint');
    int _point = 0;

    if (optionItemPrice) {
      // '옵션에 상품가격지정' 방식. 옵션마다 가격이 다르고, 옵션마다 각각의 할인율이 있다. 그래서 옵션별로 할인 계산을 따로 해야 한다.
      for (final option in options.keys) {
        _point += itemPoint * options[option].count;
      }
    } else {
      _point = itemPoint * options[DEFAULT_OPTION].count;
    }

    return _point;
  }

  /// 현재 상품의 옵션에, 상품 옵션 1개를 추가한다.
  /// 참고로, 상품 옵션 정보는 현재 상품의 옵션의 [count] 속성에 저장된다.
  addOption(String option) {
    options[option].count = 1;
  }

  /// '옵션에 상품 가격 지정'이 아닌 경우, 즉, '옵션에 추가 금액 지정'인 경우, 옵션 없이 바로 구매 할 수 있도록 기본(DEFAULT_OPTION) 옵션 추가
  ///
  /// 주의: static 이 아니어서, 생성자에서 이 함수를 호출 할 수 없다.
  /// 따라서, 쇼핑몰 상품 페이지에서, 이 함수를 한번 호출해 주어야 한다.
  ///
  /// DEFAULT_OPTION 이 혼동될 수 있으니 주의 하고, 이해를 잘 해야 한다.
  addDefaultOption() {
    if (optionItemPrice == false) {
      addOption(DEFAULT_OPTION);
    }
  }

  /// 기존에 선택된 옵션들을 모두 리젯한다. 모든 옵션 카운트를 0으로 하면 됨.
  resetOptions() {
    selectedOptions.forEach((optionName) => options[optionName].count = 0);
  }

  /// 옵션의 개 수 증가. '옵션에 상품가격지정방식'만 가능.
  increaseItemOption(String option) {
    assert(optionItemPrice || option == DEFAULT_OPTION, "옵션에 상품가격지정방식이 아니면, 옵션을 여러개 추가 할 수 없습니다.");
    options[option].count++;
  }

  /// option 의 count 를 감소시킨다. 즉, 주문 개 수 중에서 1을 감소한다.
  decreaseItemOption(String option) {
    if (options[option].count > 1) options[option].count--;
  }

  /// option 의 count 를 0 으로 하면, 장바구니에서 보이지 않도록 한다.
  delete(String option) {
    options[option].count = 0;
  }
}
