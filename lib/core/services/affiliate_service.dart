class AffiliateBanner {
  const AffiliateBanner({required this.id, required this.title, required this.description, required this.url, required this.priority, required this.position});

  final String id;
  final String title;
  final String description;
  final String url;
  final int priority;
  final String position;
}

class AffiliateService {
  Future<List<AffiliateBanner>> activeBanners(String position) async => const [];
  Future<void> trackImpression(String bannerId) async {}
  Future<void> trackClick(String bannerId) async {}
}