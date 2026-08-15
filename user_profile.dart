import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.dailyStepGoal = 10000,
    this.isProfileComplete = false,
    this.createdAt,
    this.lastActiveAt,
    
    this.friendIds = const [],
    this.challengeIds = const [],
    
    this.lastSyncedAt,
  });
 
  final String uid;
  final String email;
  final String displayName;
  
  final String? avatarUrl;
  
  final int dailyStepGoal;
  
  final bool isProfileComplete;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;
  
  final List<String> friendIds;
  
  final List<String> challengeIds;
  
  final DateTime? lastSyncedAt;

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'dailyStepGoal': dailyStepGoal,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastActiveAt':
          lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      'friendIds': friendIds,
      'challengeIds': challengeIds,
      'lastSyncedAt':
          lastSyncedAt != null ? Timestamp.fromDate(lastSyncedAt!) : null,
    };
  }
  
  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserProfile(
      uid: data['uid'] as String? ?? doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'StepSync User',
      avatarUrl: data['avatarUrl'] as String?,
      dailyStepGoal: data['dailyStepGoal'] as int? ?? 10000,
      isProfileComplete: data['isProfileComplete'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate(),
      friendIds: List<String>.from(data['friendIds'] as List? ?? []),
      challengeIds: List<String>.from(data['challengeIds'] as List? ?? []),
      lastSyncedAt: (data['lastSyncedAt'] as Timestamp?)?.toDate(),
    );
  }
  
  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? avatarUrl,
    int? dailyStepGoal,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    List<String>? friendIds,
    List<String>? challengeIds,
    DateTime? lastSyncedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      friendIds: friendIds ?? this.friendIds,
      challengeIds: challengeIds ?? this.challengeIds,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
  @override
  String toString() => 'UserProfile(uid: $uid, displayName: $displayName)';
}
