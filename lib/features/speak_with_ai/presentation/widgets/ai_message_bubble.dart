import 'package:flutter/material.dart';
import '../../domain/models/message.dart';
// import '../../../../core/utils/audio_utils.dart';

class AIMessageBubble extends StatelessWidget {
  final Message message;

  const AIMessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Color(0xFFA25BE3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.content,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}