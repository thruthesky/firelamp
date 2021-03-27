import 'package:firelamp/widgets/admin/admin.controller.dart';
import 'package:firelamp/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminCategoryList extends StatelessWidget {
  AdminCategoryList({@required this.onTap}) {
    Admin.to.categorySearch();
  }
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<Admin>(builder: (_) {
      if (_.searchedCategories == null) return Spinner();
      return ListView(
        children: [
          ListTile(
            title: Text('총. ${_.searchedCategories.length} 개의 카테고리가 있습니다.'),
          ),
          for (final category in _.searchedCategories)
            ListTile(
              title: Text(category.title),
              subtitle: Text(category.id),
              onTap: () => onTap(category),
            ),
        ],
      );
    });
  }
}
