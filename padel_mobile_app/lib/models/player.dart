/// Modèle de données pour un joueur de Padel
/// 
/// Représente un joueur avec ses informations et statistiques

class Player {
  final int? id;
  final String name;
  final String? photoPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Player({
    this.id,
    required this.name,
    this.photoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
  
  /// Crée un joueur depuis une map (base de données)
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      photoPath: map['photo_path'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
  
  /// Convertit le joueur en map pour la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photo_path': photoPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  /// Copie avec modifications
  Player copyWith({
    int? id,
    String? name,
    String? photoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  String toString() => 'Player(id: $id, name: $name)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// Statistiques d'un joueur
class PlayerStatistics {
  final int playerId;
  final int totalMatches;
  final int totalWins;
  final int totalLosses;
  final int totalSetsWon;
  final int totalSetsLost;
  final int totalGamesWon;
  final int totalGamesLost;
  final int totalPointsWon;
  final int totalPointsLost;
  final int averageMatchDuration; // en secondes
  final DateTime lastUpdated;
  
  PlayerStatistics({
    required this.playerId,
    this.totalMatches = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.totalSetsWon = 0,
    this.totalSetsLost = 0,
    this.totalGamesWon = 0,
    this.totalGamesLost = 0,
    this.totalPointsWon = 0,
    this.totalPointsLost = 0,
    this.averageMatchDuration = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();
  
  /// Taux de victoire (0-100)
  double get winRate {
    if (totalMatches == 0) return 0.0;
    return (totalWins / totalMatches) * 100;
  }
  
  /// Taux de victoire des sets
  double get setWinRate {
    final total = totalSetsWon + totalSetsLost;
    if (total == 0) return 0.0;
    return (totalSetsWon / total) * 100;
  }
  
  /// Taux de victoire des games
  double get gameWinRate {
    final total = totalGamesWon + totalGamesLost;
    if (total == 0) return 0.0;
    return (totalGamesWon / total) * 100;
  }
  
  /// Durée moyenne formatée (HH:MM:SS)
  String get averageMatchDurationFormatted {
    final hours = averageMatchDuration ~/ 3600;
    final minutes = (averageMatchDuration % 3600) ~/ 60;
    final seconds = averageMatchDuration % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }
  
  factory PlayerStatistics.fromMap(Map<String, dynamic> map) {
    return PlayerStatistics(
      playerId: map['player_id'],
      totalMatches: map['total_matches'] ?? 0,
      totalWins: map['total_wins'] ?? 0,
      totalLosses: map['total_losses'] ?? 0,
      totalSetsWon: map['total_sets_won'] ?? 0,
      totalSetsLost: map['total_sets_lost'] ?? 0,
      totalGamesWon: map['total_games_won'] ?? 0,
      totalGamesLost: map['total_games_lost'] ?? 0,
      totalPointsWon: map['total_points_won'] ?? 0,
      totalPointsLost: map['total_points_lost'] ?? 0,
      averageMatchDuration: map['average_match_duration'] ?? 0,
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'player_id': playerId,
      'total_matches': totalMatches,
      'total_wins': totalWins,
      'total_losses': totalLosses,
      'total_sets_won': totalSetsWon,
      'total_sets_lost': totalSetsLost,
      'total_games_won': totalGamesWon,
      'total_games_lost': totalGamesLost,
      'total_points_won': totalPointsWon,
      'total_points_lost': totalPointsLost,
      'average_match_duration': averageMatchDuration,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
