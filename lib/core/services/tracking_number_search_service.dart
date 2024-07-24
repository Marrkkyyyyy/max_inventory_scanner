import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:max_inventory_scanner/core/utils/check_internet.dart';

class TrackingNumberSearchService {
  final FirebaseFirestore _firestore;

  TrackingNumberSearchService(this._firestore);

  Future<List<String>> searchTrackingNumbers(String query) async {
    try {
      if (!await InternetChecker.checkInternet()) {
        return [];
      }

      Set<String> uniqueTrackingNumbers = {};

      QuerySnapshot rawResult = await _firestore
          .collection('Package')
          .where('rawTrackingNumber', isGreaterThanOrEqualTo: query)
          .where('rawTrackingNumber', isLessThan: '${query}z')
          .limit(10)
          .get();

      for (var doc in rawResult.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['rawTrackingNumber'] != null) {
          uniqueTrackingNumbers.add(data['rawTrackingNumber']);
        }
      }

      QuerySnapshot trackingResult = await _firestore
          .collection('Package')
          .where('trackingNumber', isGreaterThanOrEqualTo: query)
          .where('trackingNumber', isLessThan: '${query}z')
          .limit(10)
          .get();

      for (var doc in trackingResult.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['trackingNumber'] != null) {
          uniqueTrackingNumbers.add(data['trackingNumber']);
        }
      }

      return uniqueTrackingNumbers.toList();
    } catch (e) {
      return [];
    }
  }
}
