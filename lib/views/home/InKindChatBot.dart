import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jonssony/utils/app_text.dart';

class InKindChatBot extends StatefulWidget {
  const InKindChatBot({super.key});

  @override
  State<InKindChatBot> createState() => _InKindChatBotState();
}

class _InKindChatBotState extends State<InKindChatBot> {
  final box = GetStorage();
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  int _currentStep = 0;

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
    _startConversation();
  }

  // ১. চ্যাট শুরু করার লজিক
  void _startConversation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _addBotMessage("Welcome. I'm here to support you with the behavioral aspects of your therapy as part of your weekly homework plan.");

    await Future.delayed(const Duration(seconds: 1));
    _addBotMessage("Which behavior would you like to focus on?", isOptions: true);
  }

  // ২. বটের মেসেজ যুক্ত করা
  void _addBotMessage(String text, {bool isOptions = false}) {
    setState(() {
      _messages.add({
        "text": text,
        "isBot": true,
        "time": "10:30 AM",
        "isOptions": isOptions,
      });
    });
    _scrollToBottom();
  }

  // ৩. ইউজারের মেসেজ এবং বটের রেসপন্স লজিক
  void _handleUserMessage(String text) {
    setState(() {
      _messages.add({"text": text, "isBot": false, "time": "10:30 AM"});
      _isTyping = true;
    });
    _scrollToBottom();

    // ইউজারের ইনপুট অনুযায়ী বট রিপ্লাই দিবে
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isTyping = false);
      if (_currentStep == 0) {
        _addBotMessage("I understand. $text can be really challenging. How does this behavior typically affect your daily routine?");
        _currentStep = 1;
      } else {
        _addBotMessage("Thank you for sharing that. Recognizing these patterns is the first step toward change. Would you like to explore a coping tool for this?");
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, height: 180,
            child: Image.asset('assets/images/my_emdr.png', fit: BoxFit.fill),
          ),

          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35)),
                          image: DecorationImage(image: AssetImage('assets/images/home_bg1.jpg'), fit: BoxFit.cover),
                        ),
                      ),
                    ),

                    // চ্যাট মেসেজ লিস্ট
                    ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _isTyping) {
                          return _buildTypingIndicator();
                        }
                        var msg = _messages[index];
                        if (msg["isOptions"] == true) {
                          return _buildOptionsCard(msg["text"]);
                        }
                        return _buildChatBubble(msg);
                      },
                    ),
                  ],
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  // ইমেজের মতো গ্লাস ইফেক্ট চ্যাট বাবল
  Widget _buildChatBubble(Map<String, dynamic> msg) {
    bool isBot = msg["isBot"];
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: isBot ? Colors.white.withOpacity(0.85) : const Color(0xFFD9E4D5).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: AppText(msg["text"], fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
              child: AppText(msg["time"], fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // ইমেজের মতো মাল্টিপল চয়েস কার্ড
  Widget _buildOptionsCard(String question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChatBubble({"text": question, "isBot": true, "time": "10:30 AM"}),
        ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: _options.map((opt) => _buildSingleOption(opt)).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleOption(String text) {
    return GestureDetector(
      onTap: () => _handleUserMessage(text),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: AppText(text, fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: AppText("Bot is typing...", fontSize: 12, color: Colors.black45),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Message",
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: const Color(0xFF537E5D),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _handleUserMessage(_controller.text);
                  _controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 10),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
          const AppText("Behaviors", fontSize: 20, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}