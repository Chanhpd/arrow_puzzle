// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/game/data/repositories/game_repository_impl.dart'
    as _i33;
import '../../features/game/data/repositories/level_repository_impl.dart'
    as _i380;
import '../../features/game/data/services/level_generator_service.dart'
    as _i173;
import '../../features/game/data/services/puzzle_solver_service.dart' as _i987;
import '../../features/game/domain/repositories/repositories.dart' as _i343;
import '../../features/game/domain/usecases/generate_level_usecase.dart'
    as _i330;
import '../../features/game/domain/usecases/get_current_level_usecase.dart'
    as _i358;
import '../../features/game/domain/usecases/move_arrow_usecase.dart' as _i872;
import '../../features/game/domain/usecases/save_level_progress_usecase.dart'
    as _i1050;
import '../../features/game/domain/usecases/usecases.dart' as _i105;
import '../../features/game/presentation/cubit/game_cubit.dart' as _i192;
import '../storage/local_storage.dart' as _i329;
import 'app_module.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.factory<_i987.PuzzleSolverService>(() => _i987.PuzzleSolverService());
    await gh.singletonAsync<_i460.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.singleton<_i329.LocalStorageService>(
      () => _i329.LocalStorageService(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i343.LevelRepository>(
      () => _i380.LevelRepositoryImpl(gh<_i329.LocalStorageService>()),
    );
    gh.factory<_i358.GetCurrentLevelUseCase>(
      () => _i358.GetCurrentLevelUseCase(gh<_i343.LevelRepository>()),
    );
    gh.factory<_i1050.SaveLevelProgressUseCase>(
      () => _i1050.SaveLevelProgressUseCase(gh<_i343.LevelRepository>()),
    );
    gh.factory<_i173.LevelGeneratorService>(
      () => _i173.LevelGeneratorService(gh<_i987.PuzzleSolverService>()),
    );
    gh.lazySingleton<_i343.GameRepository>(
      () => _i33.GameRepositoryImpl(
        gh<_i173.LevelGeneratorService>(),
        gh<_i987.PuzzleSolverService>(),
      ),
    );
    gh.factory<_i330.GenerateLevelUseCase>(
      () => _i330.GenerateLevelUseCase(gh<_i343.GameRepository>()),
    );
    gh.factory<_i872.MoveArrowUseCase>(
      () => _i872.MoveArrowUseCase(gh<_i343.GameRepository>()),
    );
    gh.factory<_i192.GameCubit>(
      () => _i192.GameCubit(
        gh<_i105.GenerateLevelUseCase>(),
        gh<_i105.MoveArrowUseCase>(),
        gh<_i105.GetCurrentLevelUseCase>(),
        gh<_i105.SaveLevelProgressUseCase>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}
