import 'package:cloud_firestore/cloud_firestore.dart';

import 'analytics_service.dart';
import 'firestore_schema_service.dart';

class AffiliateBanner {
  const AffiliateBanner({required this.id, required this.title, required this.description, required this.url, required this.priority, required this.position});

  final String id;
  final String title;
  final String description;
  final String url;
  final int priority;
  final String position;

  factory AffiliateBanner.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AffiliateBanner(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      url: data['affiliateURL'] as String? ?? data['url'] as String? ?? '',
      priority: data['priority'] as int? ?? 0,
      position: data['displayPosition'] as String? ?? data['position'] as String? ?? '',
    );
  }
}

class AffiliateService {
  AffiliateService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<AffiliateBanner>> activeBanners(String position) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.affiliateBanners)
        .where('displayPosition', isEqualTo: position)
        .where('active', isEqualTo: true)
        .orderBy('priority')
        .get();
    return snapshot.docs.map(AffiliateBanner.fromFirestore).toList();
  }

  Future<void> trackImpression(String bannerId) async {
    await _firestore.collection(FirestoreCollections.affiliateBanners).doc(bannerId).update({'impressions': FieldValue.increment(1)});
    await analyticsServiceProviderInstance.track('affiliate_banner_impression', parameters: {'banner_id': bannerId});
  }

  Future<void> trackClick(String bannerId) async {
    await _firestore.collection(FirestoreCollections.affiliateBanners).doc(bannerId).update({'clicks': FieldValue.increment(1)});
    await analyticsServiceProviderInstance.track('affiliate_banner_click', parameters: {'banner_id': bannerId});
  }
}