import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider2_multi_provider/user.dart';



/*
* ProxyProvider0 and the others (the rest)
* Why use ProxyProvider - 외부에서 들어오는 데이터에 따라 값이 변경될 수 있기에 기존 프로바이더의 create 는 대응이 안된다.
* 당연히 MultiProvider 안에서 사용할 수 있지.
* MultiProvider 안에서 사용하면 복잡하니깐 변수로 돌려서 쉽게하는 방법도 있다.
*
* the others 들은 모두 MultiProvider 의 다른 Provider 들의 type 을 listening 하고 있다는 걸 명심하자. 갯수의 차이만 있다는 걸..
* 밑에 보면 나와 았지만 ProxyProvider0 는 listening 을 하지 않지만 인자로 값을 넣어주는 것도 실시간으로 변경시키는 방법으로 사용할 수 있다.
            MultiProvider(
              providers: [
                ProxyProvider0<int>(update: (context, _) => _counter ), // 앞에서 하나만 사용할 때 인자로 마구잡이로 넣으려는 걸 이렇게 해결 할 수 있네.
                // 잘봐라. <int> 를 통해서 외부에서 변경되는 값을 받아들이고, 그값을 자식이 provider.of(context) 를 통해서 사용할 수 있고
                ProxyProvider<int, Translations>(update: (context, counter, __) => Translations(counter)), // 앞의 변경되는 값을 넣은 Translations 객체가 child 로 넘어간다는 거지.
                // 잘봐라. <int, Translations> 를 통해서 외부에서 벽여되는 값을 받아들이고, 그 받은 자식을 인자로 사용하고, 그 만들어진 객체를 자식이 provider.of(context) 를 통해서 사용할 수 있다.
                // 다른 provider 의 값을 listening 할 수 있다는게 가장 큰 차이점이다. listening type 아주 중요하다.
              ],
              child: const CounterNumber(),


*  현재 여기서 사용하고 있는 setState 를 사용하고 있다.
 */

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<User>(create: (context) => User(name: "Steve Lee", age: 52)),
        Provider(create: (context) => FirstPartSentence("You clicked the button "),), // 밑에서 쓰니깐.. 여기 만들어 놓은거네..
        Provider(create: (context) => SecondPartSentence(" times"),) // 그래서 지우면 안되네..
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title; // 알지? widget.title 로 State<MyHomePage> 에서 사용하는걸..

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0; // 잘봐라. 같은데 있다. 잘봐라고...여기 같은 클래스안에 이 변수가 사용되고 있잖아... 뭐가 문젠데..
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    //print(_counter);
  }

  @override
  Widget build(BuildContext context) {
    // [error] The instance member 'context' can't be accessed in an initializer.
    // [answer] 여기 State<MyHomePage 에는 context 가 존재하지 않는다. 그러니깐 없지. 방법은 context 가 있는 build 안에다가 넣어라.
    var user = Provider.of<User>(context);
    // 값을 변경하는게 가능한가? 가능하지.. 그래서 전역변수처럼 사용할 수 있다. global variable
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times: \n and Your name is  ${user.name} and age is ${user.age}',


            ),
            ProxyProvider0<Translations>(
              update: (context, translations) {
                final firstPart = Provider.of<FirstPartSentence>(context).text;
                // 그리니깐 여기서 이렇게 불러서 써도 되나는 걸 보여주는거지..
                final secondPart = Provider.of<SecondPartSentence>(context).text;
                return Translations(firstPart+ _counter.toString() + secondPart); // ProxyProvider0 이기 때문에 변경되는 값이 하위 위젯에 들어간다.
              },
              child: const CounterText(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class SecondPartSentence {

  SecondPartSentence(this._value);
  final String _value;
  String get text => _value;
}

class FirstPartSentence {
  FirstPartSentence(this._value);
  final String _value;
  String get text => _value;
}

class Translations {
  const Translations(this._value);
  final String _value;
  String get title => _value;
}

class CounterText extends StatelessWidget {
  const CounterText({Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var translations = Provider.of<Translations>(context).title;
    return
      Text(
        translations,
        style: Theme.of(context).textTheme.headline4,
      );
  }
}

