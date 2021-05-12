# FireLamp Widgets

## File/Photo Upload

```dart
Scaffold(
  appBar: AppBar(
    title: Text('상품 후기 등록'),
  ),
  body: Column(
    children: [
      Text('후기'),
      TextField(controller: contentController ),
      DisplayUploadedFilesAndDeleteButtons(postOrComment: comment),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 파일 업로드 버튼
          IconButton(
            alignment: Alignment.center,
            icon: Icon(Icons.camera_alt, color: Colors.black),
            onPressed: () async {
              // 파일 업로드 버튼 루틴
              try {
                final file = await imageUpload(onProgress: (p) => setState(() => percentage = p));
                percentage = 0;
                comment.files.add(file); // 파일 추가
                setState(() => null);
              } catch (e) {
                if (e == ERROR_IMAGE_NOT_SELECTED) { /** ignore */ } else {
                  app.error(e);
                }
              }
            },
          ),
          RaisedButton(
            child: Text('작성'),
            onPressed: () async {
              try {
                await api.commentEdit(rootIdx: productIdx,  parentIdx: productIdx, content: contentController.text,
                      files: comment.files, // 파일을 등록
                    );
                await app.alert( title: 'title after review edit'.tr, message: 'message after review edit'.tr);
                Get.toNamed(RouteNames.product, arguments: {'productIdx': productIdx, 'tabIndex': 2});
              } catch (e) {
                app.error(e);
              }
            },
          ),
        ],
      )
    ],
  ),
);
```

##
