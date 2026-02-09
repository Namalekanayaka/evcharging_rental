import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/admin_repository.dart';
import '../../domain/entities/admin_entities.dart';

// ==================== EVENTS ====================

abstract class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object?> get props => [];
}

class GetUsersEvent extends AdminEvent {
  final int limit;
  final int offset;
  final Map<String, dynamic>? filters;

  const GetUsersEvent(this.limit, this.offset, {this.filters});
  @override
  List<Object?> get props => [limit, offset, filters];
}

class ToggleUserSuspensionEvent extends AdminEvent {
  final int userId;
  final bool suspend;

  const ToggleUserSuspensionEvent(this.userId, {required this.suspend});
  @override
  List<Object?> get props => [userId, suspend];
}

class GetChargersEvent extends AdminEvent {
  final int limit;
  final int offset;
  final Map<String, dynamic>? filters;

  const GetChargersEvent(this.limit, this.offset, {this.filters});
  @override
  List<Object?> get props => [limit, offset, filters];
}

class ApproveChargerEvent extends AdminEvent {
  final int chargerId;
  final bool approved;
  final String? reason;

  const ApproveChargerEvent(this.chargerId,
      {required this.approved, this.reason});
  @override
  List<Object?> get props => [chargerId, approved, reason];
}

class GetRevenueAnalyticsEvent extends AdminEvent {
  final String startDate;
  final String endDate;

  const GetRevenueAnalyticsEvent(this.startDate, this.endDate);
  @override
  List<Object?> get props => [startDate, endDate];
}

class GetPlatformAnalyticsEvent extends AdminEvent {
  const GetPlatformAnalyticsEvent();
}

class GetFraudCasesEvent extends AdminEvent {
  final int limit;
  final int offset;

  const GetFraudCasesEvent(this.limit, this.offset);
  @override
  List<Object?> get props => [limit, offset];
}

class ResolveFraudCaseEvent extends AdminEvent {
  final int caseId;
  final String resolution;
  final String? notes;

  const ResolveFraudCaseEvent(this.caseId, this.resolution, {this.notes});
  @override
  List<Object?> get props => [caseId, resolution, notes];
}

class CreatePromotionEvent extends AdminEvent {
  final String title;
  final String description;
  final double discountPercentage;
  final String code;
  final DateTime startDate;
  final DateTime endDate;
  final int? maxUses;

  const CreatePromotionEvent(
    this.title,
    this.description,
    this.discountPercentage,
    this.code,
    this.startDate,
    this.endDate, {
    this.maxUses,
  });
  @override
  List<Object?> get props => [
        title,
        description,
        discountPercentage,
        code,
        startDate,
        endDate,
        maxUses
      ];
}

class GetPromotionsEvent extends AdminEvent {
  final int limit;
  final int offset;

  const GetPromotionsEvent(this.limit, this.offset);
  @override
  List<Object?> get props => [limit, offset];
}

class GetTopChargersEvent extends AdminEvent {
  final int limit;

  const GetTopChargersEvent(this.limit);
  @override
  List<Object?> get props => [limit];
}

class ClearAdminEvent extends AdminEvent {
  const ClearAdminEvent();
}

// ==================== STATES ====================

abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitialState extends AdminState {
  const AdminInitialState();
}

class AdminLoadingState extends AdminState {
  const AdminLoadingState();
}

class UsersLoadedState extends AdminState {
  final List<AdminUserEntity> users;

  const UsersLoadedState(this.users);
  @override
  List<Object?> get props => [users];
}

class UserSuspensionToggledState extends AdminState {
  final AdminUserEntity user;
  final bool wasSuspended;

  const UserSuspensionToggledState(this.user, {required this.wasSuspended});
  @override
  List<Object?> get props => [user, wasSuspended];
}

class ChargersLoadedState extends AdminState {
  final List<AdminChargerEntity> chargers;

  const ChargersLoadedState(this.chargers);
  @override
  List<Object?> get props => [chargers];
}

class ChargerApprovedState extends AdminState {
  final AdminChargerEntity charger;
  final bool approved;

  const ChargerApprovedState(this.charger, {required this.approved});
  @override
  List<Object?> get props => [charger, approved];
}

class RevenueAnalyticsLoadedState extends AdminState {
  final List<RevenueAnalyticsEntity> analytics;

  const RevenueAnalyticsLoadedState(this.analytics);
  @override
  List<Object?> get props => [analytics];
}

class PlatformAnalytticsLoadedState extends AdminState {
  final PlatformAnalyticsSummaryEntity summary;

  const PlatformAnalytticsLoadedState(this.summary);
  @override
  List<Object?> get props => [summary];
}

class FraudCasesLoadedState extends AdminState {
  final List<FraudCaseEntity> cases;

  const FraudCasesLoadedState(this.cases);
  @override
  List<Object?> get props => [cases];
}

class FraudCaseResolvedState extends AdminState {
  final FraudCaseEntity case_;

  const FraudCaseResolvedState(this.case_);
  @override
  List<Object?> get props => [case_];
}

class PromotionCreatedState extends AdminState {
  final PromotionEntity promotion;

  const PromotionCreatedState(this.promotion);
  @override
  List<Object?> get props => [promotion];
}

class PromotionsLoadedState extends AdminState {
  final List<PromotionEntity> promotions;

  const PromotionsLoadedState(this.promotions);
  @override
  List<Object?> get props => [promotions];
}

class TopChargersLoadedState extends AdminState {
  final List<TopChargerEntity> chargers;

  const TopChargersLoadedState(this.chargers);
  @override
  List<Object?> get props => [chargers];
}

class AdminErrorState extends AdminState {
  final String message;

  const AdminErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository repository;

  AdminBloc({required this.repository}) : super(const AdminInitialState()) {
    on<GetUsersEvent>(_onGetUsers);
    on<ToggleUserSuspensionEvent>(_onToggleUserSuspension);
    on<GetChargersEvent>(_onGetChargers);
    on<ApproveChargerEvent>(_onApproveCharger);
    on<GetRevenueAnalyticsEvent>(_onGetRevenueAnalytics);
    on<GetPlatformAnalyticsEvent>(_onGetPlatformAnalytics);
    on<GetFraudCasesEvent>(_onGetFraudCases);
    on<ResolveFraudCaseEvent>(_onResolveFraudCase);
    on<CreatePromotionEvent>(_onCreatePromotion);
    on<GetPromotionsEvent>(_onGetPromotions);
    on<GetTopChargersEvent>(_onGetTopChargers);
    on<ClearAdminEvent>(_onClear);
  }

  Future<void> _onGetUsers(
      GetUsersEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoadingState());
    final result = await repository.getUsers(event.limit, event.offset,
        filters: event.filters);
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (users) => emit(UsersLoadedState(users)),
    );
  }

  Future<void> _onToggleUserSuspension(
    ToggleUserSuspensionEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoadingState());
    final result =
        await repository.toggleUserSuspension(event.userId, event.suspend);
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (user) =>
          emit(UserSuspensionToggledState(user, wasSuspended: event.suspend)),
    );
  }

  Future<void> _onGetChargers(
      GetChargersEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoadingState());
    final result = await repository.getChargers(event.limit, event.offset,
        filters: event.filters);
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (chargers) => emit(ChargersLoadedState(chargers)),
    );
  }

  Future<void> _onApproveCharger(
      ApproveChargerEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoadingState());
    final result = await repository
        .approveCharger(event.chargerId, event.approved, reason: event.reason);
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (charger) =>
          emit(ChargerApprovedState(charger, approved: event.approved)),
    );
  }

  Future<void> _onGetRevenueAnalytics(
    GetRevenueAnalyticsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoadingState());
    final result =
        await repository.getRevenueAnalytics(event.startDate, event.endDate);
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (analytics) => emit(RevenueAnalyticsLoadedState(analytics)),
    );
  }

  Future<void> _onGetPlatformAnalytics(
    GetPlatformAnalyticsEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoadingState());
    final result = await repository.getPlatformAnalytics();
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (summary) => emit(PlatformAnalytticsLoadedState(summary)),
    );
  }

  Future<void> _onGetFraudCases(
      GetFraudCasesEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoadingState());
    final result = await repository.getFraudCases(event.limit, event.offset);
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (cases) => emit(FraudCasesLoadedState(cases)),
    );
  }

  Future<void> _onResolveFraudCase(
    ResolveFraudCaseEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoadingState());
    final result = await repository
        .resolveFraudCase(event.caseId, event.resolution, notes: event.notes);
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (case_) => emit(FraudCaseResolvedState(case_)),
    );
  }

  Future<void> _onCreatePromotion(
      CreatePromotionEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoadingState());
    final result = await repository.createPromotion({
      'title': event.title,
      'description': event.description,
      'discountPercentage': event.discountPercentage,
      'code': event.code,
      'startDate': event.startDate.toIso8601String(),
      'endDate': event.endDate.toIso8601String(),
      'maxUses': event.maxUses,
    });
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (promotion) => emit(PromotionCreatedState(promotion)),
    );
  }

  Future<void> _onGetPromotions(
      GetPromotionsEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoadingState());
    final result = await repository.getPromotions(event.limit, event.offset);
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (promotions) => emit(PromotionsLoadedState(promotions)),
    );
  }

  Future<void> _onGetTopChargers(
      GetTopChargersEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoadingState());
    final result = await repository.getTopChargers(event.limit);
    result.fold(
      (failure) => emit(AdminErrorState(failure.message)),
      (chargers) => emit(TopChargersLoadedState(chargers)),
    );
  }

  void _onClear(ClearAdminEvent event, Emitter<AdminState> emit) {
    emit(const AdminInitialState());
  }
}
