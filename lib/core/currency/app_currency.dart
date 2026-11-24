class AppCurrency {
  const AppCurrency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.locale,
    this.decimalDigits = 2,
  });

  final String code;
  final String name;
  final String symbol;
  final String locale;
  final int decimalDigits;

  String get label => '$code · $name';
}

abstract final class AppCurrencies {
  static const AppCurrency usd = AppCurrency(
    code: 'USD',
    name: 'US Dollar',
    symbol: r'$',
    locale: 'en_US',
  );
  static const AppCurrency eur = AppCurrency(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    locale: 'de_DE',
  );
  static const AppCurrency gbp = AppCurrency(
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
    locale: 'en_GB',
  );
  static const AppCurrency inr = AppCurrency(
    code: 'INR',
    name: 'Indian Rupee',
    symbol: '₹',
    locale: 'en_IN',
  );
  static const AppCurrency jpy = AppCurrency(
    code: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
    locale: 'ja_JP',
    decimalDigits: 0,
  );
  static const AppCurrency cny = AppCurrency(
    code: 'CNY',
    name: 'Chinese Yuan',
    symbol: '¥',
    locale: 'zh_CN',
  );
  static const AppCurrency aud = AppCurrency(
    code: 'AUD',
    name: 'Australian Dollar',
    symbol: r'A$',
    locale: 'en_AU',
  );
  static const AppCurrency cad = AppCurrency(
    code: 'CAD',
    name: 'Canadian Dollar',
    symbol: r'C$',
    locale: 'en_CA',
  );
  static const AppCurrency chf = AppCurrency(
    code: 'CHF',
    name: 'Swiss Franc',
    symbol: 'CHF',
    locale: 'de_CH',
  );
  static const AppCurrency sgd = AppCurrency(
    code: 'SGD',
    name: 'Singapore Dollar',
    symbol: r'S$',
    locale: 'en_SG',
  );
  static const AppCurrency aed = AppCurrency(
    code: 'AED',
    name: 'UAE Dirham',
    symbol: 'AED',
    locale: 'en_US',
  );
  static const AppCurrency sar = AppCurrency(
    code: 'SAR',
    name: 'Saudi Riyal',
    symbol: 'SAR',
    locale: 'en_US',
  );
  static const AppCurrency brl = AppCurrency(
    code: 'BRL',
    name: 'Brazilian Real',
    symbol: r'R$',
    locale: 'pt_BR',
  );
  static const AppCurrency zar = AppCurrency(
    code: 'ZAR',
    name: 'South African Rand',
    symbol: 'R',
    locale: 'en_ZA',
  );
  static const AppCurrency mxn = AppCurrency(
    code: 'MXN',
    name: 'Mexican Peso',
    symbol: r'MX$',
    locale: 'es_MX',
  );
  static const AppCurrency krw = AppCurrency(
    code: 'KRW',
    name: 'South Korean Won',
    symbol: '₩',
    locale: 'ko_KR',
    decimalDigits: 0,
  );
  static const AppCurrency nzd = AppCurrency(
    code: 'NZD',
    name: 'New Zealand Dollar',
    symbol: r'NZ$',
    locale: 'en_NZ',
  );
  static const AppCurrency sek = AppCurrency(
    code: 'SEK',
    name: 'Swedish Krona',
    symbol: 'kr',
    locale: 'sv_SE',
  );
  static const AppCurrency nok = AppCurrency(
    code: 'NOK',
    name: 'Norwegian Krone',
    symbol: 'kr',
    locale: 'nb_NO',
  );
  static const AppCurrency dkk = AppCurrency(
    code: 'DKK',
    name: 'Danish Krone',
    symbol: 'kr',
    locale: 'da_DK',
  );
  static const AppCurrency pln = AppCurrency(
    code: 'PLN',
    name: 'Polish Zloty',
    symbol: 'zł',
    locale: 'pl_PL',
  );
  static const AppCurrency tryCurrency = AppCurrency(
    code: 'TRY',
    name: 'Turkish Lira',
    symbol: '₺',
    locale: 'tr_TR',
  );
  static const AppCurrency ngn = AppCurrency(
    code: 'NGN',
    name: 'Nigerian Naira',
    symbol: '₦',
    locale: 'en_NG',
  );
  static const AppCurrency kes = AppCurrency(
    code: 'KES',
    name: 'Kenyan Shilling',
    symbol: 'KSh',
    locale: 'en_KE',
  );
  static const AppCurrency php = AppCurrency(
    code: 'PHP',
    name: 'Philippine Peso',
    symbol: '₱',
    locale: 'en_PH',
  );
  static const AppCurrency idr = AppCurrency(
    code: 'IDR',
    name: 'Indonesian Rupiah',
    symbol: 'Rp',
    locale: 'id_ID',
    decimalDigits: 0,
  );
  static const AppCurrency myr = AppCurrency(
    code: 'MYR',
    name: 'Malaysian Ringgit',
    symbol: 'RM',
    locale: 'ms_MY',
  );
  static const AppCurrency thb = AppCurrency(
    code: 'THB',
    name: 'Thai Baht',
    symbol: '฿',
    locale: 'th_TH',
  );
  static const AppCurrency vnd = AppCurrency(
    code: 'VND',
    name: 'Vietnamese Dong',
    symbol: '₫',
    locale: 'vi_VN',
    decimalDigits: 0,
  );
  static const AppCurrency pkr = AppCurrency(
    code: 'PKR',
    name: 'Pakistani Rupee',
    symbol: '₨',
    locale: 'en_US',
  );
  static const AppCurrency bdt = AppCurrency(
    code: 'BDT',
    name: 'Bangladeshi Taka',
    symbol: '৳',
    locale: 'en_US',
  );
  static const AppCurrency lkr = AppCurrency(
    code: 'LKR',
    name: 'Sri Lankan Rupee',
    symbol: 'Rs',
    locale: 'en_US',
  );
  static const AppCurrency npr = AppCurrency(
    code: 'NPR',
    name: 'Nepalese Rupee',
    symbol: 'Rs',
    locale: 'en_US',
  );

  static const List<AppCurrency> all = <AppCurrency>[
    usd,
    eur,
    gbp,
    inr,
    jpy,
    cny,
    aud,
    cad,
    chf,
    sgd,
    aed,
    sar,
    brl,
    zar,
    mxn,
    krw,
    nzd,
    sek,
    nok,
    dkk,
    pln,
    tryCurrency,
    ngn,
    kes,
    php,
    idr,
    myr,
    thb,
    vnd,
    pkr,
    bdt,
    lkr,
    npr,
  ];

  static AppCurrency? byCode(String? code) {
    if (code == null) return null;
    for (final AppCurrency currency in all) {
      if (currency.code == code) return currency;
    }
    return null;
  }
}
