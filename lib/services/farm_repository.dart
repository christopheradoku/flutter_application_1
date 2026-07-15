import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/farm_models.dart';

class FarmRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ------------------------------------------------------------------------
  // SECURITY CHECKPOINT: Always routes to the current farmer's private folder
  // ------------------------------------------------------------------------
  DocumentReference get _userDoc {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("Authentication Error: No user is currently logged in.");
    }
    return _db.collection('users').doc(uid);
  }

  // ========================================================================
  // READS: Fetching private data from Firestore and converting to your Models
  // ========================================================================

  Future<FlockInfo> fetchFlockInfo() async {
    try {
      final doc = await _userDoc.get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return FlockInfo(
          flockSize: data['flockSize'] ?? 0,
          batches: data['batches'] ?? 0,
          alerts: data['alerts'] ?? 0,
        );
      }
    } catch (e) {
      print("Error fetching flock info: $e");
    }
    return const FlockInfo(flockSize: 0, batches: 0, alerts: 0);
  }

  Future<List<FeedEntry>> fetchFeedEntries() async {
    final snapshot = await _userDoc.collection('feed_entries').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FeedEntry(
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        feedType: data['feedType'] ?? 'Unknown',
        kg: (data['kg'] ?? 0).toDouble(),
      );
    }).toList();
  }

  Future<List<EggCollection>> fetchEggCollections() async {
    final snapshot = await _userDoc.collection('egg_collections').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return EggCollection(
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        gradeA: data['gradeA'] ?? 0,
        gradeB: data['gradeB'] ?? 0,
        gradeC: data['gradeC'] ?? 0,
        cracked: data['cracked'] ?? 0,
        hensActive: data['hensActive'] ?? 0,
      );
    }).toList();
  }

  Future<List<MortalityEvent>> fetchMortalityEvents() async {
    final snapshot = await _userDoc.collection('mortality_events').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MortalityEvent(
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        count: data['count'] ?? 0,
        cause: data['cause'] ?? 'Unknown',
      );
    }).toList();
  }

  Future<List<VaccinationRecord>> fetchVaccinations() async {
    final snapshot = await _userDoc.collection('vaccinations').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return VaccinationRecord(
        id: doc.id,
        name: data['name'] ?? 'Unknown Vaccine',
        birds: data['birds'] ?? 0,
        method: data['method'] ?? 'Unknown',
        scheduledDate: (data['scheduledDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        administeredDate: (data['administeredDate'] as Timestamp?)?.toDate(),
      );
    }).toList();
  }

  Future<List<FarmTransaction>> fetchTransactions() async {
    final snapshot = await _userDoc.collection('transactions').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return FarmTransaction(
        date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        category: data['category'] ?? 'Unknown',
        amount: (data['amount'] ?? 0).toDouble(),
        type: data['type'] == 'TransactionType.income'
            ? TransactionType.income
            : TransactionType.expense,
      );
    }).toList();
  }

  // ========================================================================
  // WRITES: Saving data into the current farmer's private Firestore subcollections
  // ========================================================================
  
  Future<void> updateFlockInfo(int flockSize, int batches) async {
    await _userDoc.set({
      'flockSize': flockSize,
      'batches': batches,
    }, SetOptions(merge: true));
  }

  Future<void> saveFeedEntry(FeedEntry entry) async {
    await _userDoc.collection('feed_entries').add({
      'date': Timestamp.fromDate(entry.date),
      'feedType': entry.feedType,
      'kg': entry.kg,
    });
  }

  Future<void> saveEggCollection(EggCollection entry) async {
    await _userDoc.collection('egg_collections').add({
      'date': Timestamp.fromDate(entry.date),
      'gradeA': entry.gradeA,
      'gradeB': entry.gradeB,
      'gradeC': entry.gradeC,
      'cracked': entry.cracked,
      'hensActive': entry.hensActive,
    });
  }

  Future<void> saveMortalityEvent(MortalityEvent event) async {
    await _userDoc.collection('mortality_events').add({
      'date': Timestamp.fromDate(event.date),
      'count': event.count,
      'cause': event.cause,
    });
  }

  Future<void> saveTransaction(FarmTransaction transaction) async {
    await _userDoc.collection('transactions').add({
      'date': Timestamp.fromDate(transaction.date),
      'category': transaction.category,
      'amount': transaction.amount,
      'type': transaction.type.toString(), 
    });
  }

  // --- VACCINATION UPDATES ---
  Future<String> saveNewVaccination(VaccinationRecord record) async {
    final docRef = await _userDoc.collection('vaccinations').add({
      'name': record.name,
      'scheduledDate': Timestamp.fromDate(record.scheduledDate),
      'administeredDate': record.administeredDate != null ? Timestamp.fromDate(record.administeredDate!) : null,
      'birds': record.birds,
      'method': record.method,
      'isDone': record.administeredDate != null,
    });
    return docRef.id;
  }

  Future<void> markVaccineDone(String id) async {
    await _userDoc.collection('vaccinations').doc(id).update({
      'administeredDate': Timestamp.now(),
      'isDone': true,
    });
  }
}