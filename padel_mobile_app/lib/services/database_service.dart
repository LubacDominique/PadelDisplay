/// Service de gestion de la base de données locale
/// 
/// Gère la persistance des matchs et statistiques avec SQLite

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/match.dart';
import '../models/player.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('padel_display.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Table des joueurs
    await db.execute('''
      CREATE TABLE players (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        photo_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Table des matchs
    await db.execute('''
      CREATE TABLE matches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        match_date TEXT NOT NULL,
        player1_id INTEGER NOT NULL,
        player2_id INTEGER NOT NULL,
        player1_sets INTEGER NOT NULL DEFAULT 0,
        player2_sets INTEGER NOT NULL DEFAULT 0,
        duration_seconds INTEGER NOT NULL DEFAULT 0,
        completed INTEGER NOT NULL DEFAULT 0,
        winner_id INTEGER,
        FOREIGN KEY (player1_id) REFERENCES players (id),
        FOREIGN KEY (player2_id) REFERENCES players (id),
        FOREIGN KEY (winner_id) REFERENCES players (id)
      )
    ''');

    // Table des sets
    await db.execute('''
      CREATE TABLE match_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        match_id INTEGER NOT NULL,
        set_number INTEGER NOT NULL,
        player1_games INTEGER NOT NULL DEFAULT 0,
        player2_games INTEGER NOT NULL DEFAULT 0,
        duration_seconds INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (match_id) REFERENCES matches (id) ON DELETE CASCADE
      )
    ''');

    // Index pour améliorer les performances
    await db.execute('CREATE INDEX idx_matches_date ON matches(match_date DESC)');
    await db.execute('CREATE INDEX idx_matches_player1 ON matches(player1_id)');
    await db.execute('CREATE INDEX idx_matches_player2 ON matches(player2_id)');
  }

  // ===== GESTION DES JOUEURS =====

  /// Crée ou récupère un joueur par son nom
  Future<Player> createOrGetPlayer(String name) async {
    final db = await database;
    
    // Chercher si le joueur existe déjà
    final existing = await db.query(
      'players',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (existing.isNotEmpty) {
      return Player.fromMap(existing.first);
    }

    // Créer le joueur
    final player = Player(name: name);
    final id = await db.insert('players', player.toMap());
    return player.copyWith(id: id);
  }

  /// Récupère tous les joueurs
  Future<List<Player>> getAllPlayers() async {
    final db = await database;
    final result = await db.query('players', orderBy: 'name ASC');
    return result.map((map) => Player.fromMap(map)).toList();
  }

  // ===== GESTION DES MATCHS =====

  /// Sauvegarde un match terminé
  Future<Match> saveMatch(Match match) async {
    final db = await database;
    final id = await db.insert('matches', match.toMap());
    return match.copyWith(id: id);
  }

  /// Met à jour un match existant
  Future<void> updateMatch(Match match) async {
    final db = await database;
    await db.update(
      'matches',
      match.toMap(),
      where: 'id = ?',
      whereArgs: [match.id],
    );
  }

  /// Récupère tous les matchs (les plus récents en premier)
  Future<List<Match>> getAllMatches() async {
    final db = await database;
    final result = await db.query(
      'matches',
      orderBy: 'match_date DESC',
    );
    return result.map((map) => Match.fromMap(map)).toList();
  }

  /// Récupère les matchs d'un joueur
  Future<List<Match>> getPlayerMatches(int playerId) async {
    final db = await database;
    final result = await db.query(
      'matches',
      where: 'player1_id = ? OR player2_id = ?',
      whereArgs: [playerId, playerId],
      orderBy: 'match_date DESC',
    );
    return result.map((map) => Match.fromMap(map)).toList();
  }

  /// Récupère un match par son ID
  Future<Match?> getMatch(int id) async {
    final db = await database;
    final result = await db.query(
      'matches',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Match.fromMap(result.first);
  }

  // ===== STATISTIQUES =====

  /// Statistiques globales d'un joueur
  Future<PlayerStats> getPlayerStats(int playerId) async {
    final db = await database;
    
    // Matchs joués
    final totalMatches = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM matches WHERE (player1_id = ? OR player2_id = ?) AND completed = 1',
        [playerId, playerId],
      ),
    ) ?? 0;

    // Victoires
    final wins = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM matches WHERE winner_id = ?',
        [playerId],
      ),
    ) ?? 0;

    // Défaites
    final losses = totalMatches - wins;

    // Durée totale de jeu
    final totalDuration = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT SUM(duration_seconds) FROM matches WHERE (player1_id = ? OR player2_id = ?) AND completed = 1',
        [playerId, playerId],
      ),
    ) ?? 0;

    // Durée moyenne
    final avgDuration = totalMatches > 0 ? totalDuration ~/ totalMatches : 0;

    // Sets gagnés
    final setsWon = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT SUM(CASE WHEN player1_id = ? THEN player1_sets ELSE player2_sets END) FROM matches WHERE (player1_id = ? OR player2_id = ?) AND completed = 1',
        [playerId, playerId, playerId],
      ),
    ) ?? 0;

    // Sets perdus
    final setsLost = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT SUM(CASE WHEN player1_id = ? THEN player2_sets ELSE player1_sets END) FROM matches WHERE (player1_id = ? OR player2_id = ?) AND completed = 1',
        [playerId, playerId, playerId],
      ),
    ) ?? 0;

    return PlayerStats(
      playerId: playerId,
      totalMatches: totalMatches,
      wins: wins,
      losses: losses,
      totalDurationSeconds: totalDuration,
      avgDurationSeconds: avgDuration,
      setsWon: setsWon,
      setsLost: setsLost,
    );
  }

  /// Supprime un match
  Future<void> deleteMatch(int id) async {
    final db = await database;
    await db.delete(
      'matches',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Ferme la base de données
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

/// Statistiques d'un joueur
class PlayerStats {
  final int playerId;
  final int totalMatches;
  final int wins;
  final int losses;
  final int totalDurationSeconds;
  final int avgDurationSeconds;
  final int setsWon;
  final int setsLost;

  PlayerStats({
    required this.playerId,
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.totalDurationSeconds,
    required this.avgDurationSeconds,
    required this.setsWon,
    required this.setsLost,
  });

  double get winRate => totalMatches > 0 ? (wins / totalMatches) * 100 : 0;

  String get avgDurationFormatted {
    final hours = avgDurationSeconds ~/ 3600;
    final minutes = (avgDurationSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
