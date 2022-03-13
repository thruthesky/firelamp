import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widget.keys.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/forum/shared/display_uploaded_files_and_delete_buttons.dart';
import 'package:firelamp/widgets/functions.dart';
import 'package:firelamp/widgets/itsuda/itsuda_confirm_dialog.dart';
import 'package:firelamp/widgets/itsuda/itsuda_text_dialog.dart';
import 'package:firelamp/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class PostForm extends StatefulWidget {
  PostForm(
    this.forum, {
    this.mainCategories = const [],
    this.subcategories = const {},
    this.onSuccess,
    this.onCancel,
    this.onError,
    this.togglePostForm,
    @required this.onFileDelete,
  });
  final ApiForum forum;
  final Function onSuccess;
  final Function onCancel;
  final Function onError;
  final Function onFileDelete;
  final Function togglePostForm;
  final List<String> mainCategories;
  // final List<String> subcategories;
  final Map<String, ApiCategory> subcategories;

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final formKey = GlobalKey<FormState>();
  // final title = TextEditingController();
  // final content = TextEditingController();
  String title;
  String content;
  double percentage = 0;
  bool loading = false;
  ApiPost post;
  List<String> mainCategories = [];
  // List<String> subCategories = [];
  Map<String, ApiCategory> subCategories = {};

  String category;
  String mainCategory;
  String subCategory;
  bool isEdit = false;

  // InputDecoration _inputDecoration = InputDecoration(
  //   filled: true,
  //   contentPadding: EdgeInsets.all(Space.sm),
  //   border: OutlineInputBorder(
  //     borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
  //   ),
  //   focusedBorder: OutlineInputBorder(
  //     borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
  //     borderSide: const BorderSide(color: Color(0xFFB8860B), width: 2),
  //   ),
  // );

  onImageIconTap() async {
    FocusScope.of(context).requestFocus(new FocusNode());

    try {
      // final file = await imageUpload(
      //   quality: 95,
      //   onProgress: (p) => setState(
      //     () => percentage = p,
      //   ),
      // );
      final file = await fileUpload(
        quality: 95,
        onProgress: (p) => setState(
          () => percentage = p,
        ),
      );
      percentage = 0;
      post.files.add(file);
      setState(() => null);
    } catch (e) {
      if (e == ERROR_IMAGE_NOT_SELECTED || e == ERROR_VIDEO_NOT_SELECTED) {
      } else {
        // onError(e);
      }
    }
  }

  onFormSubmit() async {
    print('onFormSubmit()');
    if (loading) return;
    setState(() => loading = true);

    if (Api.instance.notLoggedIn) return onError("login_first".tr);
    try {
      final editedPost = await Api.instance.postEdit(
        idx: post.idx,
        // categoryId: widget.forum.categoryId,
        // subcategory: widget.forum.subcategory,
        categoryId: mainCategory,
        subcategory: subCategory,
        title: title,
        content: content,
        files: post.files,
      );
      widget.forum.insertOrUpdatePost(editedPost);
      setState(() => loading = false);
      if (!isEdit && editedPost.appliedPoint.toInt != 0)
        showDialog(
            context: context,
            builder: (_) => ItsudaTextDialog(
                content: "'글쓰기를 완료'", subContent: '${editedPost.appliedPoint}포인트를 취득하였습니다.'));

      if (widget.onSuccess != null) widget.onSuccess(editedPost);
    } catch (e) {
      setState(() => loading = false);
      if (e == 'error_daily_limit') {
        showDialog(
            context: context,
            builder: (_) => ItsudaTextDialog(content: '관리자에게 문의하세요. 게시판 글쓰기가 제한되었습니다.'));
        return;
      }
      onError(e);
    }
  }

  onError(dynamic e) {
    if (widget.onError != null) widget.onError(e);
  }

  void setCategory(String newMainCategory, String newSubCategory) {
    setState(() {
      mainCategory = newMainCategory;
      subCategory = newSubCategory;
      debugPrint('mainCategory: $mainCategory');
      debugPrint('subCategory: $subCategory');
    });
  }

  @override
  void initState() {
    super.initState();

    post = widget.forum.postInEdit;
    if (post.categoryId != null ||
        post.subcategory != null ||
        post.title != '' ||
        post.content != '') {
      isEdit = true;
      debugPrint(
          'post.categoryId: ${post.categoryId} post.subcategory: ${post.subcategory} post.title: ${post.title} post.content: ${post.content}');
      debugPrint('isEdit: $isEdit');
    }

    if (widget.forum.categoryId == null || widget.forum.categoryId == 'noCategory')
      mainCategory = null;
    else
      mainCategory = widget.forum.categoryId;
    mainCategories = widget.mainCategories;
    // subCategories = widget.subcategories[mainCategory]?.subcategories ?? [];
    subCategories = widget.subcategories;
    subCategory = post.subcategory;
    title = post.title;
    content = post.content;

    SchedulerBinding.instance.addPostFrameCallback((_) => widget.togglePostForm(true));

    print('PostForm: ${widget.forum.categoryId}');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ApiForum forum = widget.forum;
    // if (forum.postInEdit.subcategory != '' || forum.postInEdit.subcategory != null)
    //   forum.subcategory = forum.postInEdit.subcategory;
    if (forum.postInEdit == null) return SizedBox.shrink();
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Container(
          key: ValueKey(FirelampKeys.element.postEditForm),
          padding: EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
          decoration: BoxDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(top: Space.xs, bottom: Space.xs),
                child: Text('① 제목'),
              ),
              TextFormField(
                cursorColor: Color(0xFFB8860B),
                key: ValueKey(FirelampKeys.element.postTitleInput),
                // controller: title,
                initialValue: title,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  hintText: '제목을 입력해 주세요.',
                  hintStyle: TextStyle(color: Color(0xFFcccccc)),
                  filled: true,
                  contentPadding: EdgeInsets.all(Space.sm),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
                    borderSide: const BorderSide(color: Color(0xFFB8860B), width: 2),
                  ),
                ),
                onSaved: (val) {
                  setState(() {
                    this.title = val;
                  });
                },
                validator: (val) {
                  if (val.length < 1) {
                    return '제목은 필수사항입니다.';
                  }

                  if (val.length < 2) {
                    return '제목은 두 글자 이상 입력해 주셔야합니다.';
                  }

                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: Space.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('② 내용'),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onImageIconTap,
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt),
                          SizedBox(width: Space.xsm),
                          Text(
                            '사진촬영',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (percentage > 0)
                Container(
                  padding: EdgeInsets.only(right: Space.sm),
                  child: LinearProgressIndicator(
                    value: percentage,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFdd00)),
                  ),
                ),
              DisplayUploadedFilesAndDeleteButtons(
                postOrComment: forum.postInEdit,
                onFileDelete: widget.onFileDelete,
              ),

              SizedBox(height: 12),
              TextFormField(
                cursorColor: Color(0xFFB8860B),
                key: ValueKey(FirelampKeys.element.postContentInput),
                // controller: content,
                initialValue: content,
                minLines: 5,
                maxLines: 15,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  hintText: '내용을 입력해 주세요.',
                  hintStyle: TextStyle(color: Color(0xFFcccccc)),
                  filled: true,
                  contentPadding: EdgeInsets.all(Space.sm),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
                    borderSide: const BorderSide(color: Color(0xFFB8860B), width: 2),
                  ),
                ),
                onSaved: (val) {
                  setState(() {
                    this.content = val;
                  });
                },
                validator: (val) {
                  if (val.length < 1) {
                    return '내용은 필수사항입니다.';
                  }

                  if (val.length < 5) {
                    return '내용은 다섯 글자 이상 입력해 주셔야합니다.';
                  }

                  return null;
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: Space.md, bottom: Space.xs),
                child: Text('③ 주제'),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: Get.context,
                      builder: (context) => BuildScrollableSheet(
                          mainCategories: mainCategories,
                          subCategories: subCategories,
                          onTap: setCategory));
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      mainCategory == null
                          ? '해당 주제를 선택해 주세요.'
                          : '${mainCategory.tr} / $subCategory',
                      style:
                          TextStyle(color: mainCategory == null ? Color(0xFFcccccc) : Colors.black),
                    ),
                  ),
                ),
              ),

              // Row(children: [
              //   Expanded(
              //     child: DropdownButtonFormField<String>(
              //       isExpanded: true,
              //       value: mainCategory,
              //       hint: Text(
              //         '주제를 선택해 주세요.',
              //         style: TextStyle(color: Color(0xFFcccccc)),
              //       ),
              //       onChanged: (cat) async {
              //         if (cat == mainCategory) return;
              //         mainCategory = cat;
              //         subCategories = widget.subcategories[mainCategory]?.subcategories ?? [];
              //         subCategory = null;
              //         setState(() {});
              //       },
              //       validator: (value) => value == null ? '주제를 선택해 주세요.' : null,
              //       items: [
              //         DropdownMenuItem(child: Text('주제를 선택해 주세요.'), value: null),
              //         for (final String cat in widget.mainCategories)
              //           DropdownMenuItem(
              //             child: Text(
              //               '$cat'.tr,
              //               style:
              //                   cat == mainCategory ? TextStyle(fontWeight: FontWeight.bold) : null,
              //             ),
              //             value: cat,
              //           ),
              //       ],
              //     ),
              //   ),
              // ]),
              // Row(children: [
              //   Text('subcategory'.tr),
              //   SizedBox(width: Space.md),
              //   Expanded(
              //     child: DropdownButtonFormField<String>(
              //       isExpanded: true,
              //       value: subCategory,
              //       hint: Text(
              //         '서브 카테고리를 선택해 주세요.',
              //         style: TextStyle(color: Color(0xFFcccccc)),
              //       ),
              //       onChanged: (cat) {
              //         if (cat == subCategory) return;
              //         subCategory = cat;
              //         setState(() {});
              //       },
              //       validator: (value) => value == null ? '서브 카테고리를 선택해 주세요.' : null,
              //       items: [
              //         DropdownMenuItem(child: Text('서브 카테고리를 선택해 주세요.'), value: null),
              //         for (final String cat in subCategories)
              //           DropdownMenuItem(
              //             child: Text(
              //               '$cat',
              //               style:
              //                   cat == subCategory ? TextStyle(fontWeight: FontWeight.bold) : null,
              //             ),
              //             value: cat,
              //           ),
              //       ],
              //     ),
              //   ),
              // ]),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),

                  /// Submit button
                  Row(
                    children: [
                      if (!loading)
                        TextButton(
                            child: Text(
                              'cancel'.tr,
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => ItsudaConfirmDialog(
                                  title: '글쓰기 취소',
                                  content: Text(
                                    '글쓰기에서 나가겠습니까?',
                                    style: Theme.of(Get.context).textTheme.bodyText1,
                                  ),
                                  okButton: () {
                                    forum.postInEdit = null;
                                    if (widget.onCancel != null) widget.onCancel();
                                    widget.togglePostForm(false);
                                    Get.back();
                                  },
                                ),
                              );
                            }),
                      TextButton(
                          key: ValueKey(FirelampKeys.button.postFormSubmit),
                          child: loading
                              ? Spinner()
                              : Text(
                                  isEdit == false ? '완료' : '수정',
                                  style: TextStyle(
                                      color: Color(0xFFB8860B), fontWeight: FontWeight.bold),
                                ),
                          onPressed: () {
                            if (formKey.currentState.validate()) {
                              if (mainCategory == null)
                                return showDialog(
                                    context: context,
                                    builder: (_) => ItsudaTextDialog(content: '주제를 선택해 주세요.'));

                              //form is valid, proceed further
                              formKey.currentState
                                  .save(); //save once fields are valid, onSaved method invoked for every form fields
                              onFormSubmit();
                              widget.togglePostForm(false);
                            }
                          }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuildScrollableSheet extends StatelessWidget {
  const BuildScrollableSheet(
      {Key key, @required this.mainCategories, @required this.subCategories, this.onTap})
      : super(key: key);
  final List<String> mainCategories;
  final Map<String, ApiCategory> subCategories;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: GestureDetector(
        onTap: () {},
        child: DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 1,
          builder: (_, controller) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Categories(
                mainCategories: mainCategories, subCategories: subCategories, onTap: onTap),
            // ListView.builder(
            //   controller: controller,
            //   itemCount: 25,
            //   itemBuilder: (context, index) => ListTile(
            //     title: Text('Item $index'),
            //   ),
            // ),
          ),
        ),
      ),
    );
  }
}

class Categories extends StatelessWidget {
  const Categories(
      {Key key, @required this.mainCategories, @required this.subCategories, this.onTap})
      : super(key: key);

  final List<String> mainCategories;
  final Map<String, ApiCategory> subCategories;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child: Text('카테고리',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child:
                    Text('닫기', style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 18)),
              ),
            ],
          ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: xsm),
          //   child: DottedLine(dashColor: itsudaGrey),
          // ),
          SizedBox(width: Space.xsm),
          Padding(padding: EdgeInsets.symmetric(vertical: Space.sm), child: Divider()),
          Expanded(
            child: CategoryItem(
                mainCategories: mainCategories, subCategories: subCategories, onTap: onTap),
          )
        ],
      ),
    );
  }
}

class CategoryItem extends StatefulWidget {
  const CategoryItem(
      {Key key, @required this.mainCategories, @required this.subCategories, this.onTap})
      : super(key: key);

  final List<String> mainCategories;
  final Map<String, ApiCategory> subCategories;
  final Function onTap;

  @override
  _CategoryItemState createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  List categories = [];
  Map<String, String> mainCategoryMap = {};
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    for (var mainCategory in widget.mainCategories) {
      for (var subCategory in widget.subCategories[mainCategory].subcategories) {
        categories.add(subCategory);
        mainCategoryMap[subCategory] = mainCategory;
        debugPrint('categories: $categories');
        debugPrint('mainCategoryMap: $mainCategoryMap');
      }
    }
    categories.remove('쏙쏙');
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: categories.length,
      itemBuilder: (context, index) => Container(
          height: 50,
          child: RadioListTile(
            value: categories[index],
            groupValue: selectedCategory,
            title: Text(categories[index]),
            onChanged: (val) {
              print("Radio Tile pressed $val");
              setState(() {
                selectedCategory = val;
              });
              widget.onTap(mainCategoryMap[selectedCategory], selectedCategory);
              Get.back();
            },
            activeColor: Colors.black,
          )

          // ListTile(
          //   title: Text(widget.subCategories[index]),
          //   leading: Radio<String>(
          //     activeColor: itsudaGold,
          //     value: widget.subCategories[index],
          //     groupValue: category,
          //     onChanged: (String value) {
          //       setState(() {
          //         category = value;
          //       });
          //     },
          //   ),
          // ),
          ),
    );
  }
}
