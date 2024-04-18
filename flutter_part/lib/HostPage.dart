import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_common/src/util/event_emitter.dart';

class HostPage extends StatefulWidget {

  @override
  _HostPageState createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  late IO.Socket socket;
  String countFromServer = '0';
  String gameState = '0';
  String end_message = ' ';
  bool isButtonVisible = false;
  bool game_play = false;
  bool before_game = true;
  bool end_game = false;
  List<List<String>> buttonText = List.generate(
      5, (index) => List.filled(5, ""));
  List<List<bool>> buttonStates = List.generate(
      5, (index) => List.filled(5, false));
  late List<String> bingoNumbers = List.filled(6, " ");
  bool animate = false;
  @override
  void initState() {
    super.initState();
    connectToNode("host");
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        if ((i * 5 + j + 1) < 10) {
          buttonText[i][j] = '0' + (i * 5 + j + 1).toString();
        }
        else
          buttonText[i][j] = (i * 5 + j + 1).toString();
      }
    }
  }

  Widget buildElevatedButton(int row, int col) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(5, 40),
        backgroundColor: buttonStates[row][col] ? Colors.red[200] : Colors.teal[300],
      ),
      onPressed: () {
        setState(() {
          if (!buttonStates[row][col]) {
            animate = true;
            buttonStates[row][col] = true;
            sendBingoNumber(socket,buttonText[row][col]);
            Future.delayed(Duration(milliseconds: 200), () {
              setState(() {
                animate = false; // 500 毫秒后将动画变量设置为 false
                bingoNumbers[5] = bingoNumbers[4];
                bingoNumbers[4] = bingoNumbers[3];
                bingoNumbers[3] = bingoNumbers[2];
                bingoNumbers[2] = bingoNumbers[1];
                bingoNumbers[1] = bingoNumbers[0];
                bingoNumbers[0] = buttonText[row][col];
              });
            });
          }
        });
      },
      child: Text(
        buttonText[row][col],
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var buttonSpacing = 5.0;
    final element = ModalRoute
        .of(context)!
        .settings
        .arguments as Map<String, dynamic>;
    final String username = element['username'];
    final String language = element['language'];
    String identify = ' ';
    if(language == 'en'){
      if(gameState=='0'||gameState=='1') identify = 'There is ${gameState} player';
      else identify = 'There are ${gameState} player';
    }
    else{
      identify = '現在有${gameState}玩家';
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: before_game,
              child: Column(
                children: [
                  Text(
                    language == 'en' ?'Welcome , ${username}':'歡迎 , ${username}',
                    style: TextStyle(color: Colors.black, fontSize: 25.0),
                  ),
                  Text(
                    language == 'en' ?"Please wait...":'請稍微等待...',
                    style: TextStyle(color: Colors.black, fontSize: 35.0),
                  ),
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Lottie.asset('assets/animation/waiting.json',frameRate: FrameRate.max,),
                  ),
                  Text(
                    identify,
                    style: TextStyle(color: Colors.black, fontSize: 27.0),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: isButtonVisible,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    game_play = true;
                    isButtonVisible = false;
                    before_game = false;
                    sendMessageToServer(socket);
                  });
                },
                child: Text(
                    language == 'en' ?'Let the game BEGIN!!':'讓遊戲開始吧!!',
                    style: TextStyle(fontSize: 30.0)
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  fixedSize: Size(400.0, 60.0),
                ),
              ),
            ),
            Visibility(
              visible: game_play,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    language == 'en' ?'The last five drawn numbers:':'上五個開出的數字',
                    style: TextStyle(fontSize: 22.0),
                    textAlign: TextAlign.left,
                  ),
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
                    language == 'en' ?'NOW bingo numbers:':'現在開出的數字:',
                    style: TextStyle(fontSize: 27.0),
                    textAlign: TextAlign.left,
                  ),
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
                        duration: Duration(milliseconds: 200), // 动画持续时间
                        curve: Curves.easeInOut, // 动画曲线
                        transform: animate ? Matrix4.translationValues(0.0, -5.0, 0.0) : Matrix4.translationValues(0.0, 0.0, 0.0),
                        child: BingoBall(number: bingoNumbers[0]),
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  Text(
                    language == 'en' ? 'Press buttom to send the number':'按下按鈕發送數字',
                    style: TextStyle(fontSize: 22.0),
                  ),
                  SizedBox(height: 20),
                  for (int row = 0; row < 5; row++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int col = 0; col < 5; col++)
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: buttonSpacing),
                            child: buildElevatedButton(row, col),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            Visibility(
              visible: end_game,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      language == 'en' ?"GAME END":'遊戲結束',
                      style: TextStyle(
                        fontSize: 40.0,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      language == 'en' ?'Player ${end_message} win the game':'玩家${end_message}贏下遊戲',
                      style: TextStyle(
                        fontSize: 30.0,
                        color: Colors.red,
                      ),
                    ),

                  ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  void connectToNode(String who) {
    socket = IO.io('http://10.201.35.106:3000', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'role': who},
    });

    socket.on('connect', (_) {
      print('Connected to Node.js server');
    });

    socket.on('message', (data) {
      print('Message from Node.js: $data');
    });

    socket.on('countUpdate', (data) {
      print('Count update from server: $data');
      setState(() {
        countFromServer = data.toString();
        if (countFromServer == "0" || countFromServer == "1") {
          gameState = countFromServer;
        } else {
          gameState = countFromServer;
        }
        if (countFromServer == "1") {
          isButtonVisible = true;
        }
      });
    });
    socket.on('end_game', (data) {
      setState(() {
        end_game = true;
        game_play = false;
        end_message = data;
      });
    });
    socket.on('disconnect', (_) {
      print('Disconnected from Node.js server');
    });
  }

  void sendMessageToServer(IO.Socket socket) {
    socket.emit('startGame');
  }
  void sendBingoNumber(IO.Socket socket,String num) {
    socket.emit('BingoNumber' , num);
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
