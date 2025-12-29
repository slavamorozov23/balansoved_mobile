import 'package:flutter/material.dart';
import 'package:balansoved_mobile/features/clients/domain/entities/client_entity.dart';
import 'package:balansoved_mobile/features/clients/presentation/widgets/client_detail/client_detail_fields.dart';
import 'package:balansoved_mobile/features/clients/presentation/widgets/client_detail/fields/client_field_utils.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/fields/task_floral_divider.dart';

class ClientDetailCard extends StatelessWidget {
  final ClientEntity client;

  const ClientDetailCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final versionDate = client.manualCreationDate ?? client.creationDate;
    final hasTaxData =
        cleanStringList(client.taxSystems).isNotEmpty ||
        cleanStringList(client.profitTaxTypes).isNotEmpty ||
        cleanStringList(client.vatTypes).isNotEmpty ||
        cleanStringList(client.propertyTypes).isNotEmpty ||
        (client.reportingType?.trim().isNotEmpty ?? false) ||
        (client.reportingOperator?.trim().isNotEmpty ?? false) ||
        cleanStringList(client.exciseGoods).isNotEmpty ||
        cleanStringList(client.excisePaymentTerms).isNotEmpty ||
        cleanStringList(client.edoOperators).isNotEmpty ||
        (client.enpType?.trim().isNotEmpty ?? false) ||
        (client.ndflType?.trim().isNotEmpty ?? false);

    final hasAdditionalData =
        cleanStringList(client.activityTypes).isNotEmpty ||
        cleanStringList(client.additionalTags).isNotEmpty ||
        cleanStringList(client.fixedContributionsIP).isNotEmpty ||
        cleanStringList(client.contributionsIP1Percent).isNotEmpty;

    final hasAttachments =
        client.attachments.isNotEmpty ||
        (client.attachmentComments?.trim().isNotEmpty ?? false);

    final hasPatents = client.patents.isNotEmpty;

    final mainInfoSection = <Widget>[
      ClientNameField(name: client.name),
      const SizedBox(height: 12),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ClientShortNameField(shortName: client.shortName)),
            const SizedBox(width: 12),
            Expanded(child: ClientInnField(inn: client.inn)),
          ],
        ),
      ),
      const SizedBox(height: 12),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ClientCurrentKppField(kppInfo: client.kppInfo)),
            const SizedBox(width: 12),
            Expanded(child: ClientCreationDateField(date: client.creationDate)),
          ],
        ),
      ),
      const SizedBox(height: 12),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClientOwnershipFormField(
                ownershipForm: client.ownershipForm,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: ClientOnServiceField(onService: client.onService)),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ClientDirectorField(
        directorType: client.directorType,
        directorName: client.directorName,
        directorStartDate: client.directorStartDate,
      ),
      const SizedBox(height: 12),
      ClientDigitalSignatureExpiryField(
        expiryDate: client.digitalSignatureExpiryDate,
      ),
      const SizedBox(height: 12),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ClientVersionDateField(date: versionDate)),
            const SizedBox(width: 12),
            Expanded(child: ClientUpdatedAtField(date: client.updatedAt)),
          ],
        ),
      ),
      const SizedBox(height: 12),
      ClientCommentField(comment: client.comment),
    ];

    final contactsSection = <Widget>[
      ClientContactsField(contacts: client.contacts),
    ];

    final taxSection =
        hasTaxData
            ? [
              ClientTaxSectionField(
                taxSystems: client.taxSystems,
                profitTaxTypes: client.profitTaxTypes,
                vatTypes: client.vatTypes,
                propertyTypes: client.propertyTypes,
                reportingType: client.reportingType,
                reportingOperator: client.reportingOperator,
                exciseGoods: client.exciseGoods,
                excisePaymentTerms: client.excisePaymentTerms,
                edoOperators: client.edoOperators,
                enpType: client.enpType,
                ndflType: client.ndflType,
              ),
            ]
            : <Widget>[];

    final paymentSection = <Widget>[
      ClientPaymentSchedulesField(
        salaryPayment: client.salaryPayment,
        salaryPaymentEnabled: client.salaryPaymentEnabled,
        cashPayment: client.cashPayment,
        bankPayment: client.bankPayment,
        hasEmployees: client.hasEmployees,
        isSoleFounderDirector: client.isSoleFounderDirector,
        advancePayment: client.advancePayment,
        ndflPayment: client.ndflPayment,
      ),
    ];

    final additionalSection =
        hasAdditionalData
            ? [
              ClientAdditionalSectionField(
                activityTypes: client.activityTypes,
                additionalTags: client.additionalTags,
                fixedContributionsIP: client.fixedContributionsIP,
                fixedContributionsPaymentDate:
                    client.fixedContributionsPaymentDate,
                contributionsIP1Percent: client.contributionsIP1Percent,
                contributionsIP1PercentPaymentDate:
                    client.contributionsIP1PercentPaymentDate,
              ),
            ]
            : <Widget>[];

    final extendedSection = <Widget>[
      ClientExtendedInfoField(
        ownershipForm: client.ownershipForm,
        okpo: client.okpo,
        ogrn: client.ogrn,
        legalAddress: client.legalAddress,
        actualAddress: client.actualAddress,
        actualAddressSameAsLegal: client.actualAddressSameAsLegal,
        sfrInfo: client.sfrInfo,
        fnsInfo: client.fnsInfo,
        kppInfo: client.kppInfo,
      ),
    ];

    final attachmentsSection =
        hasAttachments
            ? [
              ClientAttachmentsField(attachments: client.attachments),
              if (client.attachmentComments?.trim().isNotEmpty ?? false)
                const SizedBox(height: 12),
              if (client.attachmentComments?.trim().isNotEmpty ?? false)
                ClientAttachmentCommentsField(
                  comments: client.attachmentComments,
                ),
            ]
            : <Widget>[];

    final patentsSection =
        hasPatents ? [ClientPatentsField(patents: client.patents)] : <Widget>[];

    final sections = _mergeSections([
      mainInfoSection,
      contactsSection,
      taxSection,
      paymentSection,
      additionalSection,
      extendedSection,
      attachmentsSection,
      patentsSection,
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections,
    );
  }

  List<Widget> _mergeSections(List<List<Widget>> sections) {
    final filtered = sections.where((section) => section.isNotEmpty).toList();
    if (filtered.isEmpty) return const <Widget>[];

    final widgets = <Widget>[];
    for (var i = 0; i < filtered.length; i++) {
      if (i > 0) {
        widgets.add(const SizedBox(height: 12));
        widgets.add(const TaskFloralDivider());
        widgets.add(const SizedBox(height: 12));
      }
      widgets.addAll(filtered[i]);
    }
    return widgets;
  }
}
