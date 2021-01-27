# Withcenter Api

Flutter package for Withcenter backend v3.

# Installation

- Add latest version into pubspec.yaml

# Configuration

- When app starts(and running), the instance of `WithcenterApi` is already available as global variable named `withcenterApi`. This is because data models(like `ApiUser`) shares the instance.
- You may rename it to `api` like below.

```dart
final WithcenterApi api = withcenterApi;
```

## Put WithcenterApi instance as GetX controller

- Put the instance as `GetX` controller as early as possible on the app start-up like below. Root screen page would be a good place.
  `WithcenterApi` is working on `GetX` package.

```dart
final WithcenterApi wa = Get.put(withcenterApi);
```

- Then, intialize `WithcenterApi` like below. `apiUrl` is the backend api url.

```dart
print('withcenterApi: $withcenterApi');
withcenterApi.init(apiUrl: apiUrl);
withcenterApi.version().then((res) => print('withcenterApi.version(): $res'));
```
