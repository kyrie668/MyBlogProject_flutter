import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Color? color;
  final VoidCallback onPressed;
  final Widget child;

  const MyButton({
    Key? key,
    this.color,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color),
        textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18.0)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        minimumSize: MaterialStateProperty.all(const Size(200.0, 50.0)),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
