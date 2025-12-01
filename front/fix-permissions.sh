#!/bin/bash
# Script para corrigir permissões do diretório Flutter
# Execute com: sudo ./fix-permissions.sh

echo "Corrigindo permissões do diretório Flutter..."

if [ -d "windows/flutter/ephemeral" ]; then
    echo "Removendo diretório windows/flutter/ephemeral..."
    rm -rf windows/flutter/ephemeral
    echo "Diretório removido com sucesso!"
fi

if [ -d "windows" ]; then
    echo "Corrigindo permissões do diretório windows..."
    chown -R $SUDO_USER:$SUDO_USER windows/
    echo "Permissões corrigidas!"
fi

echo "Limpeza concluída! Agora você pode rodar ./run.sh normalmente."

