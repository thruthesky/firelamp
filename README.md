# Withcenter Api

Flutter package for Withcenter backend v3.

# Installation

- Add latest version into pubspec.yaml

# Configuration

- An instance of `withcenterApi` is available as global variable, so you don't have to create one unless you wish.

- Put it as `GetX` controller like below. You should do it as early as possible on your app's lifecycle. Root screen page would be a good place.

```dart
final WithcenterApi wa = Get.put(withcenterApi);
```

- Intialize `WithcenterApi` like below. `apiUrl` is the backend api url.

```dart
print('withcenterApi: $withcenterApi');
withcenterApi.init(apiUrl: apiUrl);
withcenterApi.version().then((res) => print('withcenterApi.version(): $res'));
```
