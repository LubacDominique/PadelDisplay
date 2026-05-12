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
          // Indicateur batterie
          if (_batteryInfo != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.battery_full,
                    color: _getBatteryColor(_batteryInfo!.systemPercent),
                  ),
                  const SizedBox(width: 4),
                  Text('${_batteryInfo!.systemPercent}%'),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Joueur 1
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => bleService.addPoint(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Icon(Icons.add, size: 30),
              ),
              const SizedBox(height: 8),
              Text(widget.player1.name, style: const TextStyle(fontSize: 12)),
            ],
          ),
          
          // Contrôles centraux
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _showResetDialog(bleService),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
          
          // Joueur 2
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => bleService.addPoint(2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Icon(Icons.add, size: 30),
              ),
              const SizedBox(height: 8),
              Text(widget.player2.name, style: const TextStyle(fontSize: 12)),
            ],
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
    if (percent >= 75) return Colors.green;
    if (percent >= 50) return Colors.blue;
    if (percent >= 25) return Colors.orange;
    return Colors.red;
  }
}
