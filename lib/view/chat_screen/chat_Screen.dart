import 'dart:convert';

import 'package:ai_chat_bot/chat_message_tyoe.dart';
import 'package:ai_chat_bot/view/chat_screen/widgets/chat_message_widget/chat-mesaage_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

Future<String> generateResponse(String project) async {
  const apikey = "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";
  var url = Uri.https("api.openai.com", "/v1/completions");
  var prompt;
  final response = await http.post(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apikey"
    },
    body: json.encode({
      "model": "text-davinci-003",
      "prompt": prompt,
      "temperature": 1,
      "max_tokens": 4000,
      "top_p": 1,
      "frequency_penality": 0.0,
      "presence_penality": 0.0,
    }),
  );
  Map<String, dynamic> newresponce = jsonDecode(response.body);

  return newresponce['choices'][0]['text'];
}

class _ChatScreenState extends State<ChatScreen> {
  final _textcontroller = TextEditingController();
  final _scrollcontroller = ScrollController();
  final List<ChatMessage> _message = [];
  late bool isLoading;

  @override
  void initstate() {
    super.initState();
    isLoading = false;
  }

  void _scrollDown() {
    _scrollcontroller.animateTo(_scrollcontroller.position.maxScrollExtent,
        duration: Duration(microseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Al chat Bot"),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Color(0xFF343541),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
              controller: _scrollcontroller,
              itemCount: _message.length,
              itemBuilder: (context, index) {
                var message = _message[index];
                return ChatMessageWidget(
                  text: message.text,
                  chatMessageType: message.chatmessagetype,
                );
              },
            )),
            Visibility(
              visible: isLoading,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(color: Colors.white),
                      controller: _textcontroller,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFF444654),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none),
                    ),
                  ),
                  Visibility(
                    visible: !isLoading,
                    child: Container(
                      color: Color(0xFF444654),
                      child: IconButton(
                        icon: Icon(
                          Icons.send_rounded,
                          color: Color.fromRGBO(142, 142, 160, 1),
                        ),
                        onPressed: () async {
                          setState(() {
                            _message.add(
                              ChatMessage(
                                  text: _textcontroller.text,
                                  chatmessagetype: ChatMessageType.user),
                            );
                            isLoading = true;
                          });
                          var input = _textcontroller.text;
                          _textcontroller.clear();
                          Future.delayed(Duration(milliseconds: 50))
                              .then((_) => _scrollDown());
                          generateResponse(input).then((value) {
                            setState(() {
                              isLoading = false;
                              _message.add(
                                ChatMessage(
                                    text: value,
                                    chatmessagetype: ChatMessageType.bot),
                              );
                            });
                          });
                          _textcontroller.clear();
                          Future.delayed(Duration(milliseconds: 50))
                              .then((_) => _scrollDown());
                        },
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
