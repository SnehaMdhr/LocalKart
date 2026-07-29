import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/core/services/storage/token_service.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final tokenService = ref.read(tokenServiceProvider);
  return SocketService(tokenService: tokenService);
});

class SocketService {
  final TokenService _tokenService;
  socket_io.Socket? _socket;
  bool _isConnected = false;

  // Callbacks for notification events
  void Function(Map<String, dynamic>)? onNewNotification;
  void Function(int)? onUnreadCountUpdate;

  // Callbacks for real-time order events
  void Function(Map<String, dynamic>)? onNewOrder;
  void Function(Map<String, dynamic>)? onOrderAccepted;
  void Function(Map<String, dynamic>)? onOrderRejected;
  void Function(Map<String, dynamic>)? onOrderCancelled;
  void Function(Map<String, dynamic>)? onOrderUpdated;

  SocketService({required TokenService tokenService})
      : _tokenService = tokenService;

  bool get isConnected => _isConnected;

  /// Connect to the Socket.IO server using the stored JWT token.
  /// Called automatically after login.
  void connect() {
    if (_socket != null && _socket!.connected) return;

    final token = _tokenService.getToken();
    if (token == null || token.trim().isEmpty) return;

    try {
      _socket = socket_io.io(
        ApiEndpoints.socketUrl,
        socket_io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableForceNew()
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );

      _socket!.on('connect', (_) {
        _isConnected = true;
        debugPrint('[Socket] Connected successfully');
      });

      _socket!.on('new_notification', (data) {
        debugPrint('[Socket] New notification received');
        if (onNewNotification != null && data is Map<String, dynamic>) {
          onNewNotification!(data);
        }
      });

      _socket!.on('unread_count', (data) {
        if (onUnreadCountUpdate != null && data is int) {
          onUnreadCountUpdate!(data);
        }
      });

      // Real-time order events
      _socket!.on('new_order', (data) {
        debugPrint('[Socket] New order received via socket');
        if (onNewOrder != null && data is Map<String, dynamic>) {
          onNewOrder!(data);
        }
      });

      _socket!.on('order_accepted', (data) {
        debugPrint('[Socket] Order accepted event received');
        if (onOrderAccepted != null && data is Map<String, dynamic>) {
          onOrderAccepted!(data);
        }
      });

      _socket!.on('order_rejected', (data) {
        debugPrint('[Socket] Order rejected event received');
        if (onOrderRejected != null && data is Map<String, dynamic>) {
          onOrderRejected!(data);
        }
      });

      _socket!.on('order_cancelled', (data) {
        debugPrint('[Socket] Order cancelled event received');
        if (onOrderCancelled != null && data is Map<String, dynamic>) {
          onOrderCancelled!(data);
        }
      });

      _socket!.on('order_updated', (data) {
        debugPrint('[Socket] Order updated event received');
        if (onOrderUpdated != null && data is Map<String, dynamic>) {
          onOrderUpdated!(data);
        }
      });

      _socket!.on('disconnect', (reason) {
        _isConnected = false;
        debugPrint('[Socket] Disconnected: $reason');
      });

      _socket!.on('connect_error', (error) {
        debugPrint('[Socket] Connection error: $error');
        _isConnected = false;
      });

      _socket!.on('error', (error) {
        debugPrint('[Socket] Error: $error');
      });

      _socket!.connect();
    } catch (e) {
      debugPrint('[Socket] Failed to create socket: $e');
    }
  }

  /// Disconnect from the Socket.IO server.
  /// Called automatically on logout.
  void disconnect() {
    if (_socket != null) {
      _socket!.off('new_notification');
      _socket!.off('unread_count');
      _socket!.off('new_order');
      _socket!.off('order_accepted');
      _socket!.off('order_rejected');
      _socket!.off('order_cancelled');
      _socket!.off('order_updated');
      _socket!.off('connect');
      _socket!.off('disconnect');
      _socket!.off('connect_error');
      _socket!.off('error');
      _socket!.disconnect();
      _socket!.close();
      _socket = null;
    }
    _isConnected = false;
    debugPrint('[Socket] Disconnected cleanly');
  }

  /// Reconnect with a new token (e.g., after token refresh)
  void reconnect() {
    disconnect();
    connect();
  }

  /// Clean up all resources
  void dispose() {
    disconnect();
    onNewNotification = null;
    onUnreadCountUpdate = null;
    onNewOrder = null;
    onOrderAccepted = null;
    onOrderRejected = null;
    onOrderCancelled = null;
    onOrderUpdated = null;
  }
}
