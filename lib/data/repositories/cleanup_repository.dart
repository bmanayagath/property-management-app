import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../services/logger_service.dart';

class CleanupRepository {
  CleanupRepository({FirebaseFirestore? firestore}) : _firestore = firestore;

  FirebaseFirestore? _firestore;

  static const deletedRecordCollections = [
    'villas',
    'rooms',
    'incomes',
    'expenses',
    'notifications',
    'room_media',
    'tenant_history',
    'app_logs',
  ];

  FirebaseFirestore get _requiredFirestore {
    if (Firebase.apps.isEmpty) {
      throw StateError('Firebase is unavailable.');
    }
    return _firestore ??= FirebaseFirestore.instance;
  }

  Future<DeletedRecordsCleanupResult> hardDeleteDeletedRecords({
    required String deletedBy,
  }) async {
    final firestore = _requiredFirestore;
    final counts = <String, int>{};

    for (final collectionName in deletedRecordCollections) {
      counts[collectionName] = await _deleteSoftDeletedDocs(
        firestore.collection(collectionName),
      );
    }

    await LoggerService.logWarning(
      screenName: 'CleanupRepository',
      operation: 'HardDeleteDeletedRecords',
      message: 'Soft-deleted records permanently deleted.',
      details: [
        'deletedBy: $deletedBy',
        for (final entry in counts.entries) '${entry.key}: ${entry.value}',
      ].join('\n'),
    );

    return DeletedRecordsCleanupResult(counts);
  }

  Future<int> _deleteSoftDeletedDocs(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    var deletedCount = 0;

    while (true) {
      final snapshot =
          await collection.where('isDeleted', isEqualTo: true).limit(450).get();
      if (snapshot.docs.isEmpty) break;

      final batch = collection.firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      deletedCount += snapshot.docs.length;
    }

    return deletedCount;
  }
}

class DeletedRecordsCleanupResult {
  final Map<String, int> counts;

  const DeletedRecordsCleanupResult(this.counts);

  int get totalDeleted =>
      counts.values.fold(0, (total, count) => total + count);

  String get summary {
    if (counts.isEmpty) return 'No records deleted.';
    return counts.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(', ');
  }
}
