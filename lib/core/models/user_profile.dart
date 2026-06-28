class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.isGuest,
    this.preferredPlatforms = const [],
  });

  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final bool isGuest;
  final List<String> preferredPlatforms;
}