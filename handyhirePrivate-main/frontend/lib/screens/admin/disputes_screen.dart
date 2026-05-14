import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DisputesScreen extends StatefulWidget {
  const DisputesScreen({super.key});

  @override
  State<DisputesScreen> createState() => _DisputesScreenState();
}

class _DisputesScreenState extends State<DisputesScreen> {
  final List<Map<String, dynamic>> _ongoingDisputes = [
    {
      'id': 'DSP-001',
      'accountName': 'Kamal Perera',
      'section': 'Payment Issue',
      'title': 'Charged twice for plumbing service',
      'status': 'ongoing',
      'messages': [
        {'sender': 'user', 'text': 'Hi, I was charged twice for the job TRK-9021A.', 'time': '10:00 AM'},
        {'sender': 'admin', 'text': 'Hello Kamal, we are looking into this right now. Please give us a moment.', 'time': '10:05 AM'},
      ]
    },
    {
      'id': 'DSP-002',
      'accountName': 'Suresh Dinesh',
      'section': 'Provider Behavior',
      'title': 'Provider was very rude and late',
      'status': 'ongoing',
      'messages': [
        {'sender': 'user', 'text': 'The electrician arrived 2 hours late and was very rude.', 'time': '09:15 AM'},
      ]
    },
  ];

  final List<Map<String, dynamic>> _closedDisputes = [
    {
      'id': 'DSP-000',
      'accountName': 'Nuwan Silva',
      'section': 'App Bug',
      'title': 'Cannot upload profile picture',
      'status': 'closed',
      'messages': [
        {'sender': 'user', 'text': 'Every time I try to upload a pic, the app crashes.', 'time': 'Yesterday'},
        {'sender': 'admin', 'text': 'We have fixed this in the latest update. Please update your app.', 'time': 'Yesterday'},
      ]
    },
  ];

  void _closeDispute(Map<String, dynamic> dispute) {
    setState(() {
      _ongoingDisputes.removeWhere((d) => d['id'] == dispute['id']);
      dispute['status'] = 'closed';
      _closedDisputes.insert(0, dispute);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dispute closed successfully.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1E3F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B1E3F),
          elevation: 0,
          title: Text('Disputes & Support',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: const Color(0xFFB18E44))),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: Color(0xFFB18E44),
            labelColor: Color(0xFFB18E44),
            unselectedLabelColor: Colors.white54,
            tabs: [Tab(text: 'Ongoing'), Tab(text: 'Closed')],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDisputeList(_ongoingDisputes, isOngoing: true),
            _buildDisputeList(_closedDisputes, isOngoing: false),
          ],
        ),
      ),
    );
  }

  Widget _buildDisputeList(List<Map<String, dynamic>> disputes, {required bool isOngoing}) {
    if (disputes.isEmpty) {
      return Center(
        child: Text(
          isOngoing ? 'No ongoing disputes!' : 'No closed disputes yet.',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: disputes.length,
      itemBuilder: (context, index) {
        final dispute = disputes[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DisputeChatScreen(
                  dispute: dispute,
                  isOngoing: isOngoing,
                  onCloseDispute: () {
                    Navigator.pop(context);
                    _closeDispute(dispute);
                  },
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF1E355B),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFC0C0C2).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dispute['title'],
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Text('User: ${dispute['accountName']}  •  ID: ${dispute['id']}',
                          style: const TextStyle(
                              color: Color(0xFF8EBBFF),
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(dispute['section'],
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                if (isOngoing)
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                      onPressed: () => _closeDispute(dispute),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.lock_outline, color: Colors.white38, size: 28),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DisputeChatScreen extends StatefulWidget {
  final Map<String, dynamic> dispute;
  final bool isOngoing;
  final VoidCallback onCloseDispute;

  const DisputeChatScreen({
    super.key,
    required this.dispute,
    required this.isOngoing,
    required this.onCloseDispute,
  });

  @override
  State<DisputeChatScreen> createState() => _DisputeChatScreenState();
}

class _DisputeChatScreenState extends State<DisputeChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List<Map<String, dynamic>>.from(widget.dispute['messages']);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'admin',
        'text': _messageController.text.trim(),
        'time': 'Just now',
      });
      widget.dispute['messages'] = _messages;
    });
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1E3F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E355B),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.dispute['accountName'],
                style: const TextStyle(fontSize: 16, color: Colors.white)),
            Text(widget.dispute['id'],
                style: const TextStyle(fontSize: 12, color: Color(0xFFB18E44))),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (widget.isOngoing)
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF1E355B),
                    title: const Text('Close Dispute?', style: TextStyle(color: Colors.white)),
                    content: const Text('Mark this dispute as resolved?',
                        style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(color: Color(0xFF8EBBFF)))),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onCloseDispute();
                        },
                        child: const Text('Close', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              label: const Text('Resolve', style: TextStyle(color: Colors.green)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isAdmin = msg['sender'] == 'admin';
                return Align(
                  alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(15),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isAdmin ? const Color(0xFFB18E44) : const Color(0xFF1E355B),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: isAdmin ? const Radius.circular(15) : Radius.zero,
                        bottomRight: isAdmin ? Radius.zero : const Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg['text'],
                            style: TextStyle(
                                color: isAdmin ? const Color(0xFF0B1E3F) : Colors.white,
                                fontSize: 15)),
                        const SizedBox(height: 5),
                        Text(msg['time'],
                            style: TextStyle(
                                color: isAdmin
                                    ? const Color(0xFF0B1E3F).withOpacity(0.6)
                                    : Colors.white54,
                                fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.isOngoing)
            Container(
              padding: const EdgeInsets.all(15),
              color: const Color(0xFF1E355B),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF0B1E3F),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: const BoxDecoration(
                          color: Color(0xFF8EBBFF), shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF0B1E3F)),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.black26,
              child: const Text('This dispute has been closed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
            )
        ],
      ),
    );
  }
}
