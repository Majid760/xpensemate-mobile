import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// main app class

class MyApp extends StatelessWidget {
/// constructor of main app class
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) =>
     MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  
}
/// home page of app
class MyHomePage extends StatefulWidget {
/// constructor of home page
  const MyHomePage({super.key, required this.title});
/// The title of the home page, displayed in the app bar.
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) =>
     Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'first page',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  
}
