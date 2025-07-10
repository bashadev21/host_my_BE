import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  final db = await Db.create('mongodb://localhost:27017/shelf_db');

  await db.open();
  final messagesCollection = db.collection('messages');

  final router = Router();

  // POST: Add message to MongoDB
  router.post('/messages', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);
    await messagesCollection.insertOne(data);

    return Response.ok(jsonEncode({'status': 'Message saved'}),
        headers: {'Content-Type': 'application/json'});
  });

  // GET: Fetch all messages from MongoDB
  router.get('/messages', (Request request) async {
    final messages = await messagesCollection.find().toList();
    return Response.ok(jsonEncode(messages),
        headers: {'Content-Type': 'application/json'});
  });

  final handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(router.call);

  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('✅ Server running at http://${server.address.host}:${server.port}');
}
