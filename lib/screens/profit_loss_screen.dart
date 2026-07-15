import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm_models.dart';
import '../widgets/form_sheet.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  String _selectedTab = 'overview';

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>();
    if (farm.isLoading) return const Center(child: CircularProgressIndicator());

    final totalRevenue = farm.totalRevenue;
    final totalCost = farm.totalExpenses;
    final net = farm.netProfit;
    final incomeItems = farm.incomeItems;
    final expenseItems = farm.expenseItems;
    final itemColors = {
      'Egg Sales': const Color(0xFF7A9A00),
      'Broiler Sales': const Color(0xFF3A9A50),
      'Feed Cost': const Color(0xFFE05050),
      'Medications': const Color(0xFFE08050),
      'Labour': const Color(0xFFC03030),
      'Utilities': const Color(0xFFA02020),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profit / Loss', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                Text('Financial overview', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0x263A9A50),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x593A9A50), width: 1.5),
                  boxShadow: const [BoxShadow(color: Color(0x1A3A9A50), blurRadius: 32, offset: Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    const Text('Net This Month', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x8C3C320A))),
                    const SizedBox(height: 4),
                    Text(
                      '${net >= 0 ? '+' : '-'}GH₵${net.abs().toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: net >= 0 ? const Color(0xFF3A9A50) : const Color(0xFFE05050), letterSpacing: -1),
                    ),
                    const Text('Profit', style: TextStyle(fontSize: 14, color: Color(0x803C320A))),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(children: [
                          Text('GH₵${totalRevenue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3A9A50))),
                          const Text('Revenue', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
                        ]),
                        Container(width: 1, height: 30, color: Colors.black12, margin: const EdgeInsets.symmetric(horizontal: 24)),
                        Column(children: [
                          Text('GH₵${totalCost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE05050))),
                          const Text('Expenses', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(4),
            child: Row(children: [_buildTabButton('overview', 'Monthly Trend'), _buildTabButton('detail', 'Breakdown')]),
          ),
          const SizedBox(height: 16),
          if (_selectedTab == 'overview') ...[
            _buildGlassContainer(
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Monthly trend needs a backend aggregate endpoint\n(fetchMonthlyTotals) — see TODO in code.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0x803C320A)),
                  ),
                ),
              ),
            ),
          ] else ...[
            const Text('INCOME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0x733C320A), letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Column(
              children: incomeItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildGlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: itemColors[item.category] ?? Colors.grey, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(item.category, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2A2000))),
                          ]),
                          Text('+GH₵${item.amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: itemColors[item.category] ?? Colors.grey)),
                        ],
                      ),
                    ),
                  )).toList(),
            ),
            const SizedBox(height: 4),
            const Text('EXPENSES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0x733C320A), letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Column(
              children: expenseItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildGlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Container(width: 12, height: 12, decoration: BoxDecoration(color: itemColors[item.category] ?? Colors.grey, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text(item.category, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2A2000))),
                          ]),
                          Text('-GH₵${item.amount.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: itemColors[item.category] ?? Colors.grey)),
                        ],
                      ),
                    ),
                  )).toList(),
            ),
          ],
          const SizedBox(height: 16),
          FarmPrimaryButton(
            label: '+ Add Transaction',
            colors: const [Color(0xFF3A9A50), Color(0xFF2A7A40)],
            onPressed: () => _openAddTransactionSheet(context),
          ),
        ],
      ),
    );
  }

  void _openAddTransactionSheet(BuildContext context) {
    final categoryCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    TransactionType type = TransactionType.expense;

    showFarmFormSheet(
      context: context,
      title: 'Add Transaction',
      builder: (ctx, setModalState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: RadioListTile<TransactionType>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Income'),
                    value: TransactionType.income,
                    groupValue: type,
                    onChanged: (v) => setModalState(() => type = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<TransactionType>(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Expense'),
                    value: TransactionType.expense,
                    groupValue: type,
                    onChanged: (v) => setModalState(() => type = v!),
                  ),
                ),
              ],
            ),
            TextField(
              controller: categoryCtrl,
              decoration: InputDecoration(
                labelText: 'Category (e.g. Egg Sales, Feed Cost)',
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.04),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            FarmNumberField(label: 'Amount', controller: amountCtrl, suffix: 'GH₵'),
            const SizedBox(height: 8),
            FarmPrimaryButton(
              label: 'Save Transaction',
              colors: const [Color(0xFF3A9A50), Color(0xFF2A7A40)],
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text);
                if (amount == null || amount <= 0 || categoryCtrl.text.trim().isEmpty) return;
                await context.read<FarmProvider>().addTransaction(category: categoryCtrl.text.trim(), amount: amount, type: type);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabButton(String tabValue, String label) {
    final isActive = _selectedTab == tabValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tabValue),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withValues(alpha: 0.7) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive ? [const BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))] : [],
          ),
          child: Center(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF2A2000) : const Color(0x733C320A)))),
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(20)}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
            boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 32, offset: Offset(0, 8))],
          ),
          child: child,
        ),
      ),
    );
  }
}