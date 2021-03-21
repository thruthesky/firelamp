import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/spinner.dart';
import 'package:flutter/material.dart';

class AdminCategory extends StatefulWidget {
  @override
  _AdminCategoryState createState() => _AdminCategoryState();
}

class _AdminCategoryState extends State<AdminCategory> {
  List<ApiCategory> categories;
  @override
  void initState() {
    super.initState();

    init();
  }

  init() async {
    try {
      categories = await Api.instance.categorySearch();
      setState(() {});
    } catch (e) {
      alert(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return categories == null
        ? Spinner()
        : ListView.builder(
            itemCount: categories.length,
            itemBuilder: (_, i) {
              return ListTile(
                title: Text(categories[i].title),
                subtitle: Text(categories[i].id),
              );
            });
  }
}
