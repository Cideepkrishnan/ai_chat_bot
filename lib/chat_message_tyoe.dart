enum ChatMessageType { user, bot }

class ChatMessage {
  final String text;
  final ChatMessageType chatmessagetype;

  ChatMessage({required this.text, required this.chatmessagetype});
}
