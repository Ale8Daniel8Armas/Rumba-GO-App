import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controlador/MessageController.dart';
import 'map_view.dart';
import 'reviews_page.dart';
import 'profile_view.dart';
import 'mini_formulario.dart';
import 'nuevo_local_view.dart';
import 'review_form_view.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({super.key});

  @override
  State<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  final MessageController _messageController = MessageController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
        backgroundColor: Colors.purple[900],
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: _CustomBottomNavBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar contactos',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Lista de contactos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messageController.getContacts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No hay contactos disponibles'));
                }

                var contacts = snapshot.data!.docs.where((doc) {
                  return doc.id != currentUserId &&
                      doc['name']
                          .toString()
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    var contact = contacts[index];
                    return _buildContactItem(contact);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(QueryDocumentSnapshot contact) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.purple[900],
        child: Text(
          contact['name'].toString().substring(0, 1),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        contact['name'],
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        // Navegar al chat con este contacto
        _navigateToChat(contact.id, contact['name']);
      },
    );
  }

  void _navigateToChat(String contactId, String contactName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          receiverId: contactId,
          receiverName: contactName,
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageController _messageController = MessageController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageControllerInput = TextEditingController();

  @override
  void dispose() {
    _messageControllerInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;
    final chatId =
        _messageController.generateChatId(currentUserId!, widget.receiverId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: Colors.purple[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messageController.firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Inicia la conversación'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data!.docs[index];
                    bool isMe = message['senderId'] == currentUserId;

                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(chatId),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(QueryDocumentSnapshot message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.purple[900] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message['message'],
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(String chatId) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageControllerInput,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.purple),
            onPressed: () async {
              if (_messageControllerInput.text.trim().isNotEmpty) {
                await _messageController.sendMessage(
                  receiverId: widget.receiverId,
                  message: _messageControllerInput.text,
                );
                _messageControllerInput.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.purple[900],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined,
                  color: Color(0xFFB1FBFF), size: 50),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReviewView()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.photo, color: Color(0xFFB1FBFF), size: 50),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapView()),
                );
              },
            ),
            GestureDetector(
              onTap: () {
                MiniFormulario.mostrar(
                  context: context,
                  onResenaPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReviewFormView()),
                    );
                  },
                  onLocalPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NuevoLocalView()),
                    );
                  },
                );
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFD824A6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline,
                  color: Color(0xFFB1FBFF), size: 50),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactsView()),
                );
              },
            ),
            IconButton(
              padding: const EdgeInsets.only(top: 4),
              icon: const Icon(
                Icons.person,
                color: Color(0xFFB1FBFF),
                size: 55,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PerfilView()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
