# FireLamp

A flutter package to support CMS(Content Management System) functionalities like user management, forum management, and more for building apps like social apps, shopping apps.

It is based on Firebase and LAMP stack.

## A story

We have been working on a flutter package to support the basic functionalities that every app needs.

We first worked on Firebase with LAMP(or LEMP) stack for a while and we decided to remove LAMP stack since it is a hassle to maintain two stacks.

After a couple of months, we had successfully built the first version of flutter package without LAMP stack named `fireflutter`. But we were not satisfied with the complex query on firestore. Then, without hesitate, we went back to LAMP stack with Firebase.

And here it is, `FireLamp`.

## Reference

### LAMP stack on Wordpress

- We have built the backend on Wordpress.
  - [sonub](https://github.com/thruthesky/sonub)

# Installation

- Add latest version into pubspec.yaml
- Set the Firebase settings on the project.

  - Add iOS `GoogleServices-info.plist` and Android `google-serfvices.json`.

- The instance of FireLamp `Api` is created and available as global variable named `api`. This is because data models(like `ApiUser`) shares the global instance.

## Put WithcenterApi instance as GetX controller

- Put the instance as `GetX` controller as early as possible on the app start-up like below. Root screen page would be a good place.
  - And, intialize `Api` like below. `apiUrl` is the backend api url.

```dart
class _MainAppState extends State<MainApp> {
  final Api a = Get.put<Api>(api);

  @override
  void initState() {
    super.initState();
    a.init(apiUrl: 'https://flutterkorea.com/wp-content/themes/sonub/api/index.php');
    a.version().then((res) {
      print('res: $res');
    });
    a.translationChanges.listen((trs) {
      print('trs: $trs');
    });
  }
```

## Language Settings

- First, add `language codes` in `Info.plist` on iOS. For android, it work out of the box.

```xml
		<key>CFBundleLocalizations</key>
		<array>
			<string>en</string>
			<string>ch</string>
			<string>ja</string>
			<string>ko</string>
		</array>
```

- Then, code like below.

```dart

class _MainAppState extends State<MainApp> {
  final Api a = Get.put<Api>(api);

  @override
  void initState() {
    super.initState();
    a.init(apiUrl: 'https://flutterkorea.com/wp-content/themes/sonub/api/index.php');
    a.translationChanges.listen((trs) {
      updateTranslations(trs);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: Locale(Get.deviceLocale.languageCode),
      translations: AppTranslations(),
      getPages: [
        /// ...
      ],
    );
  }
}
```
