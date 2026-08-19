import 'package:flutter_test/flutter_test.dart';
import 'package:personal_super_app/domain/models/budget.dart';
import 'package:personal_super_app/domain/models/goal.dart';
import 'package:personal_super_app/domain/models/investment.dart';

void main() {
  group('Budget.fromJson', () {
    test('parses full budget', () {
      final budget = Budget.fromJson({
        'id': 'b1',
        'categoryId': 'c1',
        'amount': '500000',
        'period': 'monthly',
        'startDate': '2026-08-01',
        'endDate': '2026-08-31',
        'alertThreshold': '80',
        'isActive': true,
        'createdAt': '2026-08-01T00:00:00.000Z',
      });
      expect(budget.id, 'b1');
      expect(budget.amount, '500000');
      expect(budget.period, 'monthly');
      expect(budget.isActive, true);
    });

    test('uses defaults for missing fields', () {
      final budget = Budget.fromJson({
        'id': 'b2',
        'amount': '100000',
        'period': 'weekly',
        'startDate': '2026-08-01',
        'createdAt': '2026-08-01T00:00:00.000Z',
      });
      expect(budget.categoryId, isNull);
      expect(budget.endDate, isNull);
      expect(budget.isActive, true);
    });
  });

  group('SavingGoal.fromJson', () {
    test('parses goal with defaults', () {
      final goal = SavingGoal.fromJson({
        'id': 'g1',
        'name': 'New Laptop',
        'targetAmount': '15000000',
        'createdAt': '2026-08-01T00:00:00.000Z',
        'updatedAt': '2026-08-01T00:00:00.000Z',
      });
      expect(goal.name, 'New Laptop');
      expect(goal.currentAmount, '0');
      expect(goal.color, '#10B981');
      expect(goal.isActive, true);
    });
  });

  group('Investment.fromJson', () {
    test('parses investment with current price', () {
      final inv = Investment.fromJson({
        'id': 'i1',
        'name': 'BBRI',
        'type': 'stock',
        'symbol': 'BBRI',
        'quantity': '100',
        'purchasePrice': '4500',
        'currentPrice': '5000',
        'purchaseDate': '2026-01-15',
        'broker': 'Ajaib',
        'createdAt': '2026-01-15T00:00:00.000Z',
        'updatedAt': '2026-08-01T00:00:00.000Z',
      });
      expect(inv.symbol, 'BBRI');
      expect(inv.currentPrice, '5000');
      expect(inv.broker, 'Ajaib');
    });

    test('parses investment without optional fields', () {
      final inv = Investment.fromJson({
        'id': 'i2',
        'name': 'Reksa Dana',
        'type': 'mutual_fund',
        'quantity': '10',
        'purchasePrice': '100000',
        'purchaseDate': '2026-02-01',
        'createdAt': '2026-02-01T00:00:00.000Z',
        'updatedAt': '2026-02-01T00:00:00.000Z',
      });
      expect(inv.symbol, isNull);
      expect(inv.currentPrice, isNull);
      expect(inv.notes, isNull);
    });
  });
}
