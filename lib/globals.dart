class MyGlobals {
  static final MyGlobals _singleton = MyGlobals._internal();

  factory MyGlobals() {
    return _singleton;
  }

  MyGlobals._internal();

  String myGlobalVariable = "Hello, World!";
}