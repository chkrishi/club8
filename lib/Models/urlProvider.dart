import 'package:club8/Models/club8Model.dart';
import 'package:club8/Models/fetchUrl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clubProvider = FutureProvider<List<club>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get(
    'https://staging.chamberofsecrets.8club.co/v1/experiences?active=true',
  );

  final clubJson = response.data['data']['experiences'] as List<dynamic>;

  return clubJson.map((json) => club.fromJson(json)).toList();
});
