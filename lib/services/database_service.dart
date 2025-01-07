import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseService {
  static final DataBaseService _instance = DataBaseService._internal();
  static Database? _database;

  factory DataBaseService() => _instance;

  DataBaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  final String _tableName = "invoices";

  final String _invoicePath = "invoice_path";
  final String _invoiceNum = "invoice_num";
  final String _date = "date";
  final String _paymentMode = "payment_mode";
  final String _termsOfDelivery = "terms_of_delivery";
  final String _buyersName = "buyers_name";
  final String _buyersAddress = "buyers_address";
  final String _buyersTelephone = "buyers_telephone";
  final String _buyersGstNum = "buyers_gst_num";
  final String _buyersPan = "buyers_pan";
  final String _stateName = "state_name";
  final String _goodsDescription = "goods_description";
  final String _amountBeforeGst = "amount_before_gst";
  final String _CGST = "cgst";
  final String _SGST = "sgst";
  final String _totalQuantity = "total_quantity";
  final String _totalAmount = "total_amount";
  final String _CGSTRate = "cgst_rate";
  final String _SGSTRate = "sgst_rate";
  final String _totalTaxAmount = "total_tax_amount";
  final String _isB2B = "b2b";

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'invoices_db.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            $_invoicePath TEXT NOT NULL,
            $_invoiceNum TEXT NOT NULL,
            $_date TEXT NOT NULL,
            $_paymentMode TEXT NOT NULL,
            $_termsOfDelivery TEXT NOT NULL,
            $_buyersName TEXT NOT NULL,
            $_buyersAddress TEXT,
            $_buyersTelephone TEXT,
            $_buyersGstNum TEXT,
            $_buyersPan TEXT,
            $_stateName TEXT NOT NULL,
            $_goodsDescription TEXT NOT NULL,
            $_amountBeforeGst REAL NOT NULL,
            $_CGST TEXT NOT NULL,
            $_SGST TEXT NOT NULL,
            $_totalQuantity INTEGER NOT NULL,
            $_totalAmount TEXT NOT NULL,
            $_CGSTRate TEXT NOT NULL,
            $_SGSTRate TEXT NOT NULL,
            $_totalTaxAmount TEXT NOT NULL,
            $_isB2B INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertInvoice(Map<String, dynamic> invoiceData) async {
    final db = await database;
    return await db.insert(_tableName, invoiceData);
  }

  Future<List<Map<String, dynamic>>> getInvoices() async {
    final db = await database;
    return await db.query(_tableName);
  }

  Future<int> deleteInvoice(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateInvoice(int id, Map<String, dynamic> updatedData) async {
    final db = await database;
    return await db.update(
      _tableName,
      updatedData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
