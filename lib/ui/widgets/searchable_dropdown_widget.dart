import 'package:flutter/material.dart';

SearchableDropdown({
  required String label,
  required String? value,
  required List<String> items,
  required Function(String?) onChanged,
}) {
  return Autocomplete<String>(
    optionsBuilder: (TextEditingValue textEditingValue) {
      if (textEditingValue.text == '') {
        return items;
      }
      return items.where((String option) {
        return option.toLowerCase().contains(
          textEditingValue.text.toLowerCase(),
        );
      });
    },
    onSelected: onChanged,
    fieldViewBuilder: (context,
        textEditingController,
        focusNode,
        onFieldSubmitted,) {
      return TextField(
        controller: textEditingController,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: () {
              // Show all options when dropdown icon is clicked
              textEditingController.clear();
              focusNode.requestFocus();
            },
          ),
        ),
      );
    },
    optionsViewBuilder: (context, onSelected, options) {
      return Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options.elementAt(index);
                return InkWell(
                  onTap: () {
                    onSelected(option);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(option),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}