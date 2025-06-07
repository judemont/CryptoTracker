import 'package:cryptotracker/models/crypto.dart';
import 'package:cryptotracker/models/portfolio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static const String databaseName = "cryptotrackerDB.sqlite";
  static Database? db;

  static const databaseVersion = 3;
  List<String> tables = ["favorites", "portfolio"];

  static Future<Database> initializeDb() async {
    final databasePath = (await getApplicationDocumentsDirectory()).path;
    final path = join(databasePath, databaseName);
    return db ??
        await openDatabase(
          path,
          version: databaseVersion,
          onCreate: (Database db, int version) async {
            await createTables(db);
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            await updateTables(db, oldVersion, newVersion);
          },
          onOpen: (db) async {
            await openDB(db);
          },
        );
  }

  static openDB(Database db) {
    db.rawQuery('SELECT * FROM sqlite_master ORDER BY name;').then((value) {
      print(value);
    });
  }

  static updateTables(Database db, int oldVersion, int newVersion) {
    print(" DB Version : $newVersion");
    print(oldVersion);
    if (oldVersion < newVersion) {
      if (oldVersion < 2) {
        db.execute("""
          CREATE TABLE portfolio(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              crypto TEXT,
              amount REAL
          )
        """);
      }
      if (oldVersion < 3) {
        db.execute("""
          ALTER TABLE portfolio RENAME TO portfolioValue;
        """);
        db.execute("""
          ALTER TABLE portfolioValue ADD COLUMN portfolioID INTEGER;
        """);
        db.execute("""
          CREATE TABLE portfolio(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT
          )
        """);
      }
    }
  }

  static Future<void> createTables(Database database) async {
    await database.execute("""
      CREATE TABLE favorites(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          crypto TEXT
      )
    """);
    await database.execute("""
          CREATE TABLE portfolio(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT
          )
        """);
    await database.execute("""
          CREATE TABLE portfolioValue(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              crypto TEXT,
              amount REAL,
              portfolioID INTEGER
          )
        """);
  }

  static Future<int> newFavorite(String crypto) async {
    print("CREATE");

    final db = await DatabaseService.initializeDb();

    final id = await db.insert('favorites', {'crypto': crypto});
    return id;
  }

  static Future<List<String>> getFavorites() async {
    final db = await DatabaseService.initializeDb();

    List<Map<String, dynamic>> queryResult = await db.query('favorites');

    return queryResult.map((e) => e["crypto"] as String).toList();
  }

  static Future<void> removeFavorite(int id) async {
    final db = await DatabaseService.initializeDb();
    db.delete("favorites", where: "id = $id");
  }

  static Future<void> removeFavoriteFromCrypto(String name) async {
    final db = await DatabaseService.initializeDb();
    db.delete("favorites", where: "crypto = '$name'");
  }

  static Future<int> newPortfolioCoin(
      String cryptoId, double amount, int portfolioId) async {
    final db = await DatabaseService.initializeDb();
    final id = await db.insert('portfolioValue',
        {'crypto': cryptoId, 'amount': amount, 'portfolioID': portfolioId});
    return id;
  }

  static Future<int> newPortfolio(String name) async {
    final db = await DatabaseService.initializeDb();
    final id = await db.insert('portfolio', {'name': name});
    return id;
  }

  static Future<int> updatePortfolio(int portfolioID, String name) async {
    removePortfolio(portfolioID);
    final db = await DatabaseService.initializeDb();
    final id = await db.insert('portfolio', {'name': name});
    return id;
  }

  static Future<int> updatePortfolioCoin(
      String cryptoId, double amount, int portfolioID) async {
    removePortfolioCoin(cryptoId, portfolioID);
    final db = await DatabaseService.initializeDb();
    final id = await db.insert('portfolioValue',
        {'crypto': cryptoId, 'amount': amount, 'portfolioID': portfolioID});
    return id;
  }

  static Future<List<Portfolio>> getPortfolios() async {
    final db = await DatabaseService.initializeDb();

    List<Map<String, dynamic>> queryResult = await db.query('portfolio');

    return queryResult
        .map((e) => Portfolio(id: e["id"], name: e["name"]))
        .toList();
  }

  static Future<List<Crypto>> getPortfolioValues(int portfolioID) async {
    final db = await DatabaseService.initializeDb();

    List<Map<String, dynamic>> queryResult = await db.query('portfolioValue',
        where: 'portfolioID = ?', whereArgs: [portfolioID]);

    return queryResult
        .map((e) => Crypto(id: e["crypto"], amount: e["amount"]))
        .toList();
  }

  static Future<void> removePortfolioCoin(
      String cryptoId, int portfolioID) async {
    final db = await DatabaseService.initializeDb();
    print("remove $cryptoId from $portfolioID");
    db.delete("portfolioValue",
        where: "crypto = '$cryptoId' AND portfolioID = '$portfolioID'");
  }

  static Future<void> removePortfolio(int portfolioID) async {
    final db = await DatabaseService.initializeDb();
    db.delete("portfolio", where: "id = '$portfolioID'");
  }
}
