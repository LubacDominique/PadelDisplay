/// Écran de contrôle du match en direct
/// 
/// Affiche le score en temps réel et permet de contrôler le match
/// via la connexion Bluetooth avec l'ESP32

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ble_service.dart';
import '../models/player.dart';

class MatchControlScreen extends StatefulWidget {
  final Player player1;
  final Player player2;
  
  const MatchControlScreen({
    Key? key,
    required this.player1,
    required this.player2,
  }) : super(key: key);
  
  @override
  State<MatchControlScreen> createState() => _MatchControlScreenState();
}

class _MatchControlScreenState extends State<MatchControlScreen> {
  ScoreData? _currentScore;
  MatchStatus? _matchStatus;
  BatteryInfo? _batteryInfo;
  
  final List<String> _pointHistory = [];
  DateTime? _matchStartTime;
  
  @override
  void initState() {
    super.initState();
    _initializeMatch();
  }
  
  void _initializeMatch() async {
    final bleService = context.read<BLEService>();
    
    // Envoyer les noms des joueurs
    await bleService.setPlayerNames(widget.player1.name, widget.player2.name);
    
    // Réinitialiser le match
    await bleService.resetMatch();
    
    // Demander le statut initial
    await bleService.getStatus();
    
    _matchStartTime = DateTime.now();
    
    // Écouter les mises à jour de score
    bleService.scoreStream.listen((score) {
      setState(() {
        _currentScore = score;
      });
    });
    
    // Écouter les mises à jour de statut
    bleService.matchStatusStream.listen((status) {
      setState(() {
        _matchStatus = status;
      });
    });
    
    // Écouter les mises à jour de batterie
    bleService.batteryStream.listen((battery) {
      setState(() {
        _batteryInfo = battery;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final bleService = context.watch<BLEService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match en cours'),
        actions: [
          // Indicateur batterie système
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Icon(
                  _batteryInfo != null 
                    ? _getBatteryIcon(_batteryInfo!.systemPercent)
                    : Icons.battery_unknown,
                  color: _batteryInfo != null 
                    ? _getBatteryColor(_batteryInfo!.systemPercent)
                    : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _batteryInfo != null 
                    ? '${_batteryInfo!.systemVoltage.toStringAsFixed(1)}V'
                    : '--V',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          
          // Indicateur connexion BLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              bleService.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              color: bleService.isConnected ? Colors.blue : Colors.red,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone de score principal
          Expanded(
            child: _buildScoreDisplay(),
          ),
          
          // Contrôles
          _buildControls(bleService),
          
          // Historique des points
          _buildPointHistory(),
        ],
      ),
    );
  }
  
  Widget _buildScoreDisplay() {
    if (_currentScore == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Noms des joueurs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Text(
                  widget.player1.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  widget.player2.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Sets
          _buildScoreRow(
            'Sets',
            _currentScore!.player1Sets,
            _currentScore!.player2Sets,
          ),
          
          const SizedBox(height: 10),
          
          // Games
          _buildScoreRow(
            'Games',
            _currentScore!.player1Games,
            _currentScore!.player2Games,
          ),
          
          const SizedBox(height: 10),
          
          // Points
          _buildScoreRow(
            'Points',
            _currentScore!.player1Points,
            _currentScore!.player2Points,
            isPoints: true,
          ),
          
          const SizedBox(height: 30),
          
          // Informations match
          if (_matchStatus != null) ...[
            if (_matchStatus!.isDeuce)
              const Chip(
                label: Text('DEUCE'),
                backgroundColor: Colors.orange,
              ),
            
            const SizedBox(height: 10),
            
            Text(
              'Service: ${_matchStatus!.currentServer == 1 ? widget.player1.name : widget.player2.name}',
              style: const TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 10),
            
            Text(
              'Durée: ${_formatDuration(_matchStatus!.matchTime)}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildScoreRow(String label, int score1, int score2, {bool isPoints = false}) {
    return Row(
      children: [
        Expanded(
          child: _buildScoreCard(
            isPoints ? _formatPoints(score1) : score1.toString(),
            Colors.blue,
          ),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: _buildScoreCard(
            isPoints ? _formatPoints(score2) : score2.toString(),
            Colors.red,
          ),
        ),
      ],
    );
  }
  
  Widget _buildScoreCard(String score, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        score,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
  
  Widget _buildControls(BLEService bleService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Message d'information
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mode visualisation uniquement\nUtilisez les eTags pour contrôler le score',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Informations batterie détaillées
          if (_batteryInfo != null)
            _buildBatteryInfo(),
          
          const SizedBox(height: 12),
          
          // Bouton rafraîchir uniquement
          ElevatedButton.icon(
            onPressed: () => bleService.getStatus(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Actualiser les données'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPointHistory() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historique des points',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _pointHistory.length,
              itemBuilder: (context, index) {
                return Text(_pointHistory[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _showResetDialog(BLEService bleService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser'),
        content: const Text('Que souhaitez-vous réinitialiser ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              bleService.resetGame();
              Navigator.pop(context);
            },
            child: const Text('Jeu en cours'),
          ),
          TextButton(
            onPressed: () {
              bleService.resetMatch();
              Navigator.pop(context);
            },
            child: const Text('Match complet'),
          ),
        ],
      ),
    );
  }
  
  String _formatPoints(int points) {
    switch (points) {
      case 0: return '0';
      case 1: return '15';
      case 2: return '30';
      case 3: return '40';
      case 4: return 'AD';
      default: return points.toString();
    }
  }
  
  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  Color _getBatteryColor(int percent) {
    if (percent < 0) return Colors.grey; // Déconnecté
    if (percent >= 75) return Colors.green;
    if (percent >= 50) return Colors.blue;
    if (percent >= 25) return Colors.orange;
    return Colors.red;
  }
  
  IconData _getBatteryIcon(int percent) {
    if (percent < 0) return Icons.battery_unknown; // Déconnecté
    if (percent >= 90) return Icons.battery_full;
    if (percent >= 60) return Icons.battery_5_bar;
    if (percent >= 40) return Icons.battery_3_bar;
    if (percent >= 20) return Icons.battery_2_bar;
    if (percent >= 10) return Icons.battery_1_bar;
    return Icons.battery_alert;
  }
  
  Widget _buildBatteryInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.battery_charging_full, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'État des batteries',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Batterie afficheur
          _buildBatteryRow(
            'Afficheur',
            _batteryInfo!.systemVoltage,
            _batteryInfo!.systemPercent,
            Icons.monitor,
          ),
          
          const SizedBox(height: 8),
          
          // Batterie eTag 1
          _buildBatteryRow(
            'eTag 1',
            null,
            _batteryInfo!.eTag1Percent,
            Icons.circle,
          ),
          
          const SizedBox(height: 8),
          
          // Batterie eTag 2
          _buildBatteryRow(
            'eTag 2',
            null,
            _batteryInfo!.eTag2Percent,
            Icons.circle,
          ),
        ],
      ),
    );
  }
  
  Widget _buildBatteryRow(String label, double? voltage, int percent, IconData deviceIcon) {
    final isConnected = percent >= 0;
    final displayPercent = isConnected ? percent : 0;
    
    return Row(
      children: [
        Icon(
          deviceIcon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        
        // Icône batterie
        Icon(
          _getBatteryIcon(percent),
          color: _getBatteryColor(percent),
          size: 18,
        ),
        const SizedBox(width: 4),
        
        // Barre de progression
        Expanded(
          child: LinearProgressIndicator(
            value: isConnected ? displayPercent / 100 : 0,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getBatteryColor(percent),
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(width: 8),
        
        // Pourcentage ou voltage
        SizedBox(
          width: 65,
          child: Text(
            isConnected
                ? (voltage != null
                    ? '${voltage.toStringAsFixed(1)}V'
                    : '$displayPercent%')
                : 'N/C',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isConnected ? Colors.grey[800] : Colors.grey[400],
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
