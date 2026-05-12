/// Écran d'historique des matchs
/// 
/// Affiche la liste des matchs passés et les statistiques

import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Match> _matches = [];
  Map<int, Player> _players = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Charger les matchs
      final matches = await _db.getAllMatches();
      
      // Charger les joueurs
      final players = await _db.getAllPlayers();
      final playersMap = {for (var p in players) p.id!: p};

      setState(() {
        _matches = matches;
        _players = playersMap;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement historique: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des matchs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _showStatistics,
            tooltip: 'Statistiques',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matches.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _matches.length,
                    itemBuilder: (context, index) {
                      final match = _matches[index];
                      return _buildMatchCard(match);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_tennis,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun match enregistré',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les matchs terminés apparaîtront ici',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(Match match) {
    final player1 = _players[match.player1Id];
    final player2 = _players[match.player2Id];

    if (player1 == null || player2 == null) {
      return const SizedBox.shrink();
    }

    final isPlayer1Winner = match.winnerId == match.player1Id;
    final date = match.matchDate;
    final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: InkWell(
        onTap: () => _showMatchDetails(match),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date et durée
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '$dateStr à $timeStr',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        match.durationFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Score
              Row(
                children: [
                  Expanded(
                    child: _buildPlayerScore(
                      player1.name,
                      match.player1Sets,
                      isPlayer1Winner,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'vs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildPlayerScore(
                      player2.name,
                      match.player2Sets,
                      !isPlayer1Winner,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerScore(String name, int sets, bool isWinner) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isWinner ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWinner ? Colors.green : Colors.grey[300]!,
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                sets.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? Colors.green[700] : Colors.grey[700],
                ),
              ),
              if (isWinner) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.emoji_events,
                  size: 16,
                  color: Colors.amber[700],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showMatchDetails(Match match) {
    final player1 = _players[match.player1Id];
    final player2 = _players[match.player2Id];

    if (player1 == null || player2 == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails du match'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Date', '${match.matchDate.day}/${match.matchDate.month}/${match.matchDate.year}'),
            _buildDetailRow('Heure', '${match.matchDate.hour}:${match.matchDate.minute.toString().padLeft(2, '0')}'),
            _buildDetailRow('Durée', match.durationFormatted),
            const Divider(),
            _buildDetailRow('Joueur 1', player1.name),
            _buildDetailRow('Sets', match.player1Sets.toString()),
            const Divider(),
            _buildDetailRow('Joueur 2', player2.name),
            _buildDetailRow('Sets', match.player2Sets.toString()),
            const Divider(),
            _buildDetailRow(
              'Vainqueur',
              match.winnerId == match.player1Id ? player1.name : player2.name,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete(match);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _confirmDelete(Match match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le match'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce match ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await _db.deleteMatch(match.id!);
              if (mounted) {
                Navigator.pop(context);
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Match supprimé')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showStatistics() async {
    if (_players.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun joueur trouvé')),
      );
      return;
    }

    // Calculer les stats pour chaque joueur
    final statsMap = <int, PlayerStats>{};
    for (var player in _players.values) {
      final stats = await _db.getPlayerStats(player.id!);
      statsMap[player.id!] = stats;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques des joueurs'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _players.length,
            itemBuilder: (context, index) {
              final player = _players.values.elementAt(index);
              final stats = statsMap[player.id!];
              if (stats == null || stats.totalMatches == 0) {
                return const SizedBox.shrink();
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow('Matchs joués', stats.totalMatches.toString()),
                      _buildStatRow('Victoires', '${stats.wins} (${stats.winRate.toStringAsFixed(1)}%)'),
                      _buildStatRow('Défaites', stats.losses.toString()),
                      _buildStatRow('Sets gagnés', stats.setsWon.toString()),
                      _buildStatRow('Sets perdus', stats.setsLost.toString()),
                      _buildStatRow('Durée moyenne', stats.avgDurationFormatted),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
