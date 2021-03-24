import 'dart:async';

import 'package:firelamp/firelamp.dart';
import 'package:firelamp/widgets/defines.dart';
import 'package:firelamp/widgets/popup_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

typedef OnSearch = Function(String searchKey, String category);

class SearchBar extends StatefulWidget {
  SearchBar({
    @required this.display,
    @required this.onSearch,
    @required this.onCancel,
    this.categories = '',
    this.defaultSearchKeyValue,
    this.defaultSearchCategoryValue,
    this.searchOnInputChange = true,
    this.searchOnCategoryChange = true,
    this.backgroundColor = const Color(0xffebf0f7),
  });
  final bool display;
  final String categories;
  final OnSearch onSearch;
  final Function onCancel;
  final String defaultSearchCategoryValue;
  final String defaultSearchKeyValue;
  final Color backgroundColor;

  /// When `true`, search will work everytime the text input changes.
  /// If `false`, the user must click the search icon button to search.
  final bool searchOnInputChange;
  final bool searchOnCategoryChange;

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController _editingController;
  FocusNode _focusNode = FocusNode();

  PublishSubject<String> input = PublishSubject();
  StreamSubscription subscription;

  String _selectedCategory;

  String get selected => _selectedCategory ?? searchCategories.split(',').first;
  set selected(String category) => setState(() => _selectedCategory = category);
  String searchKey;

  String get searchCategories => Api.instance.settings['search_categories'] ?? widget.categories;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.defaultSearchCategoryValue;

    _editingController = TextEditingController(text: widget.defaultSearchKeyValue);
    subscription = input
        .debounceTime(Duration(milliseconds: 500))
        .distinct((a, b) => a == b)
        .listen((_searchKey) {
      searchKey = _searchKey;
      if (widget.onSearch != null) widget.onSearch(searchKey, selected);
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return widget.display == false
        ? SizedBox.shrink()
        : Container(
            color: widget.backgroundColor,
            padding: EdgeInsets.only(top: Space.xs, bottom: Space.xs),
            child: Row(
              children: [
                Container(
                  width: 40,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.redAccent),
                    onPressed: widget.onCancel,
                  ),
                ),
                Flexible(
                  child: TextField(
                    autofocus: false,
                    focusNode: _focusNode,
                    controller: _editingController,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (value) => input.add(value),
                    onChanged: widget.searchOnInputChange
                        ? (value) => input.add(value)
                        : (value) => searchKey = value,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: Space.sm),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(const Radius.circular(25.0)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          _focusNode.unfocus();
                          widget.onSearch(searchKey, selected);
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: Space.xsm),
                  constraints: BoxConstraints(minWidth: 50),
                  child: Text(
                    '$selected',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                PopUpButton(
                  items: [
                    for (final category in searchCategories.split(','))
                      PopupMenuItem(
                        child: Text('$category'),
                        value: category,
                        textStyle: selected == category
                            ? TextStyle(color: Colors.green[600], fontWeight: FontWeight.w700)
                            : null,
                      )
                  ],
                  onSelected: (selectedCat) {
                    if (selected == selectedCat) return;
                    selected = selectedCat;

                    if (!widget.searchOnCategoryChange) return;
                    widget.onSearch(searchKey, selected);
                  },
                ),
              ],
            ),
          );
  }
}
