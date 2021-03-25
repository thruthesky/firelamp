import 'package:firelamp/firelamp.dart';

createSamplePosts() async {
  int noOfPosts = 30;
  for (int i = 0; i < noOfPosts; i++) {
    try {
      ApiPost p = await Api.instance
          .postEdit(categoryId: 'gallery', title: 'Gallery : title $i', content: 'Content $i');
      print('post created. title: ${p.title}');
      p = await Api.instance
          .postEdit(categoryId: 'reminder', title: 'Reminder : title $i', content: 'Content $i');
      print('post created. title: ${p.title}');
      p = await Api.instance
          .postEdit(categoryId: 'qna', title: 'QnA : title $i', content: 'Content $i');
      print('post created. title: ${p.title}');
      p = await Api.instance.postEdit(
          categoryId: 'discussion', title: 'Discussion : title $i', content: 'Content $i');
      print('post created. title: ${p.title}');
      p = await Api.instance
          .postEdit(categoryId: 'faq', title: 'Faq : title $i', content: 'Content $i');
      print('post created. title: ${p.title}');
    } catch (e) {
      print('e: $e');
    }
  }
}
