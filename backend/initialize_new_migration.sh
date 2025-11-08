#!/bin/bash

# Script para criar novas migrações Flyway
# Uso: ./initialize_new_migration.sh

# Diretório de migrações
MIGRATION_DIR="src/main/resources/db/migration"

# Verifica se o diretório existe
if [ ! -d "$MIGRATION_DIR" ]; then
    echo "Erro: Diretório de migrações não encontrado: $MIGRATION_DIR"
    exit 1
fi

# Pergunta o nome da migração
echo -n "Nome da migração: "
read MIGRATION_NAME

# Verifica se foi fornecido um nome
if [ -z "$MIGRATION_NAME" ]; then
    echo "Erro: Nome da migração não pode ser vazio"
    exit 1
fi

# Remove espaços e substitui por underscores
MIGRATION_NAME="${MIGRATION_NAME// /_}"

# Gera timestamp
TIMESTAMP=$(date +%s)

# Nome do arquivo
FILENAME="${MIGRATION_DIR}/V${TIMESTAMP}__${MIGRATION_NAME}.sql"

# Verifica se o arquivo já existe
if [ -f "$FILENAME" ]; then
    echo "Erro: Arquivo já existe: $FILENAME"
    exit 1
fi

# Obtém o nome do autor (git username ou whoami)
GIT_USER=$(git config user.name 2>/dev/null)
if [ -z "$GIT_USER" ]; then
    AUTHOR=$(whoami)
else
    AUTHOR="$GIT_USER"
fi

# Cria o arquivo com cabeçalho
cat > "$FILENAME" << EOF
-- =====================================================
-- Migration: ${MIGRATION_NAME}
-- Author: ${AUTHOR}
-- Created: $(date '+%Y-%m-%d %H:%M:%S')
-- Version: V${TIMESTAMP}
-- =====================================================

EOF

echo "Migração criada: $FILENAME"