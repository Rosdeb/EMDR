import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/utils/app_text.dart';

class SessionOne extends StatefulWidget {
  const SessionOne({super.key});

  @override
  State<SessionOne> createState() => _SessionOneState();
}

class _SessionOneState extends State<SessionOne> {
  final box = GetStorage();
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  int _step = 0;

  final List<String> _options = [
    "Avoiding social situations",
    "Checking doors repeatedly",
    "Procrastinating on important tasks",
    "Avoiding conflict conversations",
    "Excessive reassurance seeking",
  ];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    if (_messages.isEmpty) _startChat();
  }

  void _loadChatHistory() {
    var saved = box.read('chat_history');
    if (saved != null) setState(() => _messages.addAll(List<Map<String, dynamic>>.from(saved)));
  }

  void _startChat() async {
    _addMessage("Welcome. I'm here to support you with the behavioral aspects of your therapy as part of your weekly homework plan.", true);
    await Future.delayed(const Duration(seconds: 1));
    _addMessage("Which behavior would you like to focus on?", true, isOptions: true);
  }

  void _addMessage(String text, bool isBot, {bool isOptions = false}) {
    setState(() {
      _messages.add({
        "text": text,
        "isBot": isBot,
        "time": "10:30 AM",
        "isOptions": isOptions,
      });
    });
    box.write('chat_history', _messages);
    _scrollToBottom();
  }

  void _handleUserAction(String text) {
    _addMessage(text, false);
    setState(() => _isTyping = true);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isTyping = false);
      if (_step == 0) {
        _addMessage("I see. Focusing on '$text' is a great start. How often does this happen?", true);
        _step = 1;
      } else {
        _addMessage("Thank you for sharing. We will work on this in your next session.", true);
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Positioned(top: 0, left: 0, right: 0, height: 180,
              child: Image.asset('assets/images/my_resources.png', fit: BoxFit.fill)),

          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Stack(
                  children: [

                    Positioned.fill(child: Image.asset('assets/images/chatbot_bg.jpg', fit: BoxFit.cover)),

                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) return const Text("Typing...");
                        var msg = _messages[index];
                        return msg["isOptions"] ? _buildOptions(msg["text"]) : _buildBubble(msg);
                      },
                    ),
                  ],
                ),
              ),
              _buildInput(),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildBubble(Map<String, dynamic> msg) {
    bool isBot = msg["isBot"];
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.symmetric(vertical: 5),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isBot ? Colors.white.withOpacity(0.8) : const Color(0xFFD9E4D5).withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: AppText(msg["text"], color: Colors.black87, fontSize: 14),
          ),
          AppText(msg["time"], fontSize: 10, color: Colors.black54),
        ],
      ),
    );
  }

  // ইমেজ 40c2be অনুযায়ী অপশন কার্ড
  Widget _buildOptions(String question) {
    return Column(
      children: [
        _buildBubble({"text": question, "isBot": true, "time": "10:30 AM"}),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(25)),
          child: Column(
            children: _options.map((opt) => GestureDetector(
              onTap: () => _handleUserAction(opt),
              child: Container(
                width: double.infinity, margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: AppText(opt, fontSize: 14),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "Message", border: InputBorder.none))),
          CircleAvatar(backgroundColor: const Color(0xFF537E5D), child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: () => _handleUserAction(_controller.text))),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
      child: Row(children: [IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()), const AppText("Behaviors", fontWeight: FontWeight.bold)]),
    );
  }
}