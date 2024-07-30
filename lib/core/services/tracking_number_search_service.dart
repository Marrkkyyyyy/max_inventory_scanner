import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:max_inventory_scanner/core/utils/check_internet.dart';

class TrackingNumberSearchService {
  final FirebaseFirestore _firestore;

  TrackingNumberSearchService(this._firestore);

  Future<List<String>> searchTrackingNumbers(
      String query, String currentLocation) async {
    try {
      if (!await InternetChecker.checkInternet()) {
        return [];
      }

      Set<String> uniqueTrackingNumbers = {};

      Query baseQuery = _firestore.collection('Package');

      String lowercaseQuery = query.toLowerCase();

      QuerySnapshot rawQuerySnapshot = await baseQuery
          .orderBy('rawTrackingNumber')
          .startAt([lowercaseQuery])
          .endAt(['$lowercaseQuery\uf8ff'])
          .limit(20)
          .get();

      _processQuerySnapshot(rawQuerySnapshot, uniqueTrackingNumbers,
          lowercaseQuery, currentLocation);

      if (uniqueTrackingNumbers.length < 20) {
        QuerySnapshot trackingQuerySnapshot = await baseQuery
            .orderBy('trackingNumber')
            .startAt([lowercaseQuery])
            .endAt(['$lowercaseQuery\uf8ff'])
            .limit(20 - uniqueTrackingNumbers.length)
            .get();

        _processQuerySnapshot(trackingQuerySnapshot, uniqueTrackingNumbers,
            lowercaseQuery, currentLocation);
      }

      return uniqueTrackingNumbers.toList();
    } catch (e) {
      return [];
    }
  }

  void _processQuerySnapshot(QuerySnapshot snapshot,
      Set<String> uniqueTrackingNumbers, String query, String currentLocation) {
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (currentLocation == 'Consolidation') {
        String status = (data['status'] as String?)?.toLowerCase() ?? '';
        if (status != 'receiving' && status != 'consolidated') {
          continue;
        }
      }

      String rawTrackingNumber =
          (data['rawTrackingNumber'] as String?)?.toLowerCase() ?? '';
      String trackingNumber =
          (data['trackingNumber'] as String?)?.toLowerCase() ?? '';

      if (rawTrackingNumber.contains(query)) {
        uniqueTrackingNumbers.add(rawTrackingNumber);
      }
      if (trackingNumber.contains(query) &&
          trackingNumber != rawTrackingNumber) {
        uniqueTrackingNumbers.add(trackingNumber);
      }

      if (uniqueTrackingNumbers.length >= 20) {
        break;
      }
    }
  }
}
