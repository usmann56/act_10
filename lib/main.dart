import 'package:flutter/material.dart';
import 'services/database_helper.dart';

// Using a global variable for simplicity.
// In production, consider using dependency injection (e.g., get_it).
final dbHelper = DatabaseHelper();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  await dbHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFlite Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final TextEditingController _idController = TextEditingController();
  String _queryResult = '';
  String _enteredId = '';

  // Homepage layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('sqflite')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: _insert, child: const Text('Insert')),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _query, child: const Text('Query')),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _update, child: const Text('Update')),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _delete, child: const Text('Delete')),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _deleteAll,
              child: const Text('Delete All'),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: 200,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Enter ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _enteredId = value; // store the value directly
                },
                onSubmitted: (value) => _queryById(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _queryById,
              child: const Text('Find Record'),
            ),
            const SizedBox(height: 20),
            Text(
              _queryResult,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Button onPressed methods
  static void _insert() async {
    // Row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: 'Bob',
      DatabaseHelper.columnAge: 23,
    };
    final id = await dbHelper.insert(row);
    debugPrint('Inserted row id: $id');
  }

  static void _query() async {
    final allRows = await dbHelper.queryAllRows();
    debugPrint('Query all rows:');
    for (final row in allRows) {
      debugPrint(row.toString());
    }
  }

  static void _update() async {
    // Row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnName: 'Mary',
      DatabaseHelper.columnAge: 32,
    };
    final rowsAffected = await dbHelper.update(row);
    debugPrint('Updated $rowsAffected row(s)');
  }

  static void _delete() async {
    // Assuming that the number of rows is the id for the last row
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    debugPrint('Deleted $rowsDeleted row(s): row $id');
  }

  Future<void> _deleteAll() async {
    final id = await dbHelper.queryRowCount();
    await dbHelper.deleteAll();
    debugPrint('Deleted $id rows');
    setState(() => _enteredId = '');
    setState(() => _queryResult = '');
  }

  Future<void> _queryById() async {
    if (_enteredId.isEmpty) {
      setState(() => _queryResult = 'Please enter an ID.');
      return;
    }

    final id = int.tryParse(_enteredId);
    if (id == null) {
      setState(() => _queryResult = 'Invalid ID format.');
      return;
    }

    final result = await dbHelper.queryRowById(id);
    setState(() {
      _queryResult = result != null
          ? 'Found ID: ${result[DatabaseHelper.columnId]} Name: ${result[DatabaseHelper.columnName]}, Age: ${result[DatabaseHelper.columnAge]}'
          : 'No record found for ID $id.';
    });
  }
}
