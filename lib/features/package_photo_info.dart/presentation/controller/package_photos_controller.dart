import 'package:get/get.dart';

class PhotoViewerController extends GetxController {
  final RxInt currentPage;

  PhotoViewerController(int initialPage) : currentPage = initialPage.obs;
}
