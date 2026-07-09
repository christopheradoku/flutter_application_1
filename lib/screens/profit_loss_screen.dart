import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  String _selectedTab = 'overview';

  final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
  final List<int> revenue = [3200, 3800, 4100, 3900, 4400, 4800, 5100];
  final List<int> costs = [2600, 3100, 3200, 3400, 3600, 3700, 3860];
  
  final List<Map<String, dynamic>> incomeItems = [
    {'name': 'Egg Sales', 'amount': 3840, 'color': const Color(0xFF7A9A00)},
    {'name': 'Broiler Sales', 'amount': 1260, 'color': const Color(0xFF3A9A50)},
  ];
  
  final List<Map<String, dynamic>> expenseItems = [
    {'name': 'Feed Cost', 'amount': 2100, 'color': const Color(0xFFE05050)},
    {'name': 'Medications', 'amount': 480, 'color': const Color(0xFFE08050)},
    {'name': 'Labour', 'amount': 720, 'color': const Color(0xFFC03030)},
    {'name': 'Utilities', 'amount': 560, 'color': const Color(0xFFA02020)},
  ];

  @override
  Widget build(BuildContext context) {
    final List<int> profit = List.generate(revenue.length, (i) => revenue[i] - costs[i]);
    final int maxVal = revenue.reduce(max);
    final int maxProfit = profit.reduce(max);
    
    final int totalRevenue = incomeItems.fold(0, (s, i) => s + (i['amount'] as int));
    final int totalCost = expenseItems.fold(0, (s, i) => s + (i['amount'] as int));
    final int net = totalRevenue - totalCost;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profit / Loss', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                Text('Financial overview · July 2026', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
              ],
            ),
          ),

          // Net Profit Hero
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0x263A9A50), // Green tint
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x593A9A50), width: 1.5),
                  boxShadow: const [BoxShadow(color: Color(0x1A3A9A50), blurRadius: 32, offset: Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    const Text('Net This Month', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0x8C3C320A))),
                    const SizedBox(height: 4),
                    Text(
                      '${net >= 0 ? '+' : '-'}\$${net.abs()}', 
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: net >= 0 ? const Color(0xFF3A9A50) : const Color(0xFFE05050), letterSpacing: -1)
                    ),
                    const Text('Profit', style: TextStyle(fontSize: 14, color: Color(0x803C320A))),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text('\$$totalRevenue', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3A9A50))),
                            const Text('Revenue', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
                          ],
                        ),
                        Container(width: 1, height: 30, color: Colors.black12, margin: const EdgeInsets.symmetric(horizontal: 24)),
                        Column(
                          children: [
                            Text('\$$totalCost', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE05050))),
                            const Text('Expenses', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tab Toggle
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildTabButton('overview', 'Monthly Trend'),
                _buildTabButton('detail', 'Breakdown'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab Content
          if (_selectedTab == 'overview') ...[
            _buildGlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Revenue vs Costs', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                  const SizedBox(height: 12),
                  // Dual Bar Chart
                  SizedBox(
                    height: 96,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(months.length, (i) {
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: (revenue[i] / maxVal) * 96,
                                        margin: const EdgeInsets.only(right: 1),
                                        decoration: const BoxDecoration(
                                          color: Color(0x993A9A50),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: (costs[i] / maxVal) * 96,
                                        margin: const EdgeInsets.only(left: 1),
                                        decoration: const BoxDecoration(
                                          color: Color(0x73E05050),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(months[i], style: const TextStyle(fontSize: 9, color: Color(0x663C320A))),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xB33A9A50), borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 4),
                      const Text('Revenue', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
                      const SizedBox(width: 16),
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0x80E05050), borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 4),
                      const Text('Costs', style: TextStyle(fontSize: 12, color: Color(0x803C320A))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  
                  // Net Profit Trend
                  const Text('Net Profit Trend', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2A2000))),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: profit.map((p) => Expanded(
                        child: Container(
                          height: (p / maxProfit) * 44,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: p >= 0 ? const Color(0xB33A9A50) : const Color(0x99E05050),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                          ),
                        ),
                      )).toList(),
                    ),
                  )
                ],
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
                      Row(
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: item['color'], shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(item['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2A2000))),
                        ],
                      ),
                      Text('+\$${item['amount']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: item['color'])),
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
                      Row(
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: item['color'], shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(item['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2A2000))),
                        ],
                      ),
                      Text('-\$${item['amount']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: item['color'])),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ],
          const SizedBox(height: 16),

          // Action Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3A9A50), Color(0xFF2A7A40)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Color(0x663A9A50), blurRadius: 16, offset: Offset(0, 4))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('+ Add Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF2A2000) : const Color(0x733C320A),
              ),
            ),
          ),
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