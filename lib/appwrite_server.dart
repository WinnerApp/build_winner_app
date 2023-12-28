import 'package:build_winner_app/environment.dart';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';

class AppwriteServer {
  final Client client;
  final AppwriteEnvironment environment;
  AppwriteServer(this.environment) : client = Client() {
    client
      ..setEndpoint(environment.endPoint)
      ..setProject(environment.projectId)
      ..setKey(environment.apiKey);
  }

  Databases get databases => Databases(client);

  Future<Database?> getDatabase() async {
    try {
      return databases.get(databaseId: environment.databaseId);
    } catch (e) {
      return null;
    }
  }

  Future<Collection?> getCollection() async {
    try {
      return databases.getCollection(
        databaseId: environment.databaseId,
        collectionId: environment.collectionId,
      );
    } catch (e) {
      return null;
    }
  }
}
