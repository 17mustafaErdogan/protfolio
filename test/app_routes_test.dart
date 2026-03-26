import 'package:flutter_test/flutter_test.dart';
import 'package:portfolyo/config/routes.dart';

void main() {
  test('AppRoutes sabit yollar tutarlı', () {
    expect(AppRoutes.home, '/');
    expect(AppRoutes.admin, '/admin');
    expect(AppRoutes.adminMessages, '/admin/messages');
    expect(AppRoutes.projectDetailPath('abc'), '/projects/abc');
    expect(AppRoutes.adminProjectEditPath('xyz'), '/admin/projects/xyz/edit');
  });
}
