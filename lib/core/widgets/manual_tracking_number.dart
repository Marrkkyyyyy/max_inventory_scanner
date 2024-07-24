import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/color.dart';

class TrackingNumberEntryModal extends StatelessWidget {
  final Function(String) onAdd;
  final TextEditingController textEditingController;
  final RxList<String> trackingSuggestions;
  final RxBool isLoading;
  final Function(String) onSearch;
  final bool showSuggestions;

  TrackingNumberEntryModal({
    super.key,
    required this.onAdd,
    required this.textEditingController,
    required this.trackingSuggestions,
    required this.isLoading,
    required this.onSearch,
    this.showSuggestions = true,
  });

  final RxBool showError = false.obs;
  final RxBool _showSuggestionsLocal = false.obs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _dismissKeyboardAndSuggestions(context),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Tracking Number',
                          style: TextStyle(
                            color: AppColor.darkBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Enter the tracking number of the package you want to add to the inventory.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(context),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () => _handleAddPackage(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Add Package',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColor.blue),
                            backgroundColor: AppColor.white,
                            foregroundColor: AppColor.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (showSuggestions)
                  Obx(() => _showSuggestionsLocal.value
                      ? Positioned(
                          top: 225,
                          left: 24,
                          right: 24,
                          child: Material(
                            elevation: 4.0,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: constraints.maxHeight - 225,
                              ),
                              child: _buildSuggestionsList(context),
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return const SizedBox(
          height: 52,
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (trackingSuggestions.isEmpty &&
          textEditingController.text.isNotEmpty) {
        return GestureDetector(
          onTap: () {
            _showSuggestionsLocal.value = true;
          },
          child: Container(
            height: 52,
            alignment: Alignment.center,
            child: const Text(
              'Tracking number not found',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        );
      } else if (trackingSuggestions.isNotEmpty) {
        return Container(
          color: Colors.white,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: trackingSuggestions.length,
            itemBuilder: (BuildContext context, int index) {
              final String option = trackingSuggestions[index];
              return InkWell(
                onTap: () => _selectSuggestion(context, option),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Text(option),
                ),
              );
            },
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildTextField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tracking Number',
          style: TextStyle(
            color: AppColor.darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: showError.value ? Colors.red : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: textEditingController,
            autofocus: true,
            onChanged: (value) {
              if (showSuggestions && value.isNotEmpty) {
                onSearch(value);
                _showSuggestionsLocal.value = true;
              } else {
                trackingSuggestions.clear();
                _showSuggestionsLocal.value = false;
              }
            },
            decoration: InputDecoration(
              prefixIcon:
                  const Icon(CupertinoIcons.barcode, color: AppColor.blue),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: 'Enter tracking number',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            style: const TextStyle(color: AppColor.darkBlue),
          ),
        ),
        Obx(() => showError.value
            ? const Padding(
                padding: EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  'Please enter a valid tracking number',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  void _dismissKeyboardAndSuggestions(BuildContext context) {
    FocusScope.of(context).unfocus();
    _showSuggestionsLocal.value = false;
  }

  void _selectSuggestion(BuildContext context, String option) {
    textEditingController.text = option;
    trackingSuggestions.clear();
    _showSuggestionsLocal.value = false;
    _dismissKeyboardAndSuggestions(context);
  }

  void _handleAddPackage(BuildContext context) {
    final barcode = textEditingController.text.trim();
    if (barcode.isNotEmpty) {
      showError.value = false;
      _dismissKeyboardAndSuggestions(context);
      onAdd(barcode);
    } else {
      showError.value = true;
    }
  }
}
