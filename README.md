# FireLamp

A flutter package to support fundamental functionalities for building apps.

It is based on Firebase and LAMP stack.

## Overview

We have been working on a flutter package to support basic functionalities to build apps like social community app, shopping mall app, and any kinds app.

We first worked on Firebase with LAMP stack for a while and we decided to remove LAMP stack since it is a hassle to maintain two stacks.

After a couple of months, we had successfully built a flutter package named `fireflutter`..., But we were not satisfied with the complex query on firestore. Without hesitate, we went back to LAMP stack with Firebase.

And here it is, `FireLamp`.

## Reference

### LAMP stack on Wordpress

- We have built the backend on Wordpress.
  - [withcenter-backend-v3](https://github.com/thruthesky/withcenter-backend-v3)

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
