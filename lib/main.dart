import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageModel(),
      child: MyApp(),
    ),
//    const MyApp());
  );
}

class LanguageModel extends ChangeNotifier {
  String _selectedLanguage = 'English';

  String get selectedLanguage => _selectedLanguage;

  void setSelectedLanguage(String language) {
    print("Language is now: " + language);
    _selectedLanguage = language;
    notifyListeners();
  }
}

class LanguageSelector extends StatefulWidget {
  @override
  _LanguageSelectorState createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Español',
    'Français',
    'Deutsch',
    '中文',
    '日本語',
  ];

  @override
  Widget build(BuildContext context) {
    final languageModel = Provider.of<LanguageModel>(context);

    return DropdownButton<String>(
      value: languageModel.selectedLanguage,
      onChanged: (String? newValue) {
        if (newValue != null) {
          languageModel.setSelectedLanguage(newValue);
        }
      },
      items: [
        'English',
        'Spanish',
        'French',
        'German',
        'Arabic',
        'Ukranian',
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late IO.Socket socket;
  int _counter = 0;
  late LanguageModel _languageModel;
  bool socketInitialized = false;

  String myText = "Waiting for new text";
  String myTranslatedText = "Waiting for translation";

  late String dropdownValue = "";
  static const Map<String, String> lang = {
    "None": "",
    "Arabic": "ar",
    "English": "en",
    "French": "fr",
    "German": "de",
  };

  void _onLanguageChanged() {
    String selectedLanguage = _languageModel.selectedLanguage;
    print("Detected language change to " + selectedLanguage);
  }

  @override
  void initState() {
    super.initState();
    _languageModel = Provider.of<LanguageModel>(context, listen: false);
    _languageModel.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    socket.disconnect();
    _languageModel.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void updateText(newText) {
    setState(() {
      myText = '$myText ' + newText;
    });
  }

  void resetText() {
    setState(() {
      myText = '';
    });
  }

  void updateTranslatedText(newText) {
    setState(() {
      myTranslatedText = '$myTranslatedText ' + newText;
    });
  }

  void resetTranslatedText() {
    setState(() {
      myTranslatedText = '';
    });
  }

  void _startListening() {
    resetText();
    resetTranslatedText();
    if (!socketInitialized) {
      _initSocket();
      socketInitialized = true;
    }

    setState(() {});
  }

  void _stopListening() {
    setState(() {});
  }

  Future<void> _initSocket() async {
    socket =
        IO.io('https://live-pegasus-first.ngrok-free.app', <String, dynamic>{
      'path': '/socket.io',
      'transports': ['websocket'],
      'autoconnect': false,
    });
    socket.connect();
    socket.on('connect', (_) {
      print('connected to websocket');
    });
    socket.on('transcript', (transcript) {
      print('Received transcript: ' + transcript);
      updateText(transcript);
    });
    socket.on('translation', (translation) {
      print('Received translation: ' + translation);
      updateTranslatedText(translation);
    });
  }

  void trans() {
    setState(() {
      print("Selected language: " + dropdownValue);
      socket.emit("subscribe", dropdownValue);
    });
  }

  //void _incrementCounter() {
  //  setState(() {
  //    // This call to setState tells the Flutter framework that something has
  //    // changed in this State, which causes it to rerun the build method below
  //    // so that the display can reflect the updated values. If we changed
  //    // _counter without calling setState(), then the build method would not be
  //    // called again, and so nothing would appear to happen.
  //    _counter++;
  //  });
  //}

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
//    return Scaffold(
//      appBar: AppBar(
//        // TRY THIS: Try changing the color here to a specific color (to
//        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//        // change color while the other colors stay the same.
//        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//        // Here we take the value from the MyHomePage object that was created by
//        // the App.build method, and use it to set our appbar title.
//        title: Text(widget.title),
//      ),
//      body: Center(
//        // Center is a layout widget. It takes a single child and positions it
//        // in the middle of the parent.
//        child: Column(
//          // Column is also a layout widget. It takes a list of children and
//          // arranges them vertically. By default, it sizes itself to fit its
//          // children horizontally, and tries to be as tall as its parent.
//          //
//          // Column has various properties to control how it sizes itself and
//          // how it positions its children. Here we use mainAxisAlignment to
//          // center the children vertically; the main axis here is the vertical
//          // axis because Columns are vertical (the cross axis would be
//          // horizontal).
//          //
//          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//          // action in the IDE, or press "p" in the console), to see the
//          // wireframe for each widget.
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            Text(
//              myText,
//            ),
//            Text(
//              '$_counter',
//              style: Theme.of(context).textTheme.headlineMedium,
//            ),
//          ],
//        ),
//      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {
//          updateText('');
//          _incrementCounter;
//          _startListening();
//        },
//        tooltip: 'Increment',
//        child: const Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
//    );

//    return ChangeNotifierProvider(
//        create: (_) => LanguageModel(),
//        child:
//            Consumer<LanguageModel>(builder: (context, languageModel, child) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Live Transcription with Deepgram'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
//            LanguageSelector(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Select Language here =>"),
                DropdownButton<String>(
                  value: dropdownValue,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue != null) {
                        dropdownValue = newValue;
                        trans();
                      }
                    });
                  },
                  items: lang
                      .map((string, value) {
                        return MapEntry(
                          string,
                          DropdownMenuItem<String>(
                            value: value,
                            child: Text(string),
                          ),
                        );
                      })
                      .values
                      .toList(),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    width: 150,
                    child: Text(
                      myText,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 50,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    width: 150,
                    child: Text(
                      myTranslatedText,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 50,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: () {
                      updateText('');
                      _startListening();
                    },
                    child: const Text('Start', style: TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(width: 5),
                  OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    onPressed: () {
                      updateText('');
                      _stopListening();
                    },
                    child: const Text('Stop', style: TextStyle(fontSize: 30)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
//        }));
  }
}
