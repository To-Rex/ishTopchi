import 'package:socket_io_client/socket_io_client.dart' as IO;


typedef Json = Map<String, dynamic>;

class SocketService {
  static final SocketService _i = SocketService._internal();
  factory SocketService() => _i;
  SocketService._internal();

  IO.Socket? _socket;

  bool get isConnected => _socket?.connected == true;

  // Listeners
  final _onNewMessage = <void Function(Json)>[];
  final _onMessageStatus = <void Function(Json)>[];
  final _onUserOnline = <void Function(Json)>[];
  final _onUserOffline = <void Function(Json)>[];
  final _onUserPresence = <void Function(Json)>[];
  final _onError = <void Function(String)>[];

  void connect({required String token}) {
    if (isConnected) return;

    _socket = IO.io(
      'wss://ishtopchi.uz',
      IO.OptionBuilder()
          .setPath('/api/socket.io')            // <-- /socket.io
          .setTransports(['websocket'])       // mobil uchun barqaror
          .enableReconnection()
          .setReconnectionAttempts(9999)
          .setReconnectionDelay(1000)
          .setAuth({'token': token})          // NestJS: client.handshake.auth.token
          .build(),
    );

    // Optional: socket.io internal options
    _socket!.io.options?['timeout'] = 20000;

    // Lifecycle
    _socket!.on('connect', (_) => _log('suuuuuuu: ${_socket!.id}'));
    _socket!.on('disconnect', (reason) => _log('disconnected: $reason'));
    _socket!.on('connect_error', (e) => _notifyError('connect_error: $e'));
    _socket!.on('error', (e) => _notifyError('error: $e'));

    // === Server eventlari (NestJS Gateway) ===
    _socket!.on('newMessage', (data) {
      print('Serverdan xabar: $data');
      final json = _asJson(data);
      for (final cb in _onNewMessage) {
        cb(json);
      }
    });

    _socket!.on('messageStatus', (data) {
      print('Serverdan status: $data');
      final json = _asJson(data);
      for (final cb in _onMessageStatus) cb(json);
    });

    _socket!.on('userOnline', (data) {
      print('Serverdan online: $data');
      final json = _asJson(data);
      for (final cb in _onUserOnline) cb(json);
    });

    _socket!.on('userOffline', (data) {
      print('Serverdan offline: $data');
      final json = _asJson(data);
      for (final cb in _onUserOffline) cb(json);
    });

    _socket!.on('userPresence', (data) {
      print('Serverdan presence: $data');
      final json = _asJson(data);
      for (final cb in _onUserPresence) cb(json);
    });
  }

  // Rooms
  void joinChat(int chatRoomId) {
    if (!isConnected) return _notifyError('Socket ulanmagan');
    _socket!.emit('joinChat', chatRoomId);
    _log('emit joinChat: $chatRoomId');
  }

  void leaveChat(int chatRoomId) {
    if (!isConnected) return _notifyError('Socket ulanmagan');
    _socket!.emit('leaveChat', chatRoomId);
    _log('emit leaveChat: $chatRoomId');
  }

  // Messaging
  void sendMessage({required int chatRoomId, required String content}) {
    if (!isConnected) return _notifyError('Socket ulanmagan');
    final payload = {'chatRoomId': chatRoomId, 'content': content};
    _socket!.emit('sendMessage', payload);
    _log('emit sendMessage: $payload');
  }

  // Presence (Serverdagi event nomi hozir "udatePresence")
  void updatePresence(bool isOnline) {
    if (!isConnected) return _notifyError('Socket ulanmagan');
    _socket!.emit('udatePresence', {'isOnline': isOnline});
    _log('emit udatePresence: {isOnline: $isOnline}');
  }

  // Listeners qo‘shish
  void onNewMessage(void Function(Json) cb) => _onNewMessage.add(cb);
  void onMessageStatus(void Function(Json) cb) => _onMessageStatus.add(cb);
  void onUserOnline(void Function(Json) cb) => _onUserOnline.add(cb);
  void onUserOffline(void Function(Json) cb) => _onUserOffline.add(cb);
  void onUserPresence(void Function(Json) cb) => _onUserPresence.add(cb);
  void onError(void Function(String) cb) => _onError.add(cb);

  void disconnect() {
    try {
      _socket?.dispose();
      _socket?.disconnect();
    } finally {
      _socket = null;
      _log('socket closed');
    }
  }

  // Helpers
  Json _asJson(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'data': data};
  }

  void _notifyError(String msg) {
    for (final cb in _onError) cb(msg);
  }

  void _log(String msg) {
    // ignore: avoid_print
    print('[SocketService] $msg');
  }
}