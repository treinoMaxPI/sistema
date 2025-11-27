#!/bin/bash
export PATH="$HOME/flutter/bin:$PATH"

# Limpar cache do Flutter (ignora erros de permissão no windows)
flutter pub get 2>&1 | grep -v "Flutter failed to delete" || true

# Rodar o app web (o erro de permissão no windows não afeta a execução web)
flutter run -d web-server --web-port=4200 --web-hostname=0.0.0.0 2>&1 | grep -v "Flutter failed to delete" || {
    # Se ainda houver problemas, tentar novamente
    echo "Tentando novamente..."
    flutter run -d web-server --web-port=4200 --web-hostname=0.0.0.0
}
