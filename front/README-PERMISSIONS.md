# Problema de Permissões no Flutter

Se você encontrar o erro:
```
Flutter failed to delete a directory at ".../windows/flutter/ephemeral/.plugin_symlinks"
```

## Solução Rápida

Execute o script de correção de permissões (requer sudo):
```bash
sudo ./fix-permissions.sh
```

Depois execute normalmente:
```bash
./run.sh
```

## Solução Alternativa (se não tiver sudo)

O erro não impede a execução do app web. Você pode simplesmente ignorá-lo e continuar usando o app normalmente.

O diretório `windows/` não é necessário para rodar o Flutter web no Linux.
