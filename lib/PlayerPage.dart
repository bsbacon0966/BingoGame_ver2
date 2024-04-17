import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:lottie/lottie.dart';
import 'package:quickalert/quickalert.dart';

class PlayerPage extends StatefulWidget {

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late IO.Socket socket;
  late List<List<bool>> buttonStates;
  late List<List<String>> buttonText;
  late String language;
  List<String> bingoNumbers = List.filled(6, " ");
  List<bool> has_open_number = List.filled(26,false);
  bool waiting = true;
  bool game_start = false;
  bool animate = false;
  bool win = false;
  bool end = false;
  String end_message = " ";
  bool emoji_initial = true;
  bool has_emoji = false;
  int emoji_ID = -1;
  String message_sender = " ";
  @override
  void initState() {
    super.initState();
    buttonStates = List.generate(5, (_) => List.filled(5, false));
    buttonText = List.generate(5, (_) => List.filled(5, " "));
    connectToNode("player");
  }

  Widget buildElevatedButton(int row, int col) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(16),
        backgroundColor: buttonStates[row][col] ? Colors.red[300] : Colors.teal[400],
      ),
      onPressed: () {
        setState(() {
          if(has_open_number[int.parse(buttonText[row][col])]==false){
            QuickAlert.show(
              context: context,
              type: QuickAlertType.warning,
              text: language == 'en' ?'You cannot click on numbers that have not yet been drawn.':'你不能點選還未開出的數字',
            );
          }
          else buttonStates[row][col] = !buttonStates[row][col];
        });
      },
      child: Text(
        buttonText[row][col],
        style: TextStyle(
            color: Colors.white,
            fontSize: 23
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final element = ModalRoute
        .of(context)!
        .settings
        .arguments as Map<String, dynamic>;
    final String username = element['username'];
    buttonText= element['buttomText'];
    language = element['language'];
    var buttonSpacing = 5.0;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: waiting,
              child: Column(
                children: [
                  Container(
                    child: Text(
                      language == 'en' ? 'Waiting host to start the game...':'等待主持人開始遊戲',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Lottie.asset('assets/animation/b7.json'),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: game_start,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    language == 'en' ?'The last five drawn numbers:':'上五個數:', style: TextStyle(fontSize: 22.0),  textAlign: TextAlign.left,),
                  Row(
                    children: [
                      BingoBall(number: bingoNumbers[1]),
                      SizedBox(width: 16),
                      BingoBall(number: bingoNumbers[2]),
                      SizedBox(width: 16),
                      BingoBall(number: bingoNumbers[3]),
                      SizedBox(width: 16),
                      BingoBall(number: bingoNumbers[4]),
                      SizedBox(width: 16),
                      BingoBall(number: bingoNumbers[5]),
                    ],
                  ),
                  Container(
                    width: 400,
                    height: 10,
                    color: Colors.red,
                  ),
                  Text(
                    language == 'en' ?'NOW bingo numbers:':'現在開出:', style: TextStyle(fontSize: 27.0),  textAlign: TextAlign.left,),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        transform: animate ? Matrix4.translationValues(0.0, -5.0, 0.0) : Matrix4.translationValues(0.0, 0.0, 0.0),
                        child: BingoBall(number: bingoNumbers[0]),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: emoji_initial,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children:[
                        Visibility(
                            visible: has_emoji,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children:[
                                  Text(
                                    '${message_sender}:',
                                    style: TextStyle(fontSize: 25),
                                  ),
                                  SizedBox(width: 8.0),
                                  Image.asset(
                                    emoji_ID == 1 ? 'assets/images.jpg' : 'assets/oops.jpg',
                                    width: 24.0,
                                    height: 24.0,
                                  ),
                                ],
                              ),
                            ),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              emoji_initial = false;
                            });
                          },
                          child: Text(
                            'emoji',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ButtonStyle(
                            fixedSize: MaterialStateProperty.all<Size>(
                              Size(100.0, 60.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: !emoji_initial,
                    child: Container(
                      color: Colors.black26,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children:[
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                emoji_initial = true;
                                socket.emit('cool_emoji',username);
                              });
                            },
                            child: Image.asset(
                              'assets/images.jpg',
                              width: 30.0,
                              height: 30.0,
                            ),
                            style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all<Size>(
                                Size(100.0, 60.0),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                emoji_initial = true;
                                socket.emit('oops_emoji',username);
                              });
                            },
                            child: Image.asset(
                              'assets/oops.jpg',
                              width: 30.0,
                              height: 30.0,
                            ),
                            style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all<Size>(
                                Size(100.0, 60.0),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                emoji_initial = true;
                              });
                            },
                            child:  Text(
                              'X',
                              style: TextStyle(fontSize: 18),
                            ),
                            style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all<Size>(
                                Size(100.0, 60.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  for (int row = 0; row < 5; row++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int col = 0; col < 5; col++)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: buttonSpacing),
                            child: buildElevatedButton(row, col),
                          ),
                        SizedBox(height: 60),
                      ],
                    ),
                  ElevatedButton(
                    onPressed: () {
                      if(bingo_judge_is_win_or_not()){
                        socket.emit('player_has_bingo',username);
                        setState(() {
                          win = true;
                        });
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(language == 'en' ?'You must have 3 lines to win the game':'你必須要有三條連線'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Text(
                        language == 'en' ?'send BINGO to host':'和主持人說賓果',
                        style: TextStyle(fontSize: 30.0)
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                      fixedSize: Size(400.0, 60.0),
                    ),
                  ),
                ],
              ),
            ),

            Visibility(
                visible: end,
                child: Column(
                    children: [
                      Text(
                          language == 'en' ?'player ${end_message} has 3 lines':'玩家 ${end_message}連成三條線',
                          style: TextStyle(fontSize: 30.0)
                      ),
                      Visibility(
                          visible: win,
                          child:Column(
                              children: [
                                Lottie.asset('assets/animation/cele.json'),
                                Text(
                                    language == 'en' ?"You're the winner":'你是贏家',
                                    style: TextStyle(fontSize: 30.0,color:Colors.red)
                                ),
                                Text(
                                    language == 'en' ?"Congratulations!":'恭喜你!',
                                    style: TextStyle(fontSize: 30.0,color:Colors.red)
                                )
                              ]
                          )
                      ),
                    ]
                )
            ),
          ],
        ),
      ),
    );
  }

  bool bingo_judge_is_win_or_not() {
    List<bool> is_line = List.generate(12, (index) => true);
    for(int i=0;i<5;i++){
      if(buttonStates[i][0]==false){
        is_line[0] = false;
      }
      if(buttonStates[i][1]==false){
        is_line[1] = false;
      }
      if(buttonStates[i][2]==false){
        is_line[2] = false;
      }
      if(buttonStates[i][3]==false){
        is_line[3] = false;
      }
      if(buttonStates[i][4]==false){
        is_line[4] = false;
      }
      if(buttonStates[0][i]==false){
        is_line[5] = false;
      }
      if(buttonStates[1][i]==false){
        is_line[6] = false;
      }
      if(buttonStates[2][i]==false){
        is_line[7] = false;
      }
      if(buttonStates[3][i]==false){
        is_line[8] = false;
      }
      if(buttonStates[4][i]==false){
        is_line[9] = false;
      }
      if(buttonStates[i][i]==false){
        is_line[10] = false;
      }
      if(buttonStates[i][4-i]==false){
        is_line[11] = false;
      }
    }
    int count_line = 0;
    for(int k=0;k<12;k++){
      if(is_line[k]) count_line++;
    }
    if(count_line>=3) return true;
    else return false;
  }

  void connectToNode(String who) {
    socket = IO.io('http://10.201.35.106:3000', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'role': who},
    });

    socket.on('connect', (_) {
      print('Connected to Node.js server');
    });

    socket.on('startGame', (_) {
      setState(() {
        waiting = false;
        game_start = true;
      });
    });

    socket.on('message', (data) {
      print('Message from Node.js: $data');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from Node.js server');
    });

    socket.on('BingoNumber', (data) {
      print('Number: $data');
      setState(() {
        animate = true;
        Future.delayed(Duration(milliseconds: 200), () {
          setState(() {
            animate = false;
            bingoNumbers[5] = bingoNumbers[4];
            bingoNumbers[4] = bingoNumbers[3];
            bingoNumbers[3] = bingoNumbers[2];
            bingoNumbers[2] = bingoNumbers[1];
            bingoNumbers[1] = bingoNumbers[0];
            bingoNumbers[0] = data;
            has_open_number[int.parse(data)] = true;
          });
        });
      });
    });
    socket.on('end_game', (data) {
      setState(() {
        game_start = false;
        end = true;
        end_message = data;
      });
    });
    socket.on('cool_emoji_receive', (data) {
      setState(() {
        message_sender = data;
        emoji_ID = 1;
        has_emoji = true;
      });
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          has_emoji = false; // 3秒后将 has_emoji 的值从 true 转换为 false
        });
      });
    });
    socket.on('oops_emoji_receive', (data) {
      setState(() {
        message_sender = data;
        emoji_ID = 2;
        has_emoji = true;
      });
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          has_emoji = false; // 3秒后将 has_emoji 的值从 true 转换为 false
        });
      });
    });
  }
}


class BingoBall extends StatelessWidget {
  final String number;

  const BingoBall({Key? key, required this.number}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
