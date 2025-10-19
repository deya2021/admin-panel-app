import 'package:flutter/material.dart';

class RedemptionFormSheet extends StatefulWidget {
  const RedemptionFormSheet({super.key});

  @override
  State<RedemptionFormSheet> createState() => _RedemptionFormSheetState();
}

class _RedemptionFormSheetState extends State<RedemptionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _pointsCtrl = TextEditingController();

  @override
  void dispose() {
    _pointsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Material(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Form(
            key: _formKey,
            child: Wrap(
              runSpacing: 12,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Redeem Points',
                    style: Theme.of(context).textTheme.titleLarge),
                TextFormField(
                  controller: _pointsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Points to redeem',
                    hintText: 'e.g. 100',
                    prefixIcon: Icon(Icons.star),
                  ),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n <= 0) return 'Enter a positive number';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState?.validate() != true) return;
                        final n = int.parse(_pointsCtrl.text.trim());
                        Navigator.pop<int>(context, n);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
