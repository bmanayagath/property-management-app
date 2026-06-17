// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseModelImpl _$$ExpenseModelImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseModelImpl(
      id: json['id'] as String,
      orgId: json['orgId'] as String? ?? 'default_org',
      villaId: json['villaId'] as String?,
      villaName: json['villaName'] as String? ?? '',
      roomId: json['roomId'] as String?,
      roomName: json['roomName'] as String?,
      category: $enumDecode(_$ExpenseCategoryEnumMap, json['category']),
      amount: (json['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(json['expenseDate'] as String),
      paidTo: json['paidTo'] as String,
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ExpenseModelImplToJson(_$ExpenseModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orgId': instance.orgId,
      'villaId': instance.villaId,
      'villaName': instance.villaName,
      'roomId': instance.roomId,
      'roomName': instance.roomName,
      'category': _$ExpenseCategoryEnumMap[instance.category]!,
      'amount': instance.amount,
      'expenseDate': instance.expenseDate.toIso8601String(),
      'paidTo': instance.paidTo,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.maintenance: 'maintenance',
  ExpenseCategory.repair: 'repair',
  ExpenseCategory.electricity: 'electricity',
  ExpenseCategory.water: 'water',
  ExpenseCategory.cleaning: 'cleaning',
  ExpenseCategory.commission: 'commission',
  ExpenseCategory.insurance: 'insurance',
  ExpenseCategory.governmentFee: 'governmentFee',
  ExpenseCategory.loan: 'loan',
  ExpenseCategory.ownerRent: 'ownerRent',
  ExpenseCategory.depositRefund: 'depositRefund',
  ExpenseCategory.other: 'other',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.check: 'check',
  PaymentMethod.transfer: 'transfer',
  PaymentMethod.online: 'online',
  PaymentMethod.other: 'other',
};
