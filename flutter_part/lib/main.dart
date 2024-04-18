import 'package:flutter/material.dart';
import 'PlayerPage.dart';
import 'HostPage.dart';
import 'before_play.dart';
import 'package:quickalert/quickalert.dart';
//ver3.0 update
//adding better warning animation
//adding button to translate the entire game into Chinese and English.
//making bingo card's button more 'circle'
//Adding player button to judge and prevent players from cheating.
void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {

  String language = 'en';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFBBFAFA)),
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) {
              TextEditingController usernameController = TextEditingController();
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_box_rounded,
                    size: 120,
                  ),
                  Text(
                    language == 'en' ? 'BINGO GAME' : '賓果遊戲',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 42.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      letterSpacing: 2.0,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: language == 'en' ? 'Enter your username' : '請輸入用戶名字',
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    child: Text(
                      language == 'en' ? 'Become a Host' : '成為遊戲主持人',
                      style: TextStyle(fontSize: 25.0),
                    ),
                    onPressed: () {
                      if (usernameController.text.isEmpty) {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.warning,
                          text: language == 'en' ?'You Need to Create Your Name!':'你必須輸入名字以開始遊戲',
                        );
                      } else {
                        String username = usernameController.text;
                        Map<String, dynamic> data = {
                          'username': username,
                          'language': language,
                        };
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HostPage(),
                            settings: RouteSettings(
                              arguments: data,
                            ),
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(300.0, 60.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    child:Text(
                      language == 'en' ? 'Become a Player' : '成為遊戲玩家',
                      style: TextStyle(fontSize: 25.0),
                    ),
                    onPressed: () {
                      if (usernameController.text.isEmpty) {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.warning,
                          text: language == 'en' ?'You Need to Create Your Name!':'你必須輸入名字以開始遊戲',
                        );
                      } else {
                        String username = usernameController.text;
                        Map<String, dynamic> data = {
                          'username': username,
                          'language': language,
                        };
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BeforePlay(),
                            settings: RouteSettings(
                              arguments: data,
                            ),
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(300.0, 60.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if(language=='en')language = 'ch';
                        else language = 'en';
                      });
                    },
                    child: Text(language == 'en' ? 'Switch to Chinese' : '切換到英文',style: TextStyle(fontSize: 20.0)),
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(250.0, 60.0),
                      ),
                    ),
                  ),

                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


