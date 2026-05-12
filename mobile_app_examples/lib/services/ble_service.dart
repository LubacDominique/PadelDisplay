/// Service de gestion de la connexion Bluetooth avec l'ESP32 PadelDisplay
/// 
/// Gère:
/// - Scan des appareils ESP32
/// - Connexion/Déconnexion
/// - Envoi de commandes
/// - Réception de notifications (scores, statut, batterie)
///
/// Exemple d'utilisation:
/// ```dart
/// final bleService = BLEService();
/// await bleService.startScan();
/// await bleService.connect(device);
/// bleService.sendCommand('P1_ADD');
/// ```

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService extends ChangeNotifier {
  // UUIDs des services et caractéristiques
  static const String _serviceScoreUUID = "0000aa00-0000-1000-8000-00805f9b34fb";
  static const String _charScoreUpdateUUID = "0000aa01-0000-1000-8000-00805f9b34fb";
  static const String _charCommandUUID = "0000aa02-0000-1000-8000-00805f9b34fb";
  static const String _charMatchStatusUUID = "0000aa03-0000-1000-8000-00805f9b34fb";
  static const String _charBatteryInfoUUID = "0000aa04-0000-1000-8000-00805f9b34fb";
  
  static const String _servicePlayerUUID = "0000bb00-0000-1000-8000-00805f9b34fb";
  static const String _charPlayerNamesUUID = "0000bb01-0000-1000-8000-00805f9b34fb";
  
  // État de connexion
  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectedDevice != null;
  
  // Caractéristiques BLE
  BluetoothCharacteristic? _scoreUpdateChar;
  BluetoothCharacteristic? _commandChar;
  BluetoothCharacteristic? _matchStatusChar;
  BluetoothCharacteristic? _batteryInfoChar;
  BluetoothCharacteristic? _playerNamesChar;
  
  // État du scan
  bool _isScanning = false;
  bool get isScanning => _isScanning;
  
  List<BluetoothDevice> _discoveredDevices = [];
  List<BluetoothDevice> get discoveredDevices => _discoveredDevices;
  
  // Streams pour les données reçues
  final _scoreStreamController = StreamController<ScoreData>.broadcast();
  Stream<ScoreData> get scoreStream => _scoreStreamController.stream;
  
  final _matchStatusStreamController = StreamController<MatchStatus>.broadcast();
  Stream<MatchStatus> get matchStatusStream => _matchStatusStreamController.stream;
  
  final _batteryStreamController = StreamController<BatteryInfo>.broadcast();
  Stream<BatteryInfo> get batteryStream => _batteryStreamController.stream;
  
  // Subscriptions pour cleanup
  final List<StreamSubscription> _subscriptions = [];
  
  BLEService() {
    _initialize();
  }
  
  /// Initialise le service BLE
  void _initialize() {
    // Écouter les changements d'état BLE
    _subscriptions.add(
      FlutterBluePlus.adapterState.listen((state) {
        debugPrint('📡 État BLE: $state');
        if (state != BluetoothAdapterState.on) {
          _disconnect();
        }
        notifyListeners();
      })
    );
  }
  
  /// Démarre le scan des appareils ESP32 PadelDisplay
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (_isScanning) return;
    
    _isScanning = true;
    _discoveredDevices.clear();
    notifyListeners();
    
    debugPrint('🔍 Démarrage du scan BLE...');
    
    try {
      // Arrêter un scan en cours si nécessaire
      if (FlutterBluePlus.isScanningNow) {
        await FlutterBluePlus.stopScan();
      }
      
      // Écouter les résultats du scan
      _subscriptions.add(
        FlutterBluePlus.scanResults.listen((results) {
          for (ScanResult result in results) {
            // Filtrer pour les appareils PadelDisplay
            if (result.device.name.contains('PadelDisplay') || 
                result.advertisementData.serviceUuids.contains(Guid(_serviceScoreUUID))) {
              
              if (!_discoveredDevices.contains(result.device)) {
                _discoveredDevices.add(result.device);
                debugPrint('📱 Trouvé: ${result.device.name} (${result.device.id})');
                notifyListeners();
              }
            }
          }
        })
      );
      
      // Démarrer le scan
      await FlutterBluePlus.startScan(timeout: timeout);
      
      // Attendre la fin du scan
      await Future.delayed(timeout);
      
    } catch (e) {
      debugPrint('❌ Erreur scan: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }
  
  /// Arrête le scan
  Future<void> stopScan() async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
    _isScanning = false;
    notifyListeners();
  }
  
  /// Connecte à un appareil ESP32
  Future<bool> connect(BluetoothDevice device) async {
    try {
      debugPrint('🔌 Connexion à ${device.name}...');
      
      // Se connecter
      await device.connect(timeout: const Duration(seconds: 15));
      _connectedDevice = device;
      
      // Découvrir les services
      debugPrint('🔍 Découverte des services...');
      List<BluetoothService> services = await device.discoverServices();
      
      // Trouver les caractéristiques
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() == _serviceScoreUUID) {
          for (BluetoothCharacteristic char in service.characteristics) {
            final uuid = char.uuid.toString().toLowerCase();
            
            if (uuid == _charScoreUpdateUUID) {
              _scoreUpdateChar = char;
              await _subscribeToScoreUpdates(char);
            } else if (uuid == _charCommandUUID) {
              _commandChar = char;
            } else if (uuid == _charMatchStatusUUID) {
              _matchStatusChar = char;
              await _subscribeToMatchStatus(char);
            } else if (uuid == _charBatteryInfoUUID) {
              _batteryInfoChar = char;
              await _subscribeToBatteryInfo(char);
            }
          }
        } else if (service.uuid.toString().toLowerCase() == _servicePlayerUUID) {
          for (BluetoothCharacteristic char in service.characteristics) {
            if (char.uuid.toString().toLowerCase() == _charPlayerNamesUUID) {
              _playerNamesChar = char;
            }
          }
        }
      }
      
      debugPrint('✅ Connecté avec succès');
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint('❌ Erreur connexion: $e');
      await _disconnect();
      return false;
    }
  }
  
  /// Déconnecte de l'appareil actuel
  Future<void> disconnect() async {
    await _disconnect();
    notifyListeners();
  }
  
  Future<void> _disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        debugPrint('⚠️  Erreur déconnexion: $e');
      }
      _connectedDevice = null;
      _scoreUpdateChar = null;
      _commandChar = null;
      _matchStatusChar = null;
      _batteryInfoChar = null;
      _playerNamesChar = null;
    }
  }
  
  /// S'abonne aux mises à jour de score
  Future<void> _subscribeToScoreUpdates(BluetoothCharacteristic char) async {
    await char.setNotifyValue(true);
    
    _subscriptions.add(
      char.value.listen((value) {
        if (value.isNotEmpty) {
          final data = utf8.decode(value);
          debugPrint('📊 Score reçu: $data');
          
          // Parser: "P1_points,P1_games,P1_sets,P2_points,P2_games,P2_sets"
          final parts = data.split(',');
          if (parts.length == 6) {
            final scoreData = ScoreData(
              player1Points: int.parse(parts[0]),
              player1Games: int.parse(parts[1]),
              player1Sets: int.parse(parts[2]),
              player2Points: int.parse(parts[3]),
              player2Games: int.parse(parts[4]),
              player2Sets: int.parse(parts[5]),
            );
            _scoreStreamController.add(scoreData);
          }
        }
      })
    );
  }
  
  /// S'abonne aux mises à jour de statut de match
  Future<void> _subscribeToMatchStatus(BluetoothCharacteristic char) async {
    await char.setNotifyValue(true);
    
    _subscriptions.add(
      char.value.listen((value) {
        if (value.isNotEmpty) {
          final data = utf8.decode(value);
          debugPrint('ℹ️  Statut reçu: $data');
          
          try {
            final json = jsonDecode(data);
            final status = MatchStatus(
              gameInProgress: json['gameInProgress'],
              isDeuce: json['isDeuce'],
              currentServer: json['currentServer'],
              matchTime: json['matchTime'],
              lastPointTime: json['lastPointTime'],
            );
            _matchStatusStreamController.add(status);
          } catch (e) {
            debugPrint('⚠️  Erreur parsing statut: $e');
          }
        }
      })
    );
  }
  
  /// S'abonne aux mises à jour de batterie
  Future<void> _subscribeToBatteryInfo(BluetoothCharacteristic char) async {
    await char.setNotifyValue(true);
    
    _subscriptions.add(
      char.value.listen((value) {
        if (value.isNotEmpty) {
          final data = utf8.decode(value);
          debugPrint('🔋 Batterie reçue: $data');
          
          // Parser: "voltage,percent,etag1,etag2"
          final parts = data.split(',');
          if (parts.length == 4) {
            final batteryInfo = BatteryInfo(
              systemVoltage: double.parse(parts[0]),
              systemPercent: int.parse(parts[1]),
              eTag1Percent: int.parse(parts[2]),
              eTag2Percent: int.parse(parts[3]),
            );
            _batteryStreamController.add(batteryInfo);
          }
        }
      })
    );
  }
  
  /// Envoie une commande à l'ESP32
  Future<bool> sendCommand(String command) async {
    if (_commandChar == null) {
      debugPrint('⚠️  Pas de caractéristique de commande');
      return false;
    }
    
    try {
      await _commandChar!.write(utf8.encode(command));
      debugPrint('📤 Commande envoyée: $command');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur envoi commande: $e');
      return false;
    }
  }
  
  /// Envoie les noms des joueurs
  Future<bool> setPlayerNames(String player1, String player2) async {
    if (_playerNamesChar == null) {
      debugPrint('⚠️  Pas de caractéristique de noms');
      return false;
    }
    
    try {
      final data = '$player1,$player2';
      await _playerNamesChar!.write(utf8.encode(data));
      debugPrint('📤 Noms envoyés: $data');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur envoi noms: $e');
      return false;
    }
  }
  
  /// Ajoute un point au joueur
  Future<bool> addPoint(int playerNumber) async {
    return sendCommand('P${playerNumber}_ADD');
  }
  
  /// Retire un point au joueur
  Future<bool> removePoint(int playerNumber) async {
    return sendCommand('P${playerNumber}_REMOVE');
  }
  
  /// Réinitialise le match
  Future<bool> resetMatch() async {
    return sendCommand('RESET');
  }
  
  /// Réinitialise le jeu en cours
  Future<bool> resetGame() async {
    return sendCommand('RESET_GAME');
  }
  
  /// Demande l'état complet
  Future<bool> getStatus() async {
    return sendCommand('GET_STATUS');
  }
  
  @override
  void dispose() {
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    _scoreStreamController.close();
    _matchStatusStreamController.close();
    _batteryStreamController.close();
    _disconnect();
    super.dispose();
  }
}

/// Données de score
class ScoreData {
  final int player1Points;
  final int player1Games;
  final int player1Sets;
  final int player2Points;
  final int player2Games;
  final int player2Sets;
  
  ScoreData({
    required this.player1Points,
    required this.player1Games,
    required this.player1Sets,
    required this.player2Points,
    required this.player2Games,
    required this.player2Sets,
  });
  
  @override
  String toString() {
    return 'Score: [$player1Sets-$player2Sets] [$player1Games-$player2Games] [$player1Points-$player2Points]';
  }
}

/// Statut du match
class MatchStatus {
  final bool gameInProgress;
  final bool isDeuce;
  final int currentServer;
  final int matchTime;
  final int lastPointTime;
  
  MatchStatus({
    required this.gameInProgress,
    required this.isDeuce,
    required this.currentServer,
    required this.matchTime,
    required this.lastPointTime,
  });
}

/// Informations batterie
class BatteryInfo {
  final double systemVoltage;
  final int systemPercent;
  final int eTag1Percent;
  final int eTag2Percent;
  
  BatteryInfo({
    required this.systemVoltage,
    required this.systemPercent,
    required this.eTag1Percent,
    required this.eTag2Percent,
  });
  
  @override
  String toString() {
    return 'Batterie: Système ${systemVoltage}V ($systemPercent%), eTag1 $eTag1Percent%, eTag2 $eTag2Percent%';
  }
}
