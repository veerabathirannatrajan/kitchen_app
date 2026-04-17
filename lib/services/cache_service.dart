import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  Future<void> preloadModelHtml(String htmlContent, String key) async {
    final bytes = Uint8List.fromList(htmlContent.codeUnits);
    await _cacheManager.putFile(key, bytes, fileExtension: 'html');
  }

  Future<File?> getCachedFile(String key) async {
    final fileInfo = await _cacheManager.getFileFromCache(key);
    return fileInfo?.file;
  }

  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }
}