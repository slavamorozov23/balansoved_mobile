// -------------------------------------------------------------
// ⚠️ ВАЖНО — НЕ УДАЛЯТЬ
// -------------------------------------------------------------
// Этот файл отвечает за маппинг данных клиента между
// слоями приложения и сервером. Формат JSON, формируемый в
// [toJson] и разбираемый в [fromJson], ДОЛЖЕН строго
// соответствовать требованиям API, описанным в документации:
//   • obsidian_balansoved/🔗 gateway-api/🔥 clients-api - Gateway-api Шлюз.md
//   • obsidian_balansoved/𝒇 Функции/✳️👤 edit-client - CloudFunction функция.md
// При изменении серверной спецификации обновляйте эти методы,
// но старайтесь не удалять существующие поля или логику — иначе
// приложение перестанет корректно обмениваться данными.
// -------------------------------------------------------------

import 'dart:convert';
import 'package:balansoved_mobile/core/logging/clients_logger.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/injection_container.dart';
import 'package:talker_flutter/talker_flutter.dart';

class ClientModel extends ClientEntity {
  const ClientModel({
    required super.id,
    required super.name,
    super.inn,
    super.kppInfo = const [],
    super.shortName,
    super.contacts = const [],
    super.creationDate,
    super.comment,
    super.manualCreationDate,
    super.isActual = false,
    super.isActive = true,
    super.updatedAt,
    super.fixedContributionsIP = const [],
    super.fixedContributionsPaymentDate = const [],
    super.contributionsIP1Percent = const [],
    super.contributionsIP1PercentPaymentDate = const [],
    super.ownershipForm,
    super.directorType,
    super.directorName,
    super.directorStartDate,
    super.taxSystems = const [],
    super.profitTaxTypes = const [],
    super.vatTypes = const [],
    super.propertyTypes = const [],
    super.reportingType,
    super.reportingOperator,
    super.exciseGoods = const [],
    super.excisePaymentTerms = const [],
    super.edoOperators = const [],
    super.enpType,
    super.activityTypes = const [],
    super.ndflType,
    super.additionalTags = const [],
    super.fnsInfo = const [],
    super.sfrInfo,
    super.okpo,
    super.cashOrBank,
    super.cashPayment,
    super.bankPayment,
    super.hasEmployees,
    super.isSoleFounderDirector,
    super.ogrn,
    super.legalAddress,
    super.actualAddress,
    super.actualAddressSameAsLegal = false,
    super.salaryPayment,
    super.salaryPaymentEnabled = false,
    super.advancePayment,
    super.ndflPayment,
    super.patents = const [],
    super.attachments = const [],
    super.attachmentComments,
    super.digitalSignatureExpiryDate,
    super.onService = false,
  });

  static DateTime? _parseManualCreationDate(dynamic manualCreationDate) {
    if (manualCreationDate == null) return null;

    try {
      if (manualCreationDate is String && manualCreationDate.isNotEmpty) {
        return DateTime.parse(manualCreationDate);
      } else if (manualCreationDate is int) {
        // Сервер возвращает количество дней с начала эпохи
        return DateTime(1970, 1, 1).add(Duration(days: manualCreationDate));
      }
    } catch (_) {
      // Если парсинг не удался, возвращаем null
    }

    return null;
  }

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    try {
      // Helper to safely parse a JSON string field
      Map<String, dynamic> parseJsonString(String? jsonString) {
        if (jsonString == null || jsonString.isEmpty) return {};
        try {
          return jsonDecode(jsonString) as Map<String, dynamic>;
        } catch (e) {
          sl<Talker>().error('ERROR parsing JSON string: $e');
          sl<Talker>().logCustom(ClientsLog('JSON string value: $jsonString'));
          return {};
        }
      }

      List<dynamic> parseJsonStringList(String? jsonString) {
        if (jsonString == null || jsonString.isEmpty) return [];
        try {
          return jsonDecode(jsonString) as List<dynamic>;
        } catch (e) {
          sl<Talker>().error('ERROR parsing JSON string list: $e');
          sl<Talker>().logCustom(ClientsLog('JSON string value: $jsonString'));
          return [];
        }
      }

      // Безопасный парсинг списка строк из разных типов данных
      List<String> parseStringList(dynamic value, String fieldName) {
        try {
          if (value == null) return [];

          if (value is List) {
            return value.map((e) => e.toString()).toList();
          } else if (value is String) {
            // Если это строка, оборачиваем в список
            return value.isEmpty ? [] : [value];
          } else {
            // Для других типов пытаемся преобразовать в строку
            return [value.toString()];
          }
        } catch (e) {
          sl<Talker>().error('ERROR parsing $fieldName as string list: $e');
          sl<Talker>().logCustom(
            ClientsLog('Value: $value (type: ${value.runtimeType})'),
          );
          return [];
        }
      }

      sl<Talker>().logCustom(
        ClientsLog('CLIENT MODEL: Parsing ClientModel from JSON...'),
      );
      sl<Talker>().logCustom(
        ClientsLog(
          'CLIENT MODEL: Client ID: ${json['client_id']}, Name: ${json['client_name']}',
        ),
      );

      final taxAndLegalInfo = parseJsonString(json['tax_and_legal_info_json']);
      final paymentScheduleInfo = parseJsonString(
        json['payment_schedule_json'],
      );
      final contactsList = parseJsonStringList(json['contacts_json']);
      final patentsList = parseJsonStringList(json['patents_json']);
      final tagsList = parseJsonStringList(json['tags_json']);

      sl<Talker>().logCustom(
        ClientsLog(
          '🔍 [DEBUG] CLIENT MODEL: taxAndLegalInfo: $taxAndLegalInfo',
        ),
      );

      sl<Talker>().logCustom(
        ClientsLog(
          '🔍 [DEBUG] CLIENT MODEL: digital_signature_expiry_date from taxAndLegalInfo: ${taxAndLegalInfo['digital_signature_expiry_date']}',
        ),
      );

      // --- Attachments ---
      List<Map<String, dynamic>> attachments = [];
      if (taxAndLegalInfo.containsKey('files') &&
          taxAndLegalInfo['files'] is List) {
        attachments = List<Map<String, dynamic>>.from(
          (taxAndLegalInfo['files'] as List).whereType<Map<String, dynamic>>(),
        );
      }

      // --- Attachment Comments ---
      String? attachmentComments =
          taxAndLegalInfo['attachment_comments']?.toString();

      sl<Talker>().logCustom(
        ClientsLog(
          '🔵 CLIENT MODEL: profit_tax_type raw value: ${taxAndLegalInfo['profit_tax_type']} (type: ${taxAndLegalInfo['profit_tax_type'].runtimeType})',
        ),
      );

      List<ContactEntity> contacts =
          contactsList.map((c) {
            final contactMap = c as Map<String, dynamic>;
            // Парсинг communicationMethods - поддержка как старого формата (List), так и нового (Map)
            final communicationMethods = <String, String>{};
            if (contactMap['communication_methods'] is Map) {
              final methodsMap =
                  contactMap['communication_methods'] as Map<String, dynamic>;
              communicationMethods.addAll(
                methodsMap.map(
                  (key, value) => MapEntry(key, value?.toString() ?? ''),
                ),
              );
            } else if (contactMap['communication_methods'] is List) {
              // Поддержка старого формата - конвертируем в Map с пустыми значениями
              final methodsList = contactMap['communication_methods'] as List;
              for (final method in methodsList) {
                communicationMethods[method.toString()] = '';
              }
            }

            // Парсинг emails - поддержка как старого формата (email), так и нового (emails)
            final emails = <String>[];
            if (contactMap['emails'] is List) {
              emails.addAll(
                (contactMap['emails'] as List).map((e) => e.toString()),
              );
            } else if (contactMap['email'] != null &&
                contactMap['email'].toString().isNotEmpty) {
              emails.add(contactMap['email'].toString());
            }

            return ContactEntity(
              phone: contactMap['phone']?.toString(),
              emails: emails,
              fullName: contactMap['full_name'] ?? contactMap['name'],
              communicationMethods: communicationMethods,
            );
          }).toList();

      // Парсинг creationDate: manual_creation_date имеет приоритет над created_at
      DateTime? date;
      if (json['manual_creation_date'] != null) {
        try {
          final manualDate = json['manual_creation_date'];
          if (manualDate is String && manualDate.isNotEmpty) {
            date = DateTime.parse(manualDate);
          } else if (manualDate is int) {
            // Сервер возвращает количество дней с начала эпохи
            date = DateTime(1970, 1, 1).add(Duration(days: manualDate));
          }
        } catch (_) {
          // Если парсинг не удался, пробуем created_at
        }
      }

      // Если manual_creation_date не было или не распарсилось, используем created_at
      if (date == null && json['created_at'] != null) {
        try {
          date = DateTime.fromMicrosecondsSinceEpoch(json['created_at']);
        } catch (_) {}
      }

      // Парсинг графиков платежей
      PaymentSchedule? parseSchedule(Map<String, dynamic>? data) {
        if (data == null) return null;
        return PaymentSchedule(
          paymentDate: data['day'] ?? 1,
          transferDate: data['transfer_day'] ?? 1,
        );
      }

      // Парсинг патентов
      List<PatentEntity> patents =
          patentsList.map((p) {
            final patentMap = p as Map<String, dynamic>;

            PatentPayment? parsePayment(Map<String, dynamic>? data) {
              if (data == null) return null;
              return PatentPayment(
                type: data['type'],
                customPayments:
                    (data['payments'] as List?)
                        ?.map(
                          (cp) => PaymentDate(
                            date: DateTime.parse(cp['date']),
                            amount: (cp['amount'] ?? 0).toDouble(),
                          ),
                        )
                        .toList(),
                monthlyPayment:
                    data['period_start'] != null
                        ? MonthlyPayment(
                          startDate: DateTime.parse(data['period_start']),
                          endDate: DateTime.parse(data['period_end']),
                          customAmount: (data['amount'] ?? 0).toDouble(),
                          paymentDays: List<int>.from(
                            data['payment_dates_in_month'] ?? [],
                          ),
                        )
                        : null,
              );
            }

            PatentReduction? parseReduction(Map<String, dynamic>? data) {
              if (data == null) return null;
              return PatentReduction(
                customReductions:
                    (data['payments'] as List?)
                        ?.map(
                          (cr) => PaymentDate(
                            date: DateTime.parse(cr['date']),
                            amount: (cr['amount'] ?? 0).toDouble(),
                          ),
                        )
                        .toList(),
              );
            }

            return PatentEntity(
              startDate: DateTime.parse(patentMap['start_date']),
              endDate: DateTime.parse(patentMap['end_date']),
              issueDate: DateTime.parse(patentMap['issue_date']),
              patentAmount: (patentMap['amount'] ?? 0).toDouble(),
              patentNumber: patentMap['patent_number']?.toString() ?? '',
              patentTitle: patentMap['patent_title'],
              comment: patentMap['comment'],
              payment: parsePayment(
                patentMap['payment_info'] as Map<String, dynamic>?,
              ),
              reduction: parseReduction(
                patentMap['reduction_info'] as Map<String, dynamic>?,
              ),
              newPatentApplicationDate:
                  patentMap['new_patent_application_date'] != null
                      ? DateTime.parse(patentMap['new_patent_application_date'])
                      : null,
            );
          }).toList();

      List<int> parsePaymentDates(dynamic value) {
        if (value == null) return [];
        if (value is List) {
          return value.map((e) => e as int).toList();
        }
        if (value is int) {
          return [value];
        }
        return [];
      }

      return ClientModel(
        id: json['client_id'] ?? json['id'] ?? '',
        name: json['client_name'] ?? json['name'] ?? '',
        inn: taxAndLegalInfo['inn'],
        shortName: json['short_name'],
        contacts: contacts,
        creationDate: date,
        comment: json['comment'],
        manualCreationDate: _parseManualCreationDate(
          json['manual_creation_date'],
        ),
        isActual: json['is_actual'] ?? false,
        isActive: json['is_active'] ?? true,
        updatedAt:
            json['updated_at'] != null
                ? DateTime.fromMicrosecondsSinceEpoch(json['updated_at'])
                : null,

        ownershipForm: taxAndLegalInfo['legal_form'],
        directorType: taxAndLegalInfo['director_type'],
        directorName: taxAndLegalInfo['director_name'],
        directorStartDate:
            taxAndLegalInfo['director_start_date'] != null
                ? DateTime.parse(taxAndLegalInfo['director_start_date'])
                : null,
        taxSystems: parseStringList(
          taxAndLegalInfo['tax_system'],
          'tax_system',
        ),
        profitTaxTypes: parseStringList(
          taxAndLegalInfo['profit_tax_type'],
          'profit_tax_type',
        ),
        vatTypes: parseStringList(taxAndLegalInfo['nds_type'], 'nds_type'),
        propertyTypes: parseStringList(
          taxAndLegalInfo['property_tax_type'],
          'property_tax_type',
        ),
        reportingOperator: taxAndLegalInfo['reporting_operator'],
        activityTypes: parseStringList(
          taxAndLegalInfo['activity_types'],
          'activity_types',
        ),

        additionalTags: parseStringList(tagsList, 'additional_tags'),

        salaryPayment: parseSchedule(
          paymentScheduleInfo['salary'] as Map<String, dynamic>?,
        ),
        salaryPaymentEnabled: paymentScheduleInfo['salary_enabled'] ?? false,
        advancePayment: parseSchedule(
          paymentScheduleInfo['prepayment'] as Map<String, dynamic>?,
        ),
        ndflPayment: parseSchedule(
          paymentScheduleInfo['ndfl'] as Map<String, dynamic>?,
        ), // Assuming 'ndfl' key

        patents: patents,

        // Поля, передаваемые внутри tax_and_legal_info_json
        fixedContributionsIP: parseStringList(
          paymentScheduleInfo['fixed_contributions_ip_type'],
          'fixed_contributions_ip_type',
        ),
        fixedContributionsPaymentDate: parsePaymentDates(
          paymentScheduleInfo['fixed_contributions_payment_date'],
        ),
        enpType: taxAndLegalInfo['enp_type'],
        reportingType: taxAndLegalInfo['reporting_type'],
        exciseGoods: parseStringList(
          taxAndLegalInfo['excise_goods'],
          'excise_goods',
        ),
        excisePaymentTerms: parseStringList(
          taxAndLegalInfo['excise_payment_terms'],
          'excise_payment_terms',
        ),
        edoOperators: parseStringList(
          taxAndLegalInfo['edo_operators'],
          'edo_operators',
        ),
        ndflType: taxAndLegalInfo['ndfl_type'],
        contributionsIP1Percent: parseStringList(
          paymentScheduleInfo['contributions_ip_1_percent_type'],
          'contributions_ip_1_percent_type',
        ),
        contributionsIP1PercentPaymentDate: parsePaymentDates(
          paymentScheduleInfo['contributions_ip_1_percent_payment_date'],
        ),
        attachments: attachments,

        // Новые поля
        fnsInfo:
            (taxAndLegalInfo['fns_info'] as List?)
                ?.map(
                  (f) => FnsInfo(
                    code: f['code']?.toString() ?? '',
                    name: f['name']?.toString() ?? '',
                    date: DateTime.parse(f['date']),
                    oktmo: f['oktmo']?.toString() ?? '',
                  ),
                )
                .toList() ??
            [],
        kppInfo:
            (taxAndLegalInfo['kpp_info'] as List?)
                ?.map(
                  (k) => KppInfo(
                    number: k['number']?.toString() ?? '',
                    date: DateTime.parse(k['date']),
                  ),
                )
                .toList() ??
            [],
        sfrInfo:
            taxAndLegalInfo['sfr_info'] != null
                ? SfrInfo(
                  number:
                      taxAndLegalInfo['sfr_info']['number']?.toString() ?? '',
                  subordinationCode:
                      taxAndLegalInfo['sfr_info']['subordination_code']
                          ?.toString() ??
                      '',
                )
                : null,
        okpo: taxAndLegalInfo['okpo']?.toString(),
        cashOrBank: taxAndLegalInfo['cash_or_bank'],
        cashPayment: taxAndLegalInfo['cash_payment'],
        bankPayment: taxAndLegalInfo['bank_payment'],
        hasEmployees: taxAndLegalInfo['has_employees'],
        isSoleFounderDirector: taxAndLegalInfo['is_sole_founder_director'],
        ogrn: taxAndLegalInfo['ogrn']?.toString(),
        legalAddress: taxAndLegalInfo['legal_address']?.toString(),
        actualAddress: taxAndLegalInfo['actual_address']?.toString(),
        actualAddressSameAsLegal:
            taxAndLegalInfo['actual_address_same_as_legal'] ?? false,
        attachmentComments: attachmentComments,
        digitalSignatureExpiryDate:
            taxAndLegalInfo['digital_signature_expiry_date'] != null
                ? DateTime.parse(
                  taxAndLegalInfo['digital_signature_expiry_date'],
                )
                : null,
        // Статус версии: на обслуживании (поддерживаем булевы и строковые значения)
        onService:
            taxAndLegalInfo['on_service'] is bool
                ? taxAndLegalInfo['on_service'] as bool
                : (taxAndLegalInfo['on_service']?.toString().toLowerCase() ==
                    'true'),
      );
    } catch (e) {
      sl<Talker>().error(
        'CLIENT MODEL: ERROR parsing ClientModel from JSON: $e',
      );
      sl<Talker>().logCustom(
        ClientsLog('🔍 [DEBUG] CLIENT MODEL: Full JSON: ${json.toString()}'),
      );
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    // === Helpers ===
    String? jsonEncodeIfNotEmpty(dynamic value) {
      if (value == null) return null;
      if (value is List && value.isEmpty) return null;
      if (value is Map && value.isEmpty) return null;
      return jsonEncode(value);
    }

    Map<String, dynamic>? scheduleToMap(PaymentSchedule? schedule) {
      if (schedule == null) return null;
      return {
        'day': schedule.paymentDate,
        'transfer_day': schedule.transferDate,
      };
    }

    // === tax_and_legal_info_json ===
    final Map<String, dynamic> taxAndLegalInfo = {
      if (inn != null && inn!.isNotEmpty) 'inn': inn,
      if (ownershipForm != null) 'legal_form': ownershipForm,
      if (directorType != null) 'director_type': directorType,
      if (directorName != null && directorName!.isNotEmpty)
        'director_name': directorName,
      if (directorStartDate != null)
        'director_start_date': directorStartDate!.toIso8601String(),
      if (taxSystems.isNotEmpty) 'tax_system': taxSystems,
      if (profitTaxTypes.isNotEmpty) 'profit_tax_type': profitTaxTypes,
      if (vatTypes.isNotEmpty) 'nds_type': vatTypes,
      if (propertyTypes.isNotEmpty) 'property_tax_type': propertyTypes,
      if (reportingOperator != null) 'reporting_operator': reportingOperator,
      if (activityTypes.isNotEmpty) 'activity_types': activityTypes,
      if (enpType != null && enpType!.isNotEmpty) 'enp_type': enpType,
      if (reportingType != null) 'reporting_type': reportingType,
      if (exciseGoods.isNotEmpty) 'excise_goods': exciseGoods,
      if (excisePaymentTerms.isNotEmpty)
        'excise_payment_terms': excisePaymentTerms,
      if (edoOperators.isNotEmpty) 'edo_operators': edoOperators,
      if (ndflType != null) 'ndfl_type': ndflType,
      if (attachments.isNotEmpty) 'files': attachments,
      if (attachmentComments != null && attachmentComments!.isNotEmpty)
        'attachment_comments': attachmentComments,

      // Новые поля
      if (fnsInfo.isNotEmpty)
        'fns_info':
            fnsInfo
                .map(
                  (f) => {
                    'code': f.code,
                    'name': f.name,
                    'date': f.date.toIso8601String(),
                    'oktmo': f.oktmo,
                  },
                )
                .toList(),
      if (kppInfo.isNotEmpty)
        'kpp_info':
            kppInfo
                .map(
                  (k) => {'number': k.number, 'date': k.date.toIso8601String()},
                )
                .toList(),
      if (sfrInfo != null)
        'sfr_info': {
          'number': sfrInfo!.number,
          'subordination_code': sfrInfo!.subordinationCode,
        },
      if (okpo != null && okpo!.isNotEmpty) 'okpo': okpo,
      if (cashOrBank != null) 'cash_or_bank': cashOrBank,
      if (cashPayment != null) 'cash_payment': cashPayment,
      if (bankPayment != null) 'bank_payment': bankPayment,
      if (hasEmployees != null) 'has_employees': hasEmployees,
      if (isSoleFounderDirector != null)
        'is_sole_founder_director': isSoleFounderDirector,
      if (ogrn != null && ogrn!.isNotEmpty) 'ogrn': ogrn,
      if (legalAddress != null && legalAddress!.isNotEmpty)
        'legal_address': legalAddress,
      if (actualAddress != null && actualAddress!.isNotEmpty)
        'actual_address': actualAddress,
      'actual_address_same_as_legal': actualAddressSameAsLegal,
      if (digitalSignatureExpiryDate != null)
        'digital_signature_expiry_date':
            digitalSignatureExpiryDate!.toIso8601String(),
      // Статус версии: на обслуживании
      'on_service': onService,
    };

    // === payment_schedule_json ===
    final Map<String, dynamic> paymentScheduleJson = {
      'salary_enabled': salaryPaymentEnabled,
      if (salaryPayment != null) 'salary': scheduleToMap(salaryPayment),
      if (advancePayment != null) 'prepayment': scheduleToMap(advancePayment),
      if (ndflPayment != null) 'ndfl': scheduleToMap(ndflPayment),
      'fixed_contributions_ip_type': fixedContributionsIP,
      'fixed_contributions_payment_date': fixedContributionsPaymentDate,
      'contributions_ip_1_percent_type': contributionsIP1Percent,
      'contributions_ip_1_percent_payment_date':
          contributionsIP1PercentPaymentDate,
    };

    // === patents_json ===
    List<Map<String, dynamic>> patentsList =
        patents.map((p) {
          Map<String, dynamic> map = {
            'start_date': p.startDate.toIso8601String(),
            'end_date': p.endDate.toIso8601String(),
            'issue_date': p.issueDate.toIso8601String(),
            'amount': p.patentAmount,
            'patent_number': p.patentNumber,
            if (p.patentTitle != null && p.patentTitle!.isNotEmpty)
              'patent_title': p.patentTitle,
          };
          if (p.comment != null) map['comment'] = p.comment;
          if (p.payment != null) {
            map['payment_info'] = {
              'type': p.payment!.type,
              if (p.payment!.customPayments != null)
                'payments':
                    p.payment!.customPayments!
                        .map(
                          (cp) => {
                            'date': cp.date.toIso8601String(),
                            'amount': cp.amount,
                          },
                        )
                        .toList(),
              if (p.payment!.monthlyPayment != null)
                'period_start':
                    p.payment!.monthlyPayment!.startDate.toIso8601String(),
              if (p.payment!.monthlyPayment != null)
                'period_end':
                    p.payment!.monthlyPayment!.endDate.toIso8601String(),
              if (p.payment!.monthlyPayment != null)
                'amount': p.payment!.monthlyPayment!.customAmount,
              if (p.payment!.monthlyPayment != null)
                'payment_dates_in_month':
                    p.payment!.monthlyPayment!.paymentDays,
            };
          }
          if (p.reduction != null) {
            map['reduction_info'] = {
              'type': 'произвольно',
              if (p.reduction!.customReductions != null &&
                  p.reduction!.customReductions!.isNotEmpty)
                'payments':
                    p.reduction!.customReductions!
                        .map(
                          (cr) => {
                            'date': cr.date.toIso8601String(),
                            'amount': cr.amount,
                          },
                        )
                        .toList(),
            };
          }
          if (p.newPatentApplicationDate != null) {
            map['new_patent_application_date'] =
                p.newPatentApplicationDate!.toIso8601String();
          }
          return map;
        }).toList();

    // === contacts_json ===
    final contactsList =
        contacts
            .map(
              (c) => {
                if (c.fullName != null)
                  'name': c.fullName, // API ожидает "name"
                if (c.phone != null) 'phone': c.phone,
                if (c.emails.isNotEmpty)
                  'emails': c.emails, // Новое поле для множественных email
                if (c.communicationMethods.isNotEmpty)
                  'communication_methods': c.communicationMethods,
              },
            )
            .toList();

    return {
      if (id.isNotEmpty) 'client_id': id,
      'client_name': name,
      if (shortName != null) 'short_name': shortName,
      if (jsonEncodeIfNotEmpty(contactsList) != null)
        'contacts_json': jsonEncodeIfNotEmpty(contactsList),
      if (jsonEncodeIfNotEmpty(taxAndLegalInfo) != null)
        'tax_and_legal_info_json': jsonEncodeIfNotEmpty(taxAndLegalInfo),
      if (jsonEncodeIfNotEmpty(paymentScheduleJson) != null)
        'payment_schedule_json': jsonEncodeIfNotEmpty(paymentScheduleJson),
      if (jsonEncodeIfNotEmpty(patentsList) != null)
        'patents_json': jsonEncodeIfNotEmpty(patentsList),
      if (additionalTags.isNotEmpty) 'tags_json': jsonEncode(additionalTags),
      if (comment != null) 'comment': comment,
      // Используем manualCreationDate если есть, иначе creationDate
      if (manualCreationDate != null || creationDate != null)
        'manual_creation_date':
            (manualCreationDate ?? creationDate)!
                .toIso8601String()
                .split('T')
                .first,
      'is_actual': isActual,
      'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt!.microsecondsSinceEpoch,
    };
  }

  ClientEntity toEntity() => ClientEntity(
    id: id,
    name: name,
    inn: inn,
    kppInfo: kppInfo,
    shortName: shortName,
    contacts: contacts,
    creationDate: creationDate,
    comment: comment,
    manualCreationDate: manualCreationDate,
    isActual: isActual,
    isActive: isActive,
    updatedAt: updatedAt,
    fixedContributionsIP: fixedContributionsIP,
    fixedContributionsPaymentDate: fixedContributionsPaymentDate,
    ownershipForm: ownershipForm,
    directorType: directorType,
    directorName: directorName,
    directorStartDate: directorStartDate,
    taxSystems: taxSystems,
    profitTaxTypes: profitTaxTypes,
    vatTypes: vatTypes,
    propertyTypes: propertyTypes,
    reportingType: reportingType,
    reportingOperator: reportingOperator,
    exciseGoods: exciseGoods,
    excisePaymentTerms: excisePaymentTerms,
    edoOperators: edoOperators,
    enpType: enpType,
    activityTypes: activityTypes,
    ndflType: ndflType,
    additionalTags: additionalTags,
    salaryPayment: salaryPayment,
    salaryPaymentEnabled: salaryPaymentEnabled,
    advancePayment: advancePayment,
    ndflPayment: ndflPayment,
    patents: patents,
    contributionsIP1Percent: contributionsIP1Percent,
    contributionsIP1PercentPaymentDate: contributionsIP1PercentPaymentDate,
    attachments: attachments,
    attachmentComments: attachmentComments,
    fnsInfo: fnsInfo,
    sfrInfo: sfrInfo,
    okpo: okpo,
    cashOrBank: cashOrBank,
    cashPayment: cashPayment,
    bankPayment: bankPayment,
    hasEmployees: hasEmployees,
    isSoleFounderDirector: isSoleFounderDirector,
    ogrn: ogrn,
    legalAddress: legalAddress,
    actualAddress: actualAddress,
    actualAddressSameAsLegal: actualAddressSameAsLegal,
    digitalSignatureExpiryDate: digitalSignatureExpiryDate,
    onService: onService,
  );

  factory ClientModel.fromEntity(ClientEntity e) {
    return ClientModel(
      id: e.id,
      name: e.name,
      inn: e.inn,
      kppInfo: e.kppInfo,
      shortName: e.shortName,
      contacts: e.contacts,
      creationDate: e.creationDate,
      comment: e.comment,
      manualCreationDate: e.manualCreationDate,
      isActual: e.isActual,
      isActive: e.isActive,
      updatedAt: e.updatedAt,
      fixedContributionsIP: e.fixedContributionsIP,
      fixedContributionsPaymentDate: e.fixedContributionsPaymentDate,
      ownershipForm: e.ownershipForm,
      directorType: e.directorType,
      directorName: e.directorName,
      directorStartDate: e.directorStartDate,
      taxSystems: e.taxSystems,
      profitTaxTypes: e.profitTaxTypes,
      vatTypes: e.vatTypes,
      propertyTypes: e.propertyTypes,
      reportingType: e.reportingType,
      reportingOperator: e.reportingOperator,
      exciseGoods: e.exciseGoods,
      excisePaymentTerms: e.excisePaymentTerms,
      edoOperators: e.edoOperators,
      enpType: e.enpType,
      activityTypes: e.activityTypes,
      ndflType: e.ndflType,
      additionalTags: e.additionalTags,
      salaryPayment: e.salaryPayment,
      salaryPaymentEnabled: e.salaryPaymentEnabled,
      advancePayment: e.advancePayment,
      ndflPayment: e.ndflPayment,
      patents: e.patents,
      contributionsIP1Percent: e.contributionsIP1Percent,
      contributionsIP1PercentPaymentDate: e.contributionsIP1PercentPaymentDate,
      attachments: e.attachments,
      attachmentComments: e.attachmentComments,
      fnsInfo: e.fnsInfo,
      sfrInfo: e.sfrInfo,
      okpo: e.okpo,
      cashOrBank: e.cashOrBank,
      cashPayment: e.cashPayment,
      bankPayment: e.bankPayment,
      hasEmployees: e.hasEmployees,
      isSoleFounderDirector: e.isSoleFounderDirector,
      ogrn: e.ogrn,
      legalAddress: e.legalAddress,
      actualAddress: e.actualAddress,
      actualAddressSameAsLegal: e.actualAddressSameAsLegal,
      digitalSignatureExpiryDate: e.digitalSignatureExpiryDate,
      onService: e.onService,
    );
  }
}
