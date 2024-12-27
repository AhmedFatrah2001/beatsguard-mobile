import 'package:beatsguard/components/custom_app_bar.dart';
import 'package:beatsguard/components/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  final ChatService _chatService = ChatService();

  bool _isTyping = false;

  @override
  void initState() {
    super.initState();

    // Add initial bot message
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add({
          "text":
              "Hello! 👋 I’m Dr. Bot, your friendly medical assistant. Ask me anything about health, symptoms, or general medical advice!",
          "isUser": false,
        });
      });
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add({"text": text, "isUser": true});
    });

    _controller.clear();
    _scrollToBottom();

    // Display typing indicator
    setState(() {
      _isTyping = true;
    });

    // Fetch chatbot response
    _fetchResponse(text);
  }

  Future<void> _fetchResponse(String question) async {
    try {
      final data = await _chatService.getChatbotResponse(question);
      final answer = data["answer"] as String;
      final similarity = data["similarity"] as double;

      // Simulate typing delay
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isTyping = false;
        if (similarity < 0.7) {
          _messages.add({
            "text": "I'm sorry, I don't have enough information to answer that question.",
            "isUser": false,
          });
        } else {
          _messages.add({"text": answer, "isUser": false});
        }
      });
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add({
          "text": "Unable to connect to the server. Please check your network.",
          "isUser": false,
        });
      });
    } finally {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:const CustomAppBar(title: "Dr. Bot"),
      drawer:const CustomDrawer(),
      body: Column(
        children: [
          // Chat Display
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  // Typing Indicator
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 5),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.teal.shade200,
                            child: const Icon(Icons.smart_toy, color: Colors.white),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              "Typing...",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final message = _messages[index];
                final isUser = message["isUser"];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isUser)
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 5),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.teal.shade200,
                          child: const Icon(Icons.smart_toy, color: Colors.white),
                        ),
                      ),
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.teal.shade300
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomLeft: isUser
                                ? const Radius.circular(15)
                                : const Radius.circular(0),
                            bottomRight: isUser
                                ? const Radius.circular(0)
                                : const Radius.circular(15),
                          ),
                        ),
                        child: Text(
                          message["text"],
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    if (isUser)
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 10),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.teal.shade500,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          // Message Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  offset: const Offset(0, -2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                // Input Field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      hintText: "Ask something...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _sendMessage(_controller.text),
                  child: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
