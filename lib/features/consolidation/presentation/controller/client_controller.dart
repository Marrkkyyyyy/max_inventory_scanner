// file: lib/features/consolidation/presentation/controller/client_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/services/client_service.dart';

class ClientController extends GetxController {
  final ClientService clientService;
  final TextEditingController clientNameController = TextEditingController();

  // Observable variables
  final RxBool isWarningVisible = false.obs;
  final RxBool isTextFieldFocused = false.obs;
  final RxBool showSuggestions = true.obs;
  final RxList<String> clientSuggestions = <String>[].obs;
  final RxBool isClientNameValid = true.obs;
  final RxString clientNameError = ''.obs;
  final RxBool isNameInClientList = true.obs;
  final RxString nameNotInListWarning = ''.obs;

  ClientController(this.clientService);

  @override
  void onInit() {
    super.onInit();
    clientService.loadClients();
    clientNameController.addListener(onClientNameChanged);
  }

  @override
  void onClose() {
    clientNameController.removeListener(onClientNameChanged);
    clientNameController.dispose();
    super.onClose();
  }

  void onClientNameChanged() {
    final query = clientNameController.text.trim();
    clientSuggestions.value = query.isEmpty ? [] : clientService.getSuggestions(query);
    showSuggestions.value = isTextFieldFocused.value && clientSuggestions.isNotEmpty;

    isNameInClientList.value = clientService.isExactMatch(query);
    if (!isNameInClientList.value && query.isNotEmpty) {
      nameNotInListWarning.value = 'Name not in client list. Verify or continue if it\'s a new client.';
      isWarningVisible.value = false;
    } else {
      nameNotInListWarning.value = '';
      isWarningVisible.value = false;
    }

    validateClientName();
  }

  bool validateClientName() {
    final name = clientNameController.text.trim();
    isClientNameValid.value = name.isNotEmpty;
    clientNameError.value = isClientNameValid.value ? '' : 'Client name is required';

    if (name.isNotEmpty && !clientService.isExactMatch(name)) {
      nameNotInListWarning.value = 'Name not in client list. Verify or continue if it\'s a new client.';
      isWarningVisible.value = !isTextFieldFocused.value;
    } else {
      nameNotInListWarning.value = '';
      isWarningVisible.value = false;
    }

    update();
    return isClientNameValid.value;
  }

  void onClientNameFocusChanged(bool hasFocus) {
    isTextFieldFocused.value = hasFocus;
    if (!hasFocus) {
      validateClientName();
    }
    update();
  }

  void selectClientName(String name) {
    clientNameController.text = name;
    showSuggestions.value = false;
    isTextFieldFocused.value = false;
    validateClientName();
    update();
  }
}