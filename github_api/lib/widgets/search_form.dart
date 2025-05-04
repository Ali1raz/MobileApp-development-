import 'package:flutter/material.dart';

class SearchForm extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final GlobalKey<FormState> formKey;

  const SearchForm({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: "Username"),
            controller: controller,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your Github username here.";
              }
              return null;
            },
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                controller.text.trim();
                if (formKey.currentState!.validate()) {
                  onSearch();
                }
              },
              child: const Text('Search'),
            ),
          ),
        ],
      ),
    );
  }
} 