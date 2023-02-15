import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TerminalController _terminalController = TerminalController();

  Terminal _terminal =
      Terminal(maxLines: 10000, platform: TerminalTargetPlatform.android);
  Pty pty = Pty.start('sh');

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.endOfFrame.then((_) {
      pty.kill(ProcessSignal.sigkill);
      if (mounted) _startPty();
    });
  }

  void _startPty() {
    pty = Pty.start(
      'sh',
      columns: _terminal.viewWidth,
      rows: _terminal.viewHeight,
    );

    pty.output
        .cast<List<int>>()
        .transform(const Utf8Decoder())
        .listen(_terminal.write);

    pty.exitCode.then((code) {
      var snackBar = SnackBar(content: Text('Terminal exited with $code'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      setState(() {
        _terminal =
            Terminal(maxLines: 10000, platform: TerminalTargetPlatform.android);
      });

      _startPty();
    });

    _terminal.onOutput = (data) {
      pty.write(const Utf8Encoder().convert(data));
    };

    _terminal.onResize = (w, h, pw, ph) {
      pty.resize(h, w);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onDoubleTap: () {
              pty.kill(ProcessSignal.sigkill);
            },
            child: TerminalView(
              _terminal,
              controller: _terminalController,
              autofocus: true,
              backgroundOpacity: 1.0,
              /*onSecondaryTapDown: (details, offset) async {
              final selection = _terminalController.selection;

              if (selection != null) {
                final text = _terminal.buffer.getText(selection);
                _terminalController.clearSelection();
                await Clipboard.setData(ClipboardData(text: text));
              } else {
                final data = await Clipboard.getData('text/plain');
                final text = data?.text;

                if (text != null) {
                  _terminal.paste(text);
                }
              }
            }*/
            )));
  }
}
