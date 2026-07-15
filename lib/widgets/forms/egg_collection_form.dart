import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/farm_provider.dart';
import '../form_sheet.dart';

class EggCollectionForm extends StatefulWidget {
  const EggCollectionForm({super.key});

  @override
  State<EggCollectionForm> createState() => _EggCollectionFormState();
}

class _EggCollectionFormState extends State<EggCollectionForm> {
  final TextEditingController _goodEggsController = TextEditingController();
  final TextEditingController _badEggsController = TextEditingController();

  Future<void> _submitForm() async {
    final int goodEggs = int.tryParse(_goodEggsController.text) ?? 0;
    final int badEggs = int.tryParse(_badEggsController.text) ?? 0;

    if (goodEggs == 0 && badEggs == 0) return;

    // Maps the 2 inputs to the 4 variables your FarmProvider requires
    await context.read<FarmProvider>().addEggCollection(
      gradeA: goodEggs,
      gradeB: 0,
      gradeC: 0,
      cracked: badEggs,
      hensActive: 0,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Egg collection saved securely!'),
          backgroundColor: Color(0xFF7A9A00),
        ),
      );
    }
  }

  @override
  void dispose() {
    _goodEggsController.dispose();
    _badEggsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FarmNumberField(
          label: 'Good Eggs Collected',
          controller: _goodEggsController,
        ),
        FarmNumberField(
          label: 'Damaged or Cracked Eggs',
          controller: _badEggsController,
        ),
        const SizedBox(height: 24),
        FarmPrimaryButton(
          label: 'Save Collection',
          onPressed: _submitForm,
          colors: const [Color(0xFF7A9A00), Color(0xFF526A00)],
        ),
      ],
    );
  }
}
