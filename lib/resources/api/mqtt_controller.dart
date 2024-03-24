import 'dart:async';
import 'dart:convert';

import 'package:flutter_gtt/models/mqtt_data.dart';
import 'package:flutter_gtt/resources/utils/utils.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

class MqttController {
  final Set<String> _shortNames = {};
  late MqttServerClient _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _subscription;
  final StreamController<MqttVehicle> _payloadStreamController =
      StreamController<MqttVehicle>();
  final uuid = const Uuid();
  MqttController() {
    final clientId = uuid.v1().substring(0, 18);
    _client = MqttServerClient.withPort(
        'wss://mapi.5t.torino.it/scre', clientId, 443);
    _client.logging(on: false);
    _client.keepAlivePeriod = 60;
    final connMess = MqttConnectMessage().withWillQos(MqttQos.atMostOnce);

    _client.connectionMessage = connMess;
    _client.useWebSocket = true;
    _client.autoReconnect = true;

    _client.setProtocolV311();

    //connect(shortName);
  }
  void addSubscription(String gtfsId) {
    String shortName = Utils.getBusIdentifier(gtfsId);

    //print(shortName);
    _shortNames.add(shortName);
    _client.clientIdentifier = '${_client.clientIdentifier}$shortName';
  }

  void connect() async {
    await _client.connect();
    for (String shortName in _shortNames) {
      _client.subscribe('/$shortName/#', MqttQos.atMostOnce);
    }

    // listen to subscriptions
    _subscription =
        _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      if (pt.isEmpty) return;
      MqttVehicle data =
          MqttVehicle.fromList(json.decode(pt) as List<dynamic>, c[0].topic);
      if (!_payloadStreamController.isClosed) {
        _payloadStreamController.add(data);
      }
    });
  }

  Stream<MqttVehicle> get payloadStream => _payloadStreamController.isClosed
      ? throw 'error'
      : _payloadStreamController.stream;

  Future<void> dispose() async {
    for (String shortName in _shortNames) {
      _client.unsubscribe('/$shortName/#');
    }
    _subscription?.cancel();
    _client.disconnect();
    _payloadStreamController.close();
  }
}
