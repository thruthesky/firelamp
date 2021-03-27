import 'package:firelamp/firelamp.dart';
import 'package:flutter/material.dart';

class AdminCategoryEdit extends StatefulWidget {
  AdminCategoryEdit(this.category);
  final ApiCategory category;
  @override
  _AdminCategoryEditState createState() => _AdminCategoryEditState();
}

class _AdminCategoryEditState extends State<AdminCategoryEdit> {
  ApiCategory category;

  @override
  Widget build(BuildContext context) {
    category = widget.category;
    return ListView(
      children: [
        Text('카테고리 아이디', style: Theme.of(context).textTheme.caption),
        Text('${category.id}', style: Theme.of(context).textTheme.headline6),
        SizedBox(height: 10),
        TextField(
          controller: TextEditingController()..text = category.title,
          decoration: InputDecoration(labelText: '카테고리 이름'),
          onChanged: (t) => category.title = t,
        ),
        TextField(
          controller: TextEditingController()..text = category.description,
          decoration: InputDecoration(labelText: '카테고리 설명'),
          onChanged: (t) => category.description = t,
        ),
        TextField(
          controller: TextEditingController()..text = category.orgSubcategories,
          decoration: InputDecoration(labelText: '서브 카테고리. 콤마로 분리하여 여러개 입력 가능.'),
          onChanged: (t) => category.orgSubcategories = t,
        ),
        SizedBox(height: 20),
        ListHeader(text: '포인트 설정', desc: '포인트 설정에서 삭제 포인트는 0 또는 음수 값만 입력 할 수 있습니다.'),
        TextField(
          controller: TextEditingController()..text = category.pointPostCreate,
          decoration: InputDecoration(labelText: '글 쓰기 포인트'),
          onChanged: (t) => category.pointPostCreate = t,
        ),
        TextField(
          controller: TextEditingController()..text = category.pointCommentCreate,
          decoration: InputDecoration(labelText: '코멘트 쓰기 포인트'),
          onChanged: (t) => category.pointCommentCreate = t,
        ),
        TextField(
          controller: TextEditingController()..text = category.pointPostDelete,
          decoration: InputDecoration(labelText: '글 삭제 포인트'),
          onChanged: (t) => category.pointPostDelete = t,
        ),
        TextField(
          controller: TextEditingController()..text = category.pointCommentDelete,
          decoration: InputDecoration(labelText: '코멘트 삭제 포인트'),
          onChanged: (t) => category.pointCommentDelete = t,
        ),
        SizedBox(height: 20),
        ListHeader(
            text: '제한 설정',
            desc:
                '포인트 설정 및 글 쓰기 제한. 아래의 제한에 걸리면, 포인트는 증/감하지 않습니다. 단, 글/코멘트 쓰기 제한은 옵션 선택을 해야합니다.\n\n시간/수 제한'),
        Row(
          children: [
            SizedBox(
                width: 40,
                child: TextField(
                  controller: TextEditingController()..text = category.pointHourLimit,
                  onChanged: (t) => category.pointHourLimit = t,
                )),
            Text('시간에'),
            SizedBox(width: 32),
            SizedBox(
                width: 40,
                child: TextField(
                  controller: TextEditingController()..text = category.pointHourLimitCount,
                  onChanged: (t) => category.pointHourLimitCount = t,
                )),
            Text('회로 제한'),
          ],
        ),
        TextField(
          controller: TextEditingController()..text = category.pointDailyLimitCount,
          decoration: InputDecoration(labelText: '일/수 제한. 하루에 몇 회로 제한.'),
          onChanged: (t) => category.pointDailyLimitCount = t,
        ),
        ListTile(
          contentPadding: EdgeInsets.fromLTRB(0, 12, 0, 0),
          title: Text(
            '글/코멘트 글 쓰기 제한',
            style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 13),
          ),
          subtitle: Text(
            '이 옵션을 선택하면, 위의 제한에 걸리는 경우, 더 이상 글을 쓸 없습니다.',
            style: TextStyle(fontSize: 12),
          ),
          trailing: Switch.adaptive(
            value: category.banOnLimit == 'Y',
            onChanged: (bool value) {
              setState(() {
                category.banOnLimit = value ? 'Y' : 'N';
              });
            },
          ),
        ),
        SizedBox(height: 20),
        ListHeader(text: '위젯 설정', desc: '카테고리 목록의 디자인을 선택합니다.'),
        ListTile(
          contentPadding: EdgeInsets.fromLTRB(0, 12, 0, 0),
          title: Text('글 목록 디자인'),
          trailing: DropdownButton<String>(
            value: category.mobilePostListWidget ?? '',
            items: [
              DropdownMenuItem(value: '', child: Text('글 목록 디자인 선택')),
              DropdownMenuItem(value: 'text', child: Text('텍스트')),
              DropdownMenuItem(value: 'gallery', child: Text('갤러리')),
              DropdownMenuItem(value: 'thumbnail', child: Text('썸네일')),
            ],
            onChanged: (String value) => setState(() => category.mobilePostListWidget = value),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.fromLTRB(0, 12, 0, 0),
          title: Text('글 읽기 디자인'),
          trailing: DropdownButton<String>(
            value: category.mobilePostViewWidget ?? '',
            items: [
              DropdownMenuItem(value: '', child: Text('글 읽기 디자인 선택')),
              DropdownMenuItem(value: 'default', child: Text('기본')),
              DropdownMenuItem(value: 'slide', child: Text('슬라이드')),
            ],
            onChanged: (String value) => setState(() => category.mobilePostViewWidget = value),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
            onPressed: () async {
              try {
                await Api.instance.categoryUpdate(id: category.id, data: category.toSave());
                alert('카테고리가 수정되었습니다.');
              } catch (e) {
                alert(e);
              }
            },
            child: Text('업데이트'))
      ],
    );
  }
}

class ListHeader extends StatelessWidget {
  const ListHeader({
    this.text,
    this.desc,
    Key key,
  }) : super(key: key);
  final String text;
  final String desc;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        Text(
          desc,
          style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
