import 'package:balansoved_mobile/features/_empty/data/models/empty_model.dart';

abstract class EmptyRemoteDataSource {
  Future<EmptyModel> fetchEmpty();
}

class EmptyRemoteDataSourceStub implements EmptyRemoteDataSource {
  @override
  Future<EmptyModel> fetchEmpty() async {
    return const EmptyModel(id: 'stub');
  }
}

