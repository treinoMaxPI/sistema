-- =====================================================
-- MIGRATION: Adicionar plano_id à tabela usuarios
-- =====================================================

-- Adicionar coluna plano_id à tabela usuarios
ALTER TABLE usuarios 
ADD COLUMN plano_id UUID;

-- Adicionar chave estrangeira para a tabela planos
ALTER TABLE usuarios 
ADD CONSTRAINT fk_usuarios_plano 
FOREIGN KEY (plano_id) REFERENCES planos(id) ON DELETE SET NULL;

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índice para busca por plano
CREATE INDEX idx_usuarios_plano_id ON usuarios(plano_id);

-- =====================================================
-- COMENTÁRIOS NAS COLUNAS
-- =====================================================

COMMENT ON COLUMN usuarios.plano_id IS 'ID do plano de assinatura do usuário (opcional)';