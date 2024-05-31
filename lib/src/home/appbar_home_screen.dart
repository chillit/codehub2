import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AppBarHomeScreen extends StatefulWidget {
  @override
  State<AppBarHomeScreen> createState() => _AppBarHomeScreenState();
}

class _AppBarHomeScreenState extends State<AppBarHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _databaseReference;
  String image = "";
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _getUserData();
  }



  String language = '';
  int userPoints = 0;

  Future<void> _getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _databaseReference = FirebaseDatabase.instance.reference().child('users/${user.uid}');
        final dataSnapshot = await _databaseReference.once();
        final Map<dynamic, dynamic> data = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
        print(data);

        setState(() {
          userPoints = data['points'];
          language = data['language'];
        });
        print("wtf $language");
      }
    } catch (error) {
      print('Error: $error');
    }
      print("wtfff $language  ${language=="C++"} ${language.toString() == "C++"} ${language.length}");
      if(language=='igcse'){
        image =  'assets/images/exams/igcse.png';}
      else if(language=='ent'){
        image =  'assets/images/exams/ent.png';}
      else{
        image =  'assets/images/white.png';}
    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return isLoading?
        Container():
    AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,

      elevation: 3,
      actions: <Widget>[
        Row(

          children: <Widget> [

            Image.asset('assets/images/kz/tarihnama.png',height: 70,width: 150,),
            SizedBox(width: 50,),

            Image.asset(
              "assets/images/appBar/crown_stroke.png",
              height: 29,
            ),

            Text(
              "$userPoints",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  fontSize: 17),
            ),
            const SizedBox(
              width: 30,
            ),

          ],
        ),
      ],
    );
  }
}