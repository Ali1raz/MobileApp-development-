import 'package:flashcards/models/flashcard_provider.dart';
import 'package:sqflite/sqflite.dart';
import "package:path/path.dart";
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "flashcards.db";
  static const _databaseVersion = 1;
  
  static const decksTable = 'decks';
  static const cardsTable = 'cards';
  
  static final DatabaseHelper instance = DatabaseHelper._init();
  Database? _database;
  
  DatabaseHelper._init();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      create table $decksTable (
        id text primary key,
        name text not null,
        correctCount integer not null default 0
      )
    ''');

    await db.execute('''
      create table $cardsTable (
        id text primary key,
        deckId text not null,
        question text not null,
        answer text not null,
        isAnswered integer not null default 0,
        isCorrect integer not null default 0,
        foreign key (deckId) references $decksTable (id)
      )
    ''');
  }

  Future<int> insertDeck(Deck deck) async {
    final db = await instance.database;
    return await db.insert(decksTable, deck.toMap());
  }

  Future<List<Deck>> getAllDecks() async {
    try {
      final db = await instance.database;
      final List<Map<String, dynamic>> maps = await db.query(decksTable);
      return List.generate(maps.length, (i) => Deck.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  Future<int> insertCard(Flashcard card, String deckId) async {
    final db = await instance.database;
    return await db.insert(cardsTable,{
      ...card.toMap(),
      'deckId': deckId,
    });
  }

  Future<List<Flashcard>> getCardsForDeck(String deckId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
        cardsTable,
        where: 'deckId = ?',
        whereArgs: [deckId]
    );
    return List.generate(maps.length, (i) => Flashcard.fromMap(maps[i]));
  }

  Future<int> updateCard(Flashcard card) async {
    final db = await instance.database;
    return await db.update(
      cardsTable,
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteCard(String cardId) async {
    final db = await instance.database;
    return await db.delete(
      cardsTable,
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  Future<int> updateCardQuestionAnswer (Flashcard card) async {
    final db = await instance.database;
    return await db.update(
      cardsTable,
      {
        'question': card.question,
        'answer': card.answer,
      },
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> updateDeck(Deck deck) async {
    final db = await instance.database;
    return await db.update(
      decksTable,
      deck.toMap(),
      where: 'id = ?',
      whereArgs: [deck.id],
    );
  }

  Future<int> deleteDeck(String deckId) async {
    final db = await instance.database;
    await db.delete(
      cardsTable,
      where: 'deckId = ?',
      whereArgs: [deckId],
    );
    return await db.delete(
      decksTable,
      where: 'id = ?',
      whereArgs: [deckId],
    );
  }
}