// lib/core/constants/currency_catalog.dart
/// Catálogo centralizado de monedas para Latinoamérica y otras comunes.
///
/// Incluye código ISO 4217, nombre, símbolo, locale y decimales.
class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;
  final String locale;
  final int decimalDigits;
  final String? countryCode;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.locale,
    required this.decimalDigits,
    this.countryCode,
  });
}

/// Catálogo de monedas disponibles en la aplicación.
/// Incluye todas las monedas relevantes de Latinoamérica (Sudamérica,
/// Centroamérica, Caribe) más USD y EUR.
class CurrencyCatalog {
  static const List<CurrencyInfo> all = [
    // ============ SUDAMÉRICA ============
    // Peso Argentino
    CurrencyInfo(
      code: 'ARS',
      name: 'Peso Argentino',
      symbol: r'$',
      locale: 'es_AR',
      decimalDigits: 2,
      countryCode: 'AR',
    ),
    // Real Brasileño
    CurrencyInfo(
      code: 'BRL',
      name: 'Real Brasileño',
      symbol: r'R$',
      locale: 'pt_BR',
      decimalDigits: 2,
      countryCode: 'BR',
    ),
    // Peso Chileno
    CurrencyInfo(
      code: 'CLP',
      name: 'Peso Chileno',
      symbol: r'CLP$',
      locale: 'es_CL',
      decimalDigits: 0,
      countryCode: 'CL',
    ),
    // Peso Colombiano
    CurrencyInfo(
      code: 'COP',
      name: 'Peso Colombiano',
      symbol: r'COP$',
      locale: 'es_CO',
      decimalDigits: 0,
      countryCode: 'CO',
    ),
    // Sol Peruano
    CurrencyInfo(
      code: 'PEN',
      name: 'Sol Peruano',
      symbol: 'S/',
      locale: 'es_PE',
      decimalDigits: 2,
      countryCode: 'PE',
    ),
    // Peso Uruguayo
    CurrencyInfo(
      code: 'UYU',
      name: 'Peso Uruguayo',
      symbol: r'$U',
      locale: 'es_UY',
      decimalDigits: 2,
      countryCode: 'UY',
    ),
    // Bolívar Venezolano
    CurrencyInfo(
      code: 'VES',
      name: 'Bolívar Venezolano',
      symbol: 'Bs.S',
      locale: 'es_VE',
      decimalDigits: 2,
      countryCode: 'VE',
    ),
    // Guaraní Paraguayo
    CurrencyInfo(
      code: 'PYG',
      name: 'Guaraní Paraguayo',
      symbol: '₲',
      locale: 'es_PY',
      decimalDigits: 0,
      countryCode: 'PY',
    ),
    // Bolívar Boliviano (BOB)
    CurrencyInfo(
      code: 'BOB',
      name: 'Bolívar Boliviano',
      symbol: 'Bs.',
      locale: 'es_BO',
      decimalDigits: 2,
      countryCode: 'BO',
    ),
    // Peso Dominicano (DOP)
    CurrencyInfo(
      code: 'DOP',
      name: 'Peso Dominicano',
      symbol: r'RD$',
      locale: 'es_DO',
      decimalDigits: 2,
      countryCode: 'DO',
    ),
    // ============ CENTROAMÉRICA ============
    // Peso Mexicano
    CurrencyInfo(
      code: 'MXN',
      name: 'Peso Mexicano',
      symbol: r'MX$',
      locale: 'es_MX',
      decimalDigits: 2,
      countryCode: 'MX',
    ),
    // Quetzal Guatemalteco (GTQ)
    CurrencyInfo(
      code: 'GTQ',
      name: 'Quetzal Guatemalteco',
      symbol: 'Q',
      locale: 'es_GT',
      decimalDigits: 2,
      countryCode: 'GT',
    ),
    // Colón Costarricense (CRC)
    CurrencyInfo(
      code: 'CRC',
      name: 'Colón Costarricense',
      symbol: '₡',
      locale: 'es_CR',
      decimalDigits: 2,
      countryCode: 'CR',
    ),
    // Colón Salvadoreño (SVC) - Dólar también es curso legal
    CurrencyInfo(
      code: 'SVC',
      name: 'Colón Salvadoreño',
      symbol: r'$',
      locale: 'es_SV',
      decimalDigits: 2,
      countryCode: 'SV',
    ),
    // Lempira Hondureño (HNL)
    CurrencyInfo(
      code: 'HNL',
      name: 'Lempira Hondureño',
      symbol: 'L',
      locale: 'es_HN',
      decimalDigits: 2,
      countryCode: 'HN',
    ),
    // Córdoba Nicaragüense (NIO)
    CurrencyInfo(
      code: 'NIO',
      name: 'Córdoba Nicaragüense',
      symbol: r'C$',
      locale: 'es_NI',
      decimalDigits: 2,
      countryCode: 'NI',
    ),
    // Balboa Panameño (PAB) - Dólar también es curso legal
    CurrencyInfo(
      code: 'PAB',
      name: 'Balboa Panameño',
      symbol: 'B/.',
      locale: 'es_PA',
      decimalDigits: 2,
      countryCode: 'PA',
    ),
    // ============ CARIBE & OTROS ============
    // Peso Cubano (CUP)
    CurrencyInfo(
      code: 'CUP',
      name: 'Peso Cubano',
      symbol: r'₱',
      locale: 'es_CU',
      decimalDigits: 2,
      countryCode: 'CU',
    ),
    // Dólar Estadounidense (común en la región)
    CurrencyInfo(
      code: 'USD',
      name: 'Dólar Estadounidense',
      symbol: r'US$',
      locale: 'en_US',
      decimalDigits: 2,
      countryCode: 'US',
    ),
    // Euro
    CurrencyInfo(
      code: 'EUR',
      name: 'Euro',
      symbol: r'€',
      locale: 'de_DE',
      decimalDigits: 2,
      countryCode: 'EU',
    ),
  ];

  /// Obtiene una moneda por su código.
  static CurrencyInfo? getByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene el símbolo de una moneda por su código.
  static String getSymbol(String code) {
    return getByCode(code)?.symbol ?? r'$';
  }

  /// Obtiene el nombre de una moneda por su código.
  static String getName(String code) {
    return getByCode(code)?.name ?? code;
  }

  /// Obtiene los decimales de una moneda por su código.
  static int getDecimalDigits(String code) {
    return getByCode(code)?.decimalDigits ?? 2;
  }

  /// Obtiene el locale de una moneda por su código.
  static String getLocale(String code) {
    return getByCode(code)?.locale ?? 'en_US';
  }

  /// Lista de monedas para mostrar en selectors (code + name).
  static List<CurrencyInfo> get forSelector => all;

  /// Obtiene la moneda por defecto.
  static CurrencyInfo get defaultCurrency => getByCode('ARS')!;
}
