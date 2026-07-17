/// Core domain models for the poultry farm app.
/// These replace the ad-hoc Map<String, dynamic> lists that were hardcoded
/// directly into the screen widgets.
library;

class FlockInfo {
  final int flockSize;
  final int batches;
  final int alerts;

  const FlockInfo({
    required this.flockSize,
    required this.batches,
    required this.alerts,
  });
}

class FeedEntry {
  final DateTime date;
  final String feedType; // 'Starter Feed' | 'Grower Feed' | 'Finisher Feed'
  final double kg;

  const FeedEntry({
    required this.date,
    required this.feedType,
    required this.kg,
  });
}

class EggCollection {
  final DateTime date;
  final int gradeA;
  final int gradeB;
  final int gradeC;
  final int cracked;
  final int hensActive;

  const EggCollection({
    required this.date,
    this.gradeA = 0,
    this.gradeB = 0,
    this.gradeC = 0,
    this.cracked = 0,
    this.hensActive = 0,
  });

  int get total => gradeA + gradeB + gradeC + cracked;
}

class MortalityEvent {
  final DateTime date;
  final int count;
  final String cause; // 'Respiratory' | 'Disease' | 'Injury' | 'Unknown'

  const MortalityEvent({
    required this.date,
    required this.count,
    required this.cause,
  });
}

class VaccinationRecord {
  final String id;
  final String name;
  final DateTime scheduledDate;
  final DateTime? administeredDate;
  final int birds;
  final String method; // 'Intraocular' | 'Drinking water' | ...

  const VaccinationRecord({
    required this.id,
    required this.name,
    required this.scheduledDate,
    this.administeredDate,
    required this.birds,
    required this.method,
  });

  bool get isDone => administeredDate != null;

  VaccinationRecord copyWith({DateTime? administeredDate}) {
    return VaccinationRecord(
      id: id,
      name: name,
      scheduledDate: scheduledDate,
      administeredDate: administeredDate ?? this.administeredDate,
      birds: birds,
      method: method,
    );
  }
}

enum TransactionType { income, expense }

class FarmTransaction {
  final DateTime date;
  final String category; // 'Egg Sales', 'Feed Cost', etc.
  final double amount;
  final TransactionType type;

  const FarmTransaction({
    required this.date,
    required this.category,
    required this.amount,
    required this.type,
  });
}
