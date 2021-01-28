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

# Configuration

- When app starts(and running), the instance of `Api` is already available as global variable named `api`. This is because data models(like `ApiUser`) shares the global instance.

## Put WithcenterApi instance as GetX controller

- Put the instance as `GetX` controller as early as possible on the app start-up like below. Root screen page would be a good place.

```dart
final Api a = Get.put(api);
```

- Then, intialize `Api` like below. `apiUrl` is the backend api url.

```dart
print('api: $api');
api.init(apiUrl: apiUrl);
api.version().then((res) => print('api.version(): $res'));
```
