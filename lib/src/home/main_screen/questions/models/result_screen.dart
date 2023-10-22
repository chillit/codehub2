import 'package:duolingo/src/home/main_screen/home.dart';
import 'package:flutter/material.dart';
import 'package:duolingo/src/home/main_screen/questions/question.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class ResultScreen extends StatefulWidget {
  final Function(Locale) setLocale;
  final int score;
  final int len;
  const ResultScreen({
    key,
    required this.setLocale, required this.score, required this.len
  });



  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(setLocale: widget.setLocale,)));
          }, icon: Icon(Icons.close_sharp,color: Colors.black,))
        ],
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.6),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0,3),
              )
            ],
            borderRadius: BorderRadius.circular(25),
            color: Colors.grey.withOpacity(0.3),
          ),

          height: MediaQuery.of(context).size.width * 0.95,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 200,
                child: Image.asset('assets/images/Trophy.gif')),
              SizedBox(height: 10),
              Text(
                '${AppLocalizations.of(context)!.cong}',
                style: TextStyle( fontSize: 23),
              ),
              SizedBox(height: 20),
              Text(
                '${AppLocalizations.of(context)!.proscore}: ${(widget.score / widget.len * 100).round()}%',
                style: const TextStyle(fontSize: 37,color: Colors.green),
              ),
              SizedBox(height: 24,),
              Text(
                '${AppLocalizations.of(context)!.lvlcomp}'
                  ,style: TextStyle(
                  fontSize: 18,
              ),
              ),
            ],
          ),
        )
      )


      /*Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 1000),
          const Text(
            'Your Score: ',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w500,
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 250,
                width: 250,
                child: CircularProgressIndicator(
                  strokeWidth: 10,
                  value: score / len,
                  color: Colors.green,
                  backgroundColor: Colors.white,
                ),
              ),
              Column(
                children: [
                  Text(
                    score.toString(),
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${(score / len * 100).round()}%',
                    style: const TextStyle(fontSize: 25),
                  )
                ],
              ),
            ],
          ),
        ],
      ),*/
    );
  }
}