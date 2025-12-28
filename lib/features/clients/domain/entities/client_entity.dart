// -------------------------------------------------------------
// ⚠️ ВАЖНО — НЕ УДАЛЯТЬ
// -------------------------------------------------------------
// Сущность [ClientEntity] хранит все поля, которые серверная
// функция `edit-client` может принять или вернуть. Даже если
// отдельные свойства пока не используются во фронте, они нужны
// для корректного обмена данными с API clients-api. Поэтому
// НЕ удаляйте и не переименовывайте поля без синхронизации со
// спецификацией Gateway-API и Cloud Function.
// -------------------------------------------------------------

import 'package:equatable/equatable.dart';

/// Сущность клиента (компании, обслуживаемой фирмой).
///
/// Для облегчения первой итерации реализованы только основные поля
/// (ID, названия, контакты, дата регистрации и комментарий). Остальные
/// параметры из ТЗ могут быть добавлены позднее без нарушения
/// существующего внешнего интерфейса, т.к. [extra] хранит все
/// необязательные данные.
class ClientEntity extends Equatable {
  final String id;
  final String name;
  final String? shortName;
  final String? inn; // ИНН клиента
  final List<KppInfo> kppInfo; // Информация о КПП
  final List<ContactEntity> contacts;
  final DateTime? creationDate;
  final String? comment;

  // Поля для версионирования
  final DateTime? manualCreationDate; // Дата создания версии
  final bool isActual; // Является ли версия актуальной
  final bool isActive; // Активен ли клиент
  final DateTime? updatedAt; // Дата последнего обновления

  /// Словарь для дополнительных параметров клиента, например типы налогов, НДС и т.д.
  /// Эти поля отражены на бэкенде, но пока не используются напрямую во фронте.
  final Map<String, dynamic>? extra;

  // Типы (списки)
  final List<String>
  fixedContributionsIP; // ТИП фиксированных взносов ИП (необязательно, много)
  final List<int> fixedContributionsPaymentDate; // даты платежа фикс. взносов
  final List<String>
  contributionsIP1Percent; // ТИП взносов ИП 1% (необязательно, много)
  final List<int> contributionsIP1PercentPaymentDate; // даты платежа взносов 1%
  final String? ownershipForm; // ТИП формы собственности (мин 1, макс 1)
  final String?
  directorType; // ТИП руководителя для ООО, КХ, АО (обязательное поле)
  final String? directorName; // ФИО руководителя
  final DateTime? directorStartDate; // Дата начала полномочий руководителя
  final List<String> taxSystems; // ТИП системы налогообложения (обяз, много)
  final List<String>
  profitTaxTypes; // ТИП налога на прибыль (мин 1, множественный)
  final List<String> vatTypes; // ТИП НДС (мин 1, макс 2)
  final List<String> propertyTypes; // ТИП имущества (много)
  final String? reportingType; // ТИП отчётности (мин 1, макс 1)
  final String?
  reportingOperator; // ТИП оператора отчётности (мин 1, макс 1) (СБИС, контур, 1с)
  final List<String> exciseGoods; // ТИП подакцизных товары (много)
  final List<String>
  excisePaymentTerms; // ТИП срок оплаты акциза (мин 1, макс 2)
  final List<String> edoOperators; // ТИП операторы ЭДО (много)
  final String? enpType; // ТИП ЕНП (мин 1, макс 1)
  final List<String> activityTypes; // ТИП виды деятельности (много)
  final String? ndflType; // ТИП НДФЛ (мин 1, макс 1)
  final List<String> additionalTags; // список, доп ТЕГИ (много)

  // Новые поля для расширенной информации о клиенте
  final List<FnsInfo> fnsInfo; // ФНС информация (может быть много)
  final SfrInfo? sfrInfo; // СФР информация
  final String? okpo; // ОКПО (цифровое поле)
  final bool?
  cashOrBank; // касса / банк switch (true = касса, false = банк) - DEPRECATED
  final bool? cashPayment; // выплата через кассу (да/нет)
  final bool? bankPayment; // выплата через банк (да/нет)
  final bool? hasEmployees; // есть сотрудники (да/нет)
  final bool?
  isSoleFounderDirector; // единственный учредитель-директор (да/нет)
  final String? ogrn; // ОГРН для ООО или ОГРНИП для КФХ и ИП
  final String? legalAddress; // Юридический адрес
  final String? actualAddress; // Фактический адрес
  final bool actualAddressSameAsLegal; // Фактический совпадает с юридическим

  // Даты выплат (пары чисел от 1 до 31)
  final PaymentSchedule? salaryPayment; // выплата зарплаты
  final PaymentSchedule? advancePayment; // выплата аванса
  final PaymentSchedule? ndflPayment; // уплата ндфл

  // Патенты
  final List<PatentEntity> patents;

  final bool salaryPaymentEnabled;

  /// Файлы, прикреплённые к клиенту (карточка). Каждый элемент — Map
  /// с ключами `name`, `fileKey`, `fileSize`.
  final List<Map<String, dynamic>> attachments;

  /// Комментарии к вложениям
  final String? attachmentComments;

  /// Срок действия ЭЦП (электронной цифровой подписи)
  final DateTime? digitalSignatureExpiryDate;

  /// Статус "на обслуживании" у версии клиента (true = на обслуживании)
  final bool onService;

  const ClientEntity({
    required this.id,
    required this.name,
    this.inn,
    this.kppInfo = const [],
    this.shortName,
    this.contacts = const [],
    this.creationDate,
    this.comment,
    this.manualCreationDate,
    this.isActual = false,
    this.isActive = true,
    this.updatedAt,
    this.extra,
    this.fixedContributionsIP = const [],
    this.fixedContributionsPaymentDate = const [],
    this.contributionsIP1Percent = const [],
    this.contributionsIP1PercentPaymentDate = const [],
    this.ownershipForm,
    this.directorType,
    this.directorName,
    this.directorStartDate,
    this.taxSystems = const [],
    this.profitTaxTypes = const [],
    this.vatTypes = const [],
    this.propertyTypes = const [],
    this.reportingType,
    this.reportingOperator,
    this.exciseGoods = const [],
    this.excisePaymentTerms = const [],
    this.edoOperators = const [],
    this.enpType,
    this.activityTypes = const [],
    this.ndflType,
    this.additionalTags = const [],
    this.fnsInfo = const [],
    this.sfrInfo,
    this.okpo,
    this.cashOrBank,
    this.cashPayment,
    this.bankPayment,
    this.hasEmployees,
    this.isSoleFounderDirector,
    this.ogrn,
    this.legalAddress,
    this.actualAddress,
    this.actualAddressSameAsLegal = false,
    this.salaryPayment,
    this.salaryPaymentEnabled = false,
    this.advancePayment,
    this.ndflPayment,
    this.patents = const [],
    this.attachments = const [],
    this.attachmentComments,
    this.digitalSignatureExpiryDate,
    this.onService = false,
  });

  ClientEntity copyWith({
    String? id,
    String? name,
    String? shortName,
    String? inn,
    List<KppInfo>? kppInfo,
    List<ContactEntity>? contacts,
    DateTime? creationDate,
    String? comment,
    DateTime? manualCreationDate,
    bool? isActual,
    bool? isActive,
    DateTime? updatedAt,
    Map<String, dynamic>? extra,
    List<String>? fixedContributionsIP,
    List<int>? fixedContributionsPaymentDate,
    List<String>? contributionsIP1Percent,
    List<int>? contributionsIP1PercentPaymentDate,
    String? ownershipForm,
    String? directorType,
    String? directorName,
    DateTime? directorStartDate,
    List<String>? taxSystems,
    List<String>? profitTaxTypes,
    List<String>? vatTypes,
    List<String>? propertyTypes,
    String? reportingType,
    String? reportingOperator,
    List<String>? exciseGoods,
    List<String>? excisePaymentTerms,
    List<String>? edoOperators,
    String? enpType,
    List<String>? activityTypes,
    String? ndflType,
    List<String>? additionalTags,
    List<FnsInfo>? fnsInfo,
    SfrInfo? sfrInfo,
    String? okpo,
    bool? cashOrBank,
    bool? cashPayment,
    bool? bankPayment,
    bool? hasEmployees,
    bool? isSoleFounderDirector,
    String? ogrn,
    String? legalAddress,
    String? actualAddress,
    bool? actualAddressSameAsLegal,
    PaymentSchedule? salaryPayment,
    bool? salaryPaymentEnabled,
    PaymentSchedule? advancePayment,
    PaymentSchedule? ndflPayment,
    List<PatentEntity>? patents,
    List<Map<String, dynamic>>? attachments,
    String? attachmentComments,
    DateTime? digitalSignatureExpiryDate,
    bool? onService,
  }) {
    return ClientEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      inn: inn ?? this.inn,
      kppInfo: kppInfo ?? this.kppInfo,
      contacts: contacts ?? this.contacts,
      creationDate: creationDate ?? this.creationDate,
      comment: comment ?? this.comment,
      manualCreationDate: manualCreationDate ?? this.manualCreationDate,
      isActual: isActual ?? this.isActual,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      extra: extra ?? this.extra,
      fixedContributionsIP: fixedContributionsIP ?? this.fixedContributionsIP,
      fixedContributionsPaymentDate:
          fixedContributionsPaymentDate ?? this.fixedContributionsPaymentDate,
      contributionsIP1Percent:
          contributionsIP1Percent ?? this.contributionsIP1Percent,
      contributionsIP1PercentPaymentDate:
          contributionsIP1PercentPaymentDate ??
          this.contributionsIP1PercentPaymentDate,
      ownershipForm: ownershipForm ?? this.ownershipForm,
      directorType: directorType ?? this.directorType,
      directorName: directorName ?? this.directorName,
      directorStartDate: directorStartDate ?? this.directorStartDate,
      taxSystems: taxSystems ?? this.taxSystems,
      profitTaxTypes: profitTaxTypes ?? this.profitTaxTypes,
      vatTypes: vatTypes ?? this.vatTypes,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      reportingType: reportingType ?? this.reportingType,
      reportingOperator: reportingOperator ?? this.reportingOperator,
      exciseGoods: exciseGoods ?? this.exciseGoods,
      excisePaymentTerms: excisePaymentTerms ?? this.excisePaymentTerms,
      edoOperators: edoOperators ?? this.edoOperators,
      enpType: enpType ?? this.enpType,
      activityTypes: activityTypes ?? this.activityTypes,
      ndflType: ndflType ?? this.ndflType,
      additionalTags: additionalTags ?? this.additionalTags,
      fnsInfo: fnsInfo ?? this.fnsInfo,
      sfrInfo: sfrInfo ?? this.sfrInfo,
      okpo: okpo ?? this.okpo,
      cashOrBank: cashOrBank ?? this.cashOrBank,
      cashPayment: cashPayment ?? this.cashPayment,
      bankPayment: bankPayment ?? this.bankPayment,
      hasEmployees: hasEmployees ?? this.hasEmployees,
      isSoleFounderDirector:
          isSoleFounderDirector ?? this.isSoleFounderDirector,
      ogrn: ogrn ?? this.ogrn,
      legalAddress: legalAddress ?? this.legalAddress,
      actualAddress: actualAddress ?? this.actualAddress,
      actualAddressSameAsLegal:
          actualAddressSameAsLegal ?? this.actualAddressSameAsLegal,
      salaryPayment: salaryPayment ?? this.salaryPayment,
      salaryPaymentEnabled: salaryPaymentEnabled ?? this.salaryPaymentEnabled,
      advancePayment: advancePayment ?? this.advancePayment,
      ndflPayment: ndflPayment ?? this.ndflPayment,
      patents: patents ?? this.patents,
      attachments: attachments ?? this.attachments,
      attachmentComments: attachmentComments ?? this.attachmentComments,
      digitalSignatureExpiryDate:
          digitalSignatureExpiryDate ?? this.digitalSignatureExpiryDate,
      onService: onService ?? this.onService,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    shortName,
    inn,
    kppInfo,
    contacts,
    creationDate,
    comment,
    manualCreationDate,
    isActual,
    isActive,
    updatedAt,
    extra,
    fixedContributionsIP,
    fixedContributionsPaymentDate,
    contributionsIP1Percent,
    contributionsIP1PercentPaymentDate,
    ownershipForm,
    directorType,
    directorName,
    directorStartDate,
    taxSystems,
    profitTaxTypes,
    vatTypes,
    propertyTypes,
    reportingType,
    reportingOperator,
    exciseGoods,
    excisePaymentTerms,
    edoOperators,
    enpType,
    activityTypes,
    ndflType,
    additionalTags,
    fnsInfo,
    sfrInfo,
    okpo,
    cashOrBank,
    cashPayment,
    bankPayment,
    hasEmployees,
    isSoleFounderDirector,
    ogrn,
    legalAddress,
    actualAddress,
    actualAddressSameAsLegal,
    salaryPayment,
    salaryPaymentEnabled,
    advancePayment,
    ndflPayment,
    patents,
    attachments,
    attachmentComments,
    digitalSignatureExpiryDate,
    onService,
  ];
}

/// Упрощённая сущность контакта компании.
class ContactEntity extends Equatable {
  final String? phone;
  final List<String> emails; // Список email адресов
  final String? fullName;
  final Map<String, String>
  communicationMethods; // Дополнительно с их значениями

  const ContactEntity({
    this.phone,
    this.emails = const [],
    this.fullName,
    this.communicationMethods = const {},
  });

  ContactEntity copyWith({
    String? phone,
    List<String>? emails,
    String? fullName,
    Map<String, String>? communicationMethods,
  }) {
    return ContactEntity(
      phone: phone ?? this.phone,
      emails: emails ?? this.emails,
      fullName: fullName ?? this.fullName,
      communicationMethods: communicationMethods ?? this.communicationMethods,
    );
  }

  @override
  List<Object?> get props => [phone, emails, fullName, communicationMethods];
}

/// График платежей (дата + дата переноса).
class PaymentSchedule extends Equatable {
  final int paymentDate; // 1-31
  final int transferDate; // 1-31, для НДФЛ

  const PaymentSchedule({
    required this.paymentDate,
    required this.transferDate,
  });

  PaymentSchedule copyWith({int? paymentDate, int? transferDate}) {
    return PaymentSchedule(
      paymentDate: paymentDate ?? this.paymentDate,
      transferDate: transferDate ?? this.transferDate,
    );
  }

  @override
  List<Object?> get props => [paymentDate, transferDate];
}

/// Патент.
class PatentEntity extends Equatable {
  final DateTime startDate; // дата начала (не изм)
  final DateTime endDate; // дата конца (изм)
  final DateTime issueDate; // дата выдачи (не изм)
  final double patentAmount; // сумма патента (изм)
  final String patentNumber; // номер патента (огромное целое число)
  final String? patentTitle; // название патента
  final String? comment; // комментарий

  final PatentPayment? payment; // оплата патента
  final PatentReduction? reduction; // уменьшение патента
  final DateTime?
  newPatentApplicationDate; // заявление на новый патент - дата задачи

  const PatentEntity({
    required this.startDate,
    required this.endDate,
    required this.issueDate,
    required this.patentAmount,
    required this.patentNumber,
    this.patentTitle,
    this.comment,
    this.payment,
    this.reduction,
    this.newPatentApplicationDate,
  });

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    issueDate,
    patentAmount,
    patentNumber,
    patentTitle,
    comment,
    payment,
    reduction,
    newPatentApplicationDate,
  ];
}

/// Оплата патента.
class PatentPayment extends Equatable {
  final String type; // "произвольно" / "ежемесячно"
  final List<PaymentDate>? customPayments; // если произвольно
  final MonthlyPayment? monthlyPayment; // если ежемесячно

  const PatentPayment({
    required this.type,
    this.customPayments,
    this.monthlyPayment,
  });

  PatentPayment copyWith({
    String? type,
    List<PaymentDate>? customPayments,
    MonthlyPayment? monthlyPayment,
  }) {
    return PatentPayment(
      type: type ?? this.type,
      customPayments: customPayments ?? this.customPayments,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
    );
  }

  @override
  List<Object?> get props => [type, customPayments, monthlyPayment];
}

/// Уменьшение патента.
class PatentReduction extends Equatable {
  final List<PaymentDate>? customReductions; // если произвольно

  const PatentReduction({this.customReductions});

  PatentReduction copyWith({List<PaymentDate>? customReductions}) {
    return PatentReduction(
      customReductions: customReductions ?? this.customReductions,
    );
  }

  @override
  List<Object?> get props => [customReductions];
}

/// Произвольная дата и сумма.
class PaymentDate extends Equatable {
  final DateTime date;
  final double amount;

  const PaymentDate({required this.date, required this.amount});

  @override
  List<Object?> get props => [date, amount];
}

/// Ежемесячная оплата.
class MonthlyPayment extends Equatable {
  final DateTime startDate; // дата начала периода
  final DateTime endDate; // дата конца периода
  final double customAmount; // кастомная сумма
  final List<int> paymentDays; // ДАТЫ оплаты в месяце (числа от 1 до 31)

  const MonthlyPayment({
    required this.startDate,
    required this.endDate,
    required this.customAmount,
    required this.paymentDays,
  });

  MonthlyPayment copyWith({
    DateTime? startDate,
    DateTime? endDate,
    double? customAmount,
    List<int>? paymentDays,
  }) {
    return MonthlyPayment(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      customAmount: customAmount ?? this.customAmount,
      paymentDays: paymentDays ?? this.paymentDays,
    );
  }

  @override
  List<Object?> get props => [startDate, endDate, customAmount, paymentDays];
}

/// Информация о ФНС
class FnsInfo extends Equatable {
  final String code; // 4-значный код
  final String name; // название
  final DateTime date; // дата
  final String oktmo; // 8-значный ОКТМО

  const FnsInfo({
    required this.code,
    required this.name,
    required this.date,
    required this.oktmo,
  });

  @override
  List<Object?> get props => [code, name, date, oktmo];

  FnsInfo copyWith({
    String? code,
    String? name,
    DateTime? date,
    String? oktmo,
  }) {
    return FnsInfo(
      code: code ?? this.code,
      name: name ?? this.name,
      date: date ?? this.date,
      oktmo: oktmo ?? this.oktmo,
    );
  }
}

/// Информация о СФР
class SfrInfo extends Equatable {
  final String number; // 10-значный номер
  final String subordinationCode; // 5-значный код подчинённости

  const SfrInfo({required this.number, required this.subordinationCode});

  @override
  List<Object?> get props => [number, subordinationCode];

  SfrInfo copyWith({String? number, String? subordinationCode}) {
    return SfrInfo(
      number: number ?? this.number,
      subordinationCode: subordinationCode ?? this.subordinationCode,
    );
  }
}

/// Информация о КПП
class KppInfo extends Equatable {
  final String number; // номер КПП
  final DateTime date; // дата

  const KppInfo({required this.number, required this.date});

  @override
  List<Object?> get props => [number, date];

  KppInfo copyWith({String? number, DateTime? date}) {
    return KppInfo(number: number ?? this.number, date: date ?? this.date);
  }
}
