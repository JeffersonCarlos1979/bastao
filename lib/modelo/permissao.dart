import 'package:permission_handler/permission_handler.dart';

/// Created by jeff on 06/03/2022.

class Permissao {
  final Permission permission;
  final String descricao;

  const Permissao({
    required this.permission,
    required this.descricao,
  });
}
