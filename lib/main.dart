import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Gemini API",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final GenerativeModel generativeModel;
  Stream<GenerateContentResponse> stream = const Stream.empty();
  late final TextEditingController controller;
  String lastResponse = "";

  @override
  void initState() {
    super.initState();

    controller = TextEditingController();

    generativeModel = GenerativeModel(
      model: "gemini-pro",
      apiKey: "", // Your api key
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("GEMINI"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                StreamBuilder(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      Column(
                        children: <Widget>[
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text('Error: ${snapshot.error}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Stack trace: ${snapshot.stackTrace}'),
                          ),
                        ],
                      );
                    }
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Column(
                          children: [
                            Text(lastResponse),
                            const CircularProgressIndicator(),
                          ],
                        );
                      case ConnectionState.active:
                        lastResponse = lastResponse + (snapshot.data?.text ?? "");

                        return Column(
                          children: [
                            Text(lastResponse),
                            const SizedBox(height: 12),
                            const CircularProgressIndicator(),
                          ],
                        );
                      case ConnectionState.done:
                        lastResponse = lastResponse + (snapshot.data?.text ?? "");

                        return Text(lastResponse);
                      default:
                        return const Text("else");
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSubmitted(),
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Type something...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton(
                  onPressed: onSubmitted,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onSubmitted() {
    final text = controller.text;

    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      stream = generativeModel.generateContentStream([Content.text(text)]);
      controller.clear();
    });
  }
}
