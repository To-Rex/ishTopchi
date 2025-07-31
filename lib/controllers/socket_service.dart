import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? channel;
  final List<Function(Map<String, dynamic>)> messageHandlers = [];
  final List<Function(String)> messageErrorHandlers = [];
  final List<Function(Map<String, dynamic>)> messageStatusHandlers = [];

  // Singleton pattern
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  void connect(String token) {
    if (channel != null) {
      print('WebSocket allaqachon ulangan');
      return;
    }

    try {
      channel = WebSocketChannel.connect(
        Uri.parse('wss://ishtopchi.uz/api/socket.io/?EIO=4&transport=websocket&token=$token'),
      );

      channel!.stream.listen((message) {
          print('Serverdan xabar: $message');
          // JSON xabarni parse qilish
          sendMessage(311,message);
          try {
            final data = jsonDecode(message);
            if (data['event'] == 'newMessage') {
              for (var handler in messageHandlers) {
                handler(data['data']);
              }
            } else if (data['event'] == 'messageError') {
              for (var handler in messageErrorHandlers) {
                handler(data['message']);
              }
            } else if (data['event'] == 'messageStatus') {
              for (var handler in messageStatusHandlers) {
                handler(data['data']);
              }
            }
          } catch (e) {
            print('Xabar parsing xatosi: $e');
            for (var handler in messageErrorHandlers) {
              handler('Xabar parsing xatosi: $e');
            }
          }
        },
        onError: (error) {
          print('Xato: $error');
          for (var handler in messageErrorHandlers) {
            handler(error.toString());
          }
        },
        onDone: () {
          print('Ulanish uzildi');
          channel = null;
        },
      );
    } catch (e) {
      print('Ulanish xatosi: $e');
      for (var handler in messageErrorHandlers) {
        handler(e.toString());
      }
    }
  }

  void joinChat(int chatId) {
    if (channel != null) {
      final message = jsonEncode({'event': 'joinChat', 'data': chatId});
      channel!.sink.add(message);
      print('Yuborilgan: $message');
    } else {
      print('WebSocket ulanmagan');
      for (var handler in messageErrorHandlers) {
        handler('WebSocket ulanmagan');
      }
    }
  }

  void sendMessage(int chatId, String content) {
    if (channel != null) {
      final message = jsonEncode({
        'event': 'sendMessage',
        'data': {'chatRoomId': chatId, 'content': content}
      });
      channel!.sink.add(message);
      print('Yuborilgan xabar: $message');
    } else {
      print('WebSocket ulanmagan');
      for (var handler in messageErrorHandlers) {
        handler('WebSocket ulanmagan');
      }
    }
  }

  void markAsRead(int chatId, List<int> messageIds) {
    if (channel != null) {
      final message = jsonEncode({
        'event': 'markAsRead',
        'data': {'chatRoomId': chatId, 'messageIds': messageIds}
      });
      channel!.sink.add(message);
      print('Yuborilgan: $message');
    }
  }

  void onMessage(void Function(Map<String, dynamic>) handler) {
    messageHandlers.add(handler);
  }

  void onMessageError(void Function(String) handler) {
    messageErrorHandlers.add(handler);
  }

  void onMessageStatus(void Function(Map<String, dynamic>) handler) {
    messageStatusHandlers.add(handler);
  }

  void disconnect() {
    if (channel != null) {
      channel!.sink.close();
      channel = null;
      print('WebSocket o\'chirildi');
    }
  }
}




//import 'package:socket_io_client/socket_io_client.dart' as IO;
//
// class SocketService {
//   static final SocketService _instance = SocketService._internal();
//   factory SocketService() => _instance;
//   SocketService._internal();
//
//   IO.Socket? socket;
//
//   void connect(String token) {
//     if (socket != null && socket!.connected) {
//       print('✅ Allaqachon ulanilgan');
//       return;
//     }
//
//     socket = IO.io(
//       'wss://ishtopchi.uz',
//       IO.OptionBuilder()
//           .setPath('/api/socket.io')
//           .setExtraHeaders({'x-auth-token': token})
//           .setExtraHeaders({'Authorization': 'Bearer $token'})
//           .setTransports(['websocket'])
//           .enableForceNew()
//           .enableReconnection()
//           .setReconnectionAttempts(5)
//           .setReconnectionDelay(1000)
//           .build()
//     );
//
//     socket!.onConnectError((data) {
//       print('❌ Ulanishda xatolik: $data');
//       print('Xato tafsilotlari: ${data.toString()}');
//     });
//
//     socket!.onDisconnect((data) {
//       print('🛑 Ulanish uzildi: $data');
//     });
//
//     socket!.onConnect((_) {
//       print('✅ WebSocket ulandi');
//     });
//
//     socket!.on('newMessage', (data) {
//       print('📩 Yangi xabar: $data');
//     });
//
//     socket!.on('chatRoomsUpdate', (data) {
//       print('📥 ChatRooms yangilandi: $data');
//     });
//
//     socket!.on('messageError', (error) {
//       print('❌ Xabar xatosi: $error');
//     });
//
//     socket!.connect();
//   }
//

//   void disconnect() {
//     socket?.disconnect();
//     print('🔌 Ulanish o‘chirildi');
//   }
//
//   void joinChat(int chatId) {
//     socket?.emit('joinChat', chatId);
//   }
//
//   void leaveChat(int chatId) {
//     socket?.emit('leaveChat', chatId);
//   }
//
//   void sendMessage(int chatId, String content) {
//     socket?.emit('sendMessage', {'chatRoomId': chatId, 'content': content});
//   }
//
//   void getChatRooms({int page = 1, int limit = 10}) {socket?.emit('getChatRooms', {'page': page, 'limit': limit});}
// }