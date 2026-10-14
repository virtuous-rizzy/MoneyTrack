class Account {
  final int id;
  final String name;
  final String bank;
  final int openingBalance;

  const Account({
    required this.id,
    required this.name,
    required this.bank,
    required this.openingBalance,
  });

  factory Account.fromMap(Map<String, Object?> m) => Account(
        id: m['id'] as int,
        name: m['name'] as String,
        bank: m['bank'] as String,
        openingBalance: (m['opening_balance'] as num).toInt(),
      );
}

class TxCategory {
  final int id;
  final String name;
  final String iconKey;
  final String type; // 'expense' atau 'income'

  const TxCategory({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.type,
  });

  factory TxCategory.fromMap(Map<String, Object?> m) => TxCategory(
        id: m['id'] as int,
        name: m['name'] as String,
        iconKey: m['icon_key'] as String,
        type: m['type'] as String,
      );
}

class TransactionItem {
  final int id;
  final String title;
  final int amount;
  final String type; // 'expense' atau 'income'
  final int categoryId;
  final String categoryName;
  final String iconKey;
  final String method;
  final DateTime createdAt;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.iconKey,
    required this.method,
    required this.createdAt,
  });

  bool get isIncome => type == 'income';

  factory TransactionItem.fromMap(Map<String, Object?> m) => TransactionItem(
        id: m['id'] as int,
        title: m['title'] as String,
        amount: (m['amount'] as num).toInt(),
        type: m['type'] as String,
        categoryId: m['category_id'] as int,
        categoryName: m['category_name'] as String,
        iconKey: m['icon_key'] as String,
        method: m['method'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch((m['created_at'] as num).toInt()),
      );
}

class Totals {
  final int income;
  final int expense;
  final int incomeCount;
  final int expenseCount;

  const Totals({
    this.income = 0,
    this.expense = 0,
    this.incomeCount = 0,
    this.expenseCount = 0,
  });
}
