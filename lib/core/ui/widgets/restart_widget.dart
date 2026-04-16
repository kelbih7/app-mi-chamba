import 'package:flutter/material.dart';

class RestartWidget extends StatefulWidget {
  final Widget child;

  RestartWidget({required this.child}) : super(key: _key);

  static final GlobalKey<_RestartWidgetState> _key =
      GlobalKey<_RestartWidgetState>();

  static void restart() {
    _key.currentState?.restart();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key _subtreeKey = UniqueKey();

  void restart() {
    setState(() {
      _subtreeKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _subtreeKey, child: widget.child);
  }
}
