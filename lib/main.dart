import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tic_tac_toe/utils.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'Tic Tac Toe';
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
    debugShowCheckedModeBanner: false,
    title: title,
    home: MyHomePage(title: title),
  );
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Player{
  static const none = '';
  static const x = 'X';
  static const o = 'O';
}

class _MyHomePageState extends State<MyHomePage> {
  static const countMatrix = 3;
  static const double size = 100;

  String lastMove = Player.none;
  late List<List<String>> matrix;

  @override
  void initState(){
    super.initState();

    setEmptyFields();
  }

  void setEmptyFields() => setState(() => matrix = List.generate(
      countMatrix,
        (_) => List.generate(countMatrix, (_) => Player.none),
  ));

  Color getBackgroundColor(){
    final thisMove = lastMove == Player.x ? Player.o : Player.x;

    return getFieldColor(thisMove).withAlpha(150);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: getBackgroundColor(),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black12,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: Utils.modelBuilder(matrix, (x, value) => buildRow(x)),
      ),
  );

  Widget buildRow(int x){
    final values = matrix[x];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: Utils.modelBuilder(
        values,
          (y, value) => buildField(x, y),
      ),
    );
  }

  Color getFieldColor(String value){
    switch (value){
      case Player.o:
        return Colors.cyan;

      case Player.x:
        return Colors.pinkAccent;

      default:
        return Colors.white;
    }
  }

  Widget buildField(int x, int y){
    final value = matrix[x][y];
    final color = getFieldColor(value);

    return Container(
      margin: const EdgeInsets.all(5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(size, size),
          primary: color,
        ),
        child: Text(value , style: const TextStyle(fontSize: 32)),
        onPressed: () => selectField(value, x, y),
      ),
    );
  }

  void selectField(String value, int x, int y){
    if (value == Player.none){
      final newValue = lastMove == Player.x ? Player.o : Player.x;

      setState(() {
        lastMove = newValue;
        matrix[x][y] = newValue;
      });

      if(isWinner(x, y)){
        showEndDialogue('Player $newValue Won!');
      } else if(isEnd()){
        showEndDialogue('You are tied');
      }
    }
  }

  bool isEnd() =>
    matrix.every((values) => values.every((value) => value != Player.none));

  bool isWinner(int x, int y){
    var col = 0, row = 0, diag = 0, rdiag = 0;
    final player = matrix[x][y];
    const n = countMatrix;

    for (int i = 0; i <n; i++){
      if(matrix[x][i] == player ) col++;
      if(matrix[i][y] == player ) row++;
      if(matrix[i][i] == player ) diag++;
      if(matrix[i][n - i - 1] == player ) rdiag++;
    }
    return row == n || col == n || diag == n || rdiag == n;
  }

  Future showEndDialogue(String title) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('Click to restart the game'),
        actions: [
          ElevatedButton(
              onPressed: () {
                setEmptyFields();
                Navigator.of(context).pop();
              },
              child: const Text('Restart'),
          )
        ],
      ),
  );
}


