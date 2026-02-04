import 'package:flutter/material.dart';

import 'http_utils.dart';

void showErrorSnackBar(BuildContext context, dynamic error) {
  final msg = error is ApiError ? error.message : error.toString();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
  );
}
