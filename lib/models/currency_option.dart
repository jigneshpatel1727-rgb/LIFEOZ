class CurrencyOption {
  final String code;
  final String symbol;
  final String name;

  const CurrencyOption({
    required this.code,
    required this.symbol,
    required this.name,
  });

  String get label => '$name ($code $symbol)';
}

/// Curated common currencies for LifeOS profile setup.
/// Country and currency are deliberately independent selections.
const lifeOsCurrencies = <CurrencyOption>[
  CurrencyOption(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
  CurrencyOption(code: 'USD', symbol: r'$', name: 'US Dollar'),
  CurrencyOption(code: 'EUR', symbol: '€', name: 'Euro'),
  CurrencyOption(code: 'GBP', symbol: '£', name: 'British Pound'),
  CurrencyOption(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
  CurrencyOption(code: 'SAR', symbol: '﷼', name: 'Saudi Riyal'),
  CurrencyOption(code: 'QAR', symbol: '﷼', name: 'Qatari Riyal'),
  CurrencyOption(code: 'KWD', symbol: 'د.ك', name: 'Kuwaiti Dinar'),
  CurrencyOption(code: 'SGD', symbol: r'S$', name: 'Singapore Dollar'),
  CurrencyOption(code: 'AUD', symbol: r'A$', name: 'Australian Dollar'),
  CurrencyOption(code: 'CAD', symbol: r'C$', name: 'Canadian Dollar'),
  CurrencyOption(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
  CurrencyOption(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
  CurrencyOption(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc'),
  CurrencyOption(code: 'NZD', symbol: r'NZ$', name: 'New Zealand Dollar'),
  CurrencyOption(code: 'ZAR', symbol: 'R', name: 'South African Rand'),
];

CurrencyOption currencyByCode(String code) {
  for (final option in lifeOsCurrencies) {
    if (option.code == code) return option;
  }
  return lifeOsCurrencies.first;
}
