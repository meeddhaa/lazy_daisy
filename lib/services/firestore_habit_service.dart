import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mini_habit_tracker/models/habit.dart';

class FirestoreHabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get userId => _auth.currentUser?.uid;

  // Get habits collection reference for current user
  CollectionReference? get _habitsCollection {
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('habits');
  }

  // Add a habit
  Future<void> addHabit(Habit habit) async {
    if (_habitsCollection == null) return;
    await _habitsCollection!.doc(habit.id.toString()).set({
      'name': habit.name,
      'completedDays': habit.completedDays,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update a habit
  Future<void> updateHabit(Habit habit) async {
    if (_habitsCollection == null) return;
    await _habitsCollection!.doc(habit.id.toString()).update({
      'name': habit.name,
      'completedDays': habit.completedDays,
    });
  }

  // Delete a habit
  Future<void> deleteHabit(int habitId) async {
    if (_habitsCollection == null) return;
    await _habitsCollection!.doc(habitId.toString()).delete();
  }

  // Get all habits for current user
  Stream<List<Habit>> getHabits() {
    if (_habitsCollection == null) return Stream.value([]);
    
    return _habitsCollection!.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Habit(
          name: data['name'] ?? '',
          completedDaysParam: List<int>.from(data['completedDays'] ?? []),
        );
      }).toList();
    });
  }
}
