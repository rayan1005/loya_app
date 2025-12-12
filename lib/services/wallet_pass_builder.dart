import '/backend/schema/merchants_record.dart';
import '/backend/schema/programs_record.dart';
import '/backend/schema/stamp_cards_record.dart';

class WalletPassBuilder {
  static Map<String, dynamic> build({
    required ProgramsRecord program,
    required StampCardsRecord card,
    MerchantsRecord? merchant,
    String? qrValue,
  }) {
    final total =
        program.stampsRequired > 0 ? program.stampsRequired.clamp(1, 12) : 12;
    final filled = card.currentStamps.clamp(0, total);
    final remaining = (total - filled).clamp(0, total);
    final rewardUnlocked = remaining == 0;
    final memberId = card.memberId.isNotEmpty
        ? card.memberId
        : (card.cardId.isNotEmpty ? card.cardId : card.reference.id);

    final latestUpdate = card.latestPassUpdate.isNotEmpty
        ? card.latestPassUpdate
        : program.passLatestUpdate;
    final collectRule = program.passCollectRule.isNotEmpty
        ? program.passCollectRule
        : 'Collect one stamp per purchase';
    final rewardDetails = program.rewardDetails;
    final rewardHistory = card.rewardsHistory;
    final supportEmail = program.passSupportEmail.isNotEmpty
        ? program.passSupportEmail
        : (merchant?.email ?? '');
    final contactName = program.passContactName.isNotEmpty
        ? program.passContactName
        : (merchant?.name ?? '');

    final links = <String, String>{};
    if (program.passInstagram.isNotEmpty) {
      links['instagram'] = program.passInstagram;
    }
    if (program.passSnapchat.isNotEmpty) {
      links['snapchat'] = program.passSnapchat;
    }
    if (program.passWebsite.isNotEmpty) {
      links['website'] = program.passWebsite;
    }

    final locations = program.passLocations
        .map((loc) {
          if (loc is Map) {
            final city = (loc['city'] ?? '').toString();
            final branch = (loc['label'] ?? loc['branch'] ?? '').toString();
            if (city.isEmpty && branch.isEmpty) return null;
            return {
              'city': city,
              'branch': branch,
            };
          }
          return null;
        })
        .whereType<Map<String, String>>()
        .toList();

    final events = <Map<String, dynamic>>[];
    events.add({
      'type': 'stamp_added',
      'total': filled,
      'remaining': remaining,
      'timestamp': card.updatedAt?.toIso8601String(),
    });
    if (rewardUnlocked) {
      events.add({
        'type': 'reward_unlocked',
        'reward': rewardDetails,
        'timestamp': card.updatedAt?.toIso8601String(),
      });
    }
    if (latestUpdate.isNotEmpty) {
      events.add({
        'type': 'offer_update',
        'message': latestUpdate,
        'timestamp': program.passLatestUpdateAt?.toIso8601String(),
      });
    }

    return {
      'front': {
        'program': program.title,
        'memberId': memberId,
        'logo': program.passLogo.isNotEmpty
            ? program.passLogo
            : (program.businessIcon.isNotEmpty ? program.businessIcon : ''),
        'stampIcon': program.stampIcon,
        'stamps': {
          'total': total,
          'filled': filled,
          'remaining': remaining,
        },
        'barcode': qrValue ?? card.qrValue,
      },
      'back': [
        {
          'title': 'Latest Updates',
          'value': latestUpdate,
          'updated_at': program.passLatestUpdateAt?.toIso8601String(),
        },
        {
          'title': 'How to Collect Stamps',
          'value': collectRule,
        },
        {
          'title': 'Reward Details',
          'value': rewardDetails,
        },
        {
          'title': 'Stamps Required Until Next Reward',
          'value': remaining,
        },
        if (rewardHistory.isNotEmpty)
          {
            'title': 'Rewards Earned',
            'value': rewardHistory,
          },
        if (locations.isNotEmpty)
          {
            'title': 'Locations',
            'value': locations,
          },
        if (links.isNotEmpty)
          {
            'title': 'Useful Links',
            'value': links,
          },
        if (program.termsConditions.isNotEmpty)
          {
            'title': 'Terms & Conditions',
            'value': program.termsConditions,
          },
        if (supportEmail.isNotEmpty || contactName.isNotEmpty)
          {
            'title': 'Contact',
            'value': {
              'name': contactName,
              'email': supportEmail,
            },
          },
      ],
      'meta': {
        'rewardUnlocked': rewardUnlocked,
        'stampsToNext': remaining,
      },
      'notifications': events.where((e) => e['timestamp'] != null).toList(),
    };
  }
}
