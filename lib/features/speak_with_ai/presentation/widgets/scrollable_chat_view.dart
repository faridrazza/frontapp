import 'package:flutter/material.dart';
import '../../domain/models/message.dart';
import 'ai_message_bubble.dart';
import 'user_message_bubble.dart';

class ScrollableChatView extends StatefulWidget {
  final List<Message> messages;
  final bool isLoading;

  ScrollableChatView({required this.messages, required this.isLoading});

  @override
  _ScrollableChatViewState createState() => _ScrollableChatViewState();
}

class _ScrollableChatViewState extends State<ScrollableChatView> {
  ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(ScrollableChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.messages.length + (widget.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.messages.length && widget.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        final message = widget.messages[index];
        return message.type == MessageType.ai
            ? AiMessageBubble(message: message)
            : UserMessageBubble(message: message);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}