import 'package:logger/logger.dart';

final log = Logger();

class LoggerMixin {
  final _logger = Logger();

  Logger get log => _logger;
}
