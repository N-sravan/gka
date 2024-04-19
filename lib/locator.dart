import 'package:get_it/get_it.dart';
import 'package:gka/chat/repo/chat_repo.dart';
import 'home/repository/home_repo.dart';
import 'login/repository/login_repo.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerFactory<LoginRepository>(() => LoginRepositoryImpl());
  locator.registerFactory<HomeRepository>(() => HomeRepositoryImpl());
  locator.registerFactory<ChatRepository>(() => ChatRepositoryImpl());
}
