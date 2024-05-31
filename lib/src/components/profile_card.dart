import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:duolingo/src/home/main_screen/questions/models/question_class.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import '../../../main.dart';

class ProfileCard extends StatefulWidget {
  final String nickname;

  ProfileCard({required this.nickname});

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _databaseReference;
  bool _isLoading = true;
  String name = '';
  String email = '';
  int userPoints = 0;
  String rank = '';
  String language = '';
  List<Question> recentMistakes = [];

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userReference = FirebaseDatabase.instance.reference().child('users');
      final Query query = userReference.orderByChild('Username').equalTo(widget.nickname);

      final DatabaseEvent dataSnapshot = await query.once();

      if (dataSnapshot.snapshot.value != null) {
        final Map<dynamic, dynamic> userDataMap = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

        // Iterate through the keys in userDataMap to access user data
        final userDataKey = userDataMap.keys.first;
        final Map<dynamic, dynamic> userData = userDataMap[userDataKey] as Map<dynamic, dynamic>;

        print(userData);

        if (mounted) {
          setState(() {
            name = userData['Username'] ?? '';
            email = userData['email'] ?? '';
            userPoints = userData['points'] ?? 0;
            rank = userData['rank'] ?? '';
            language = userData['language'] ?? '';
            _isLoading = false;
          });
          print("$name+$userPoints+$rank+$language+${widget.nickname}+$email");
        }
      } else {
        // Handle the case where the user with the specified nickname is not found.
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }


  Widget _titleText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Feather',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                ClipOval(
                  child: Image.asset(
                    "assets/images/ranks/${_getRankImage()}",
                    height: 120,
                  ),
                ),
                Divider(color: Colors.grey.shade500),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _titleText("${AppLocalizations.of(context)!.information}:"),
                    SizedBox(height: 4,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: <Widget>[

                    Card(
                    child: Container(
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                            ),
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.37,
                            child: ListTile(
                              leading: Icon(
                                Icons.local_fire_department_rounded,
                                color: Colors.amber,
                              ),
                              title: Text(
                                '$userPoints',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                      ),
                        Card(
                          child: Container(

                            decoration: BoxDecoration(

                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 50,
                            width: MediaQuery.of(context).size.width ,
                            child: ListTile(
                              leading: Icon(
                                Icons.email,
                                color: Colors.amber,
                              ),
                              title: Text(
                                "$email",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ),





                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }



  String _getRankImage() {
    if (userPoints >= 900) {
      return "r.png";
    } else if (userPoints >= 700) {
      return "i.png";
    } else if (userPoints >= 500) {
      return "a.png";
    } else if (userPoints >= 400) {
      return "d.png";
    } else if (userPoints >= 250) {
      return "p.png";
    } else if (userPoints >= 150) {
      return "g.png";
    } else if (userPoints >= 100) {
      return "s.png";
    } else if (userPoints >= 50) {
      return "b.png";
    } else {
      return "ir.png";
    }
  }
}
