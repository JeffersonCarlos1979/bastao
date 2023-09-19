// ignore_for_file: unused_import

import 'package:flutter/material.dart';

enum TipoBotoes {
  ok,
  okCancel,
  simNao,
}

class Alerta {
  static Future<bool?> exibirAlerta(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    TipoBotoes tipoBotoes = TipoBotoes.ok,
    double? largura,
    Icon icon = const Icon(Icons.info_outline),
    bool botaoOkPadrao = true,
  }) async {
    const tituloStyle = TextStyle(
      //fontSize: TamanhoFonte.TITULO,
      //color: Cores.fundoAzulEscuro2,
      fontWeight: FontWeight.bold,
    );

    const textStyle = TextStyle(
        //fontSize: TamanhoFonte.CORPO
        );

    const botaoStyle = TextStyle(
        //fontSize: TamanhoFonte.CORPO
        );

    String rotuloOk = tipoBotoes == TipoBotoes.simNao ? 'Sim' : 'Ok';
    String rotuloCancel = tipoBotoes == TipoBotoes.simNao ? 'Não' : 'Cancelar';

    return await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: ListTile(
            title: Text(
              titulo,
              style: tituloStyle,
            ),
            leading: icon,
          ),
          content: Container(
            //color: Colors.red,
            width: largura,
            child: Text(
              mensagem,
              style: textStyle,
            ),
          ),
          actions: <Widget>[
            if (tipoBotoes != TipoBotoes.ok)
              _buildButton(
                padrao: !botaoOkPadrao,
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  rotuloCancel,
                  style: botaoStyle,
                ),
              ),
            _buildButton(
              padrao: botaoOkPadrao,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                rotuloOk,
                style: botaoStyle,
              ),
            ),
          ],
        );
      },
    );
  }

  static _buildButton({
    bool padrao = false,
    void Function()? onPressed,
    required Widget child,
  }) {
    return padrao
        ? ElevatedButton(
            onPressed: onPressed,
            child: child,
          )
        : TextButton(
            onPressed: onPressed,
            child: child,
          );
  }
}
