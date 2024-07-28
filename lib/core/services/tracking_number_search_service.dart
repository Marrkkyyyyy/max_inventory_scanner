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

      QuerySnapshot querySnapshot = await baseQuery
          .where('rawTrackingNumber', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('rawTrackingNumber', isLessThan: '${lowercaseQuery}z')
          .limit(20)
          .get();

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (currentLocation == 'Consolidation') {
          String status = (data['status'] as String?)?.toLowerCase() ?? '';
          if (status != 'receiving' && status != 'consolidated') {
            continue;
          }
        }

        if (data['rawTrackingNumber'] != null) {
          uniqueTrackingNumbers
              .add(data['rawTrackingNumber'].toString().toLowerCase());
        }
        if (data['trackingNumber'] != null) {
          uniqueTrackingNumbers
              .add(data['trackingNumber'].toString().toLowerCase());
        }
      }

      if (uniqueTrackingNumbers.length < 10) {
        QuerySnapshot trackingSnapshot = await baseQuery
            .where('trackingNumber', isGreaterThanOrEqualTo: lowercaseQuery)
            .where('trackingNumber', isLessThan: '${lowercaseQuery}z')
            .limit(20 - uniqueTrackingNumbers.length)
            .get();

        for (var doc in trackingSnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;

          if (currentLocation == 'Consolidation') {
            String status = (data['status'] as String?)?.toLowerCase() ?? '';
            if (status != 'receiving' && status != 'consolidated') {
              continue;
            }
          }

          if (data['trackingNumber'] != null) {
            uniqueTrackingNumbers
                .add(data['trackingNumber'].toString().toLowerCase());
          }
        }
      }

      return uniqueTrackingNumbers.toList();
    } catch (e) {
      return [];
    }
  }
}
