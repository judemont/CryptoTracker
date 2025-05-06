import 'package:cryptotracker/models/portfolio_coin.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static const String databaseName = "cryptotrackerDB.sqlite";
  static Database? db;

  static const databaseVersion = 2;
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
              crypto TEXT,
              amount REAL
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

  static Future<int> newPortfolioCoin(String cryptoId, double amount) async {
    final db = await DatabaseService.initializeDb();
    final id =
        await db.insert('portfolio', {'crypto': cryptoId, 'amount': amount});
    return id;
  }

  static Future<List<PortfolioCoin>> getPortfolio() async {
    final db = await DatabaseService.initializeDb();

    List<Map<String, dynamic>> queryResult = await db.query('portfolio');

    return queryResult
        .map((e) => PortfolioCoin(id: e["crypto"], amount: e["amount"]))
        .toList();
  }

  static Future<void> removePortfolioCoin(String cryptoId) async {
    final db = await DatabaseService.initializeDb();
    db.delete("portfolio", where: "crypto = $cryptoId");
  }
}
