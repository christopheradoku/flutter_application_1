import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../models/farm_models.dart';
import '../services/farm_repository.dart';

class FarmProvider extends ChangeNotifier {
  FarmProvider({FarmRepository? repository}) : _repo = repository ?? FarmRepository() {
    loadAll();
  }

  final FarmRepository _repo;

  bool isLoading = true;
  String? error;

  FlockInfo flockInfo = const FlockInfo(flockSize: 0, batches: 0, alerts: 0);
  List<FeedEntry> feedEntries = [];
  List<EggCollection> eggCollections = [];
  List<MortalityEvent> mortalityEvents = [];
  List<VaccinationRecord> vaccinations = [];
  List<FarmTransaction> transactions = [];

  Future<void> loadAll() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      error = "Please sign in to view your farm data.";
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repo.fetchFlockInfo(),
        _repo.fetchFeedEntries(),
        _repo.fetchEggCollections(),
        _repo.fetchMortalityEvents(),
        _repo.fetchVaccinations(),
        _repo.fetchTransactions(),
      ]);
      flockInfo = results[0] as FlockInfo;
      feedEntries = results[1] as List<FeedEntry>;
      eggCollections = results[2] as List<EggCollection>;
      mortalityEvents = results[3] as List<MortalityEvent>;
      vaccinations = results[4] as List<VaccinationRecord>;
      transactions = results[5] as List<FarmTransaction>;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTime> _last7Days() {
    final today = DateTime.now();
    return List.generate(7, (i) => DateTime(today.year, today.month, today.day - (6 - i)));
  }

  // ---------------- Feed ----------------

  double get todayFeedKg {
    final today = DateTime.now();
    return feedEntries.where((e) => _isSameDay(e.date, today)).fold(0.0, (s, e) => s + e.kg);
  }

  List<double> get last7DaysFeedTotals {
    return _last7Days()
        .map((d) => feedEntries.where((e) => _isSameDay(e.date, d)).fold(0.0, (s, e) => s + e.kg))
        .toList();
  }

  Map<String, double> get feedTypeBreakdownToday {
    final today = DateTime.now();
    final todays = feedEntries.where((e) => _isSameDay(e.date, today));
    final Map<String, double> out = {};
    for (final e in todays) {
      out[e.feedType] = (out[e.feedType] ?? 0) + e.kg;
    }
    return out;
  }

  Future<void> addFeedEntry({required String feedType, required double kg}) async {
    final entry = FeedEntry(date: DateTime.now(), feedType: feedType, kg: kg);
    await _repo.saveFeedEntry(entry);
    feedEntries.add(entry);
    notifyListeners();
  }

  // ---------------- Eggs ----------------

  EggCollection? get todayEggCollection {
    final today = DateTime.now();
    final matches = eggCollections.where((e) => _isSameDay(e.date, today));
    return matches.isEmpty ? null : matches.first;
  }

  List<EggCollection> get last7DaysEggs {
    return _last7Days().map((d) {
      final matches = eggCollections.where((e) => _isSameDay(e.date, d));
      return matches.isEmpty ? EggCollection(date: d) : matches.first;
    }).toList();
  }

  Future<void> addEggCollection({required int gradeA, required int gradeB, required int gradeC, required int cracked, required int hensActive}) async {
    final entry = EggCollection(date: DateTime.now(), gradeA: gradeA, gradeB: gradeB, gradeC: gradeC, cracked: cracked, hensActive: hensActive); 
    await _repo.saveEggCollection(entry);
    eggCollections.add(entry);
    notifyListeners();
  }

  // ---------------- Mortality ----------------

  List<MortalityEvent> get last7DaysMortality {
    final days = _last7Days();
    return days.map((d) {
      final matches = mortalityEvents.where((e) => _isSameDay(e.date, d));
      final count = matches.fold(0, (s, e) => s + e.count);
      return MortalityEvent(date: d, count: count, cause: matches.isEmpty ? 'None' : matches.first.cause);
    }).toList();
  }

  Map<String, int> get mortalityByCauseThisWeek {
    final Map<String, int> out = {};
    for (final e in mortalityEvents) {
      out[e.cause] = (out[e.cause] ?? 0) + e.count;
    }
    return out;
  }

  int get totalMortalityThisWeek => mortalityEvents.fold(0, (s, e) => s + e.count);

  double get mortalityRate => flockInfo.flockSize == 0 ? 0 : totalMortalityThisWeek / flockInfo.flockSize;

  Future<void> updateFlock(int size, int batches) async {
    await _repo.updateFlockInfo(size, batches);
    flockInfo = FlockInfo(flockSize: size, batches: batches, alerts: flockInfo.alerts);
    notifyListeners();
  }

  Future<void> addMortalityEvent({required int count, required String cause}) async {
    final entry = MortalityEvent(date: DateTime.now(), count: count, cause: cause);
    await _repo.saveMortalityEvent(entry);
    mortalityEvents.add(entry);

    final newSize = (flockInfo.flockSize - count) > 0 ? (flockInfo.flockSize - count) : 0;
    await updateFlock(newSize, flockInfo.batches);

    notifyListeners();
  }

  // ---------------- Vaccination ----------------

  int get vaccinationsDoneCount => vaccinations.where((v) => v.isDone).length;

  double get vaccinationProgress => vaccinations.isEmpty ? 0 : vaccinationsDoneCount / vaccinations.length;

  VaccinationRecord? get nextUpcomingVaccination {
    final pending = vaccinations.where((v) => !v.isDone).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return pending.isEmpty ? null : pending.first;
  }

  Future<void> markVaccinationAdministered(String id) async {
    await _repo.markVaccineDone(id);
    
    final index = vaccinations.indexWhere((v) => v.id == id);
    if (index != -1) {
      final old = vaccinations[index];
      vaccinations[index] = VaccinationRecord(
        id: old.id,
        name: old.name,
        scheduledDate: old.scheduledDate,
        administeredDate: DateTime.now(), 
        birds: old.birds,
        method: old.method,
      );
      notifyListeners(); 
    }
  }

  Future<void> addVaccinationRecord(VaccinationRecord record) async {
    final newId = await _repo.saveNewVaccination(record);
    
    final newRecord = VaccinationRecord(
      id: newId,
      name: record.name,
      scheduledDate: record.scheduledDate,
      administeredDate: record.administeredDate,
      birds: record.birds,
      method: record.method,
    );
    
    vaccinations.add(newRecord);
    vaccinations.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    notifyListeners(); 
  }

  // ---------------- Profit / Loss ----------------

  double get totalRevenue => transactions.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);

  double get totalExpenses => transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);

  double get netProfit => totalRevenue - totalExpenses;

  List<FarmTransaction> get incomeItems => transactions.where((t) => t.type == TransactionType.income).toList();

  List<FarmTransaction> get expenseItems => transactions.where((t) => t.type == TransactionType.expense).toList();

  Future<void> addTransaction({required String category, required double amount, required TransactionType type}) async {
    final entry = FarmTransaction(date: DateTime.now(), category: category, amount: amount, type: type);
    await _repo.saveTransaction(entry);
    transactions.add(entry);
    notifyListeners();
  }

  // ---------------- Dashboard summary ----------------

  int get dashboardAlerts => flockInfo.alerts;
  // --- NEW: Wipes all local memory on sign out ---
  void clearData() {
    flockInfo = const FlockInfo(flockSize: 0, batches: 0, alerts: 0);
    feedEntries = [];
    eggCollections = [];
    mortalityEvents = [];
    vaccinations = [];
    transactions = [];
    error = null;
    notifyListeners();
  }
}