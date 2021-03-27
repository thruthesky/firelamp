import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/functions.dart';
import 'package:get/get.dart';

/// 관리자 페이지 상태 관리 Getx Controller
///
/// 이 상태 관리 Getx Controller 는 관리자 페이지만을 위한 것으로 Restful API 와 관련된 작업을 하지 않는다.
/// CenterX 백엔드와 관련된 통신은 전적으로 Firelamp 에서 담당한다.
class Admin extends GetxController {
  static Admin to = Get.find();
  static Admin of = Get.find();

  Api api = Api.instance;

  Map<String, ApiCategory> categories;
  List<ApiCategory> searchedCategories;

  /// 카테고리 검사 루틴 -------------------------------------------------
  ///

  /// 프로젝트에서 사용하는 카테고리
  final defaultCategories = [
    'qna',
    'faq',
    'discussion',
    'reminder',
    'gallery',
    'events',
    'shopping_mall',
    'inquiry',
    'health_meal_lunch',
    'health_meal_morning',
    'health_meal_dinner',
    'health_scribble',
    'health_exercise',
    'health_sleep',
    'health_brain'
  ];

  /// 관리자 페이지의 처음에서 한번 호출되어야 한다.
  categoryCheck() async {
    try {
      final _cats = await api.categoryGets(defaultCategories);
      categories = {};
      for (final cat in _cats) {
        categories[cat.id] = cat;
      }
      update();
    } catch (e) {
      alert(e);
    }
  }

  bool hasCategory(String categoryId) {
    if (categories == null || categories.length == 0) return false;
    return categories.keys.contains(categoryId);
  }

  /// 신규 생성된 모든 카테고리는 categories 에 추가 저장된다.
  ///
  /// 처음에 categories 에 존재하는 카테고리가 저장되고, 여기서 생성되는 카테고리를 추가로 저장한다.
  createDefaultCategories() async {
    for (final id in defaultCategories) {
      try {
        final cat = await api.categoryCreate(id: id);
        categories[cat.id] = cat;
      } catch (e) {
        if (e == 'error_category_exists') {
        } else {
          alert(e);
        }
      }
      update();
      setInquiryCategory();
    }
  }

  bool get checkInquirySubcategory {
    if (categories == null ||
        categories['inquiry'] == null ||
        categories['inquiry'].subcategories == null ||
        categories['inquiry'].subcategories.length == 0)
      return false;
    else
      return true;
  }

  setInquiryCategory() async {
    if (categories['inquiry'] == null) return;
    try {
      final cat = await api.categoryUpdate(
          id: 'inquiry', field: 'subcategories', value: '상품 문의,배송 문의,취소/결제 문의,교환/반품 문의,기타 문의');
      categories[cat.id] = cat;
      update();
    } catch (e) {
      alert(e);
    }
  }

  // 카테고리 검사 루틴, 끝 --

  /// 검색한 카테고리
  ///
  /// 관리자 페이지의 처음에서 한번 호출하면 된다.
  categorySearch() async {
    try {
      searchedCategories = await api.categorySearch(limit: 20000);
      update();
    } catch (e) {
      alert(e);
    }
  }

  /// ----------------------- About --------------------------
  ApiFile about = ApiFile();
  uploadAbout() async {
    try {
      about = await imageUpload(
        onProgress: (p) {
          about.percentage = p;
          update();
        },
        code: 'admin.app.about.setting',
        deletePreviousUpload: true,
      );
      about.percentage = 0;
      update();
      await api.setConfig('admin.app.about.setting', about.idx);
    } catch (e) {
      alert(e);
    }
  }

  // loadAbout() async {
  //   api.thumbnailUrl(code: 'admin.app.about.setting');
  // }
}
