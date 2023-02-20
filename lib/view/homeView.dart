import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TerminalController _terminalController = TerminalController();

  Terminal _terminal =
      Terminal(maxLines: 10000, platform: TerminalTargetPlatform.android);
  late Pty pty;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.endOfFrame.then((_) {
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
        ),
      ),
    );
  }
}
