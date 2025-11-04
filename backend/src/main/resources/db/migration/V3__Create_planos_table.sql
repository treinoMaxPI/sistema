-- =====================================================
-- TABELA: planos
-- Sistema de planos de assinatura
-- =====================================================

-- Tabela: planos
-- Armazena os planos de assinatura disponíveis
CREATE TABLE planos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(1000) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    preco_centavos INTEGER NOT NULL DEFAULT 0,
    criado_por UUID NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (criado_por) REFERENCES usuarios(id) ON DELETE RESTRICT
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índice para busca por nome
CREATE INDEX idx_planos_nome ON planos(nome);

-- Índice para planos ativos
CREATE INDEX idx_planos_ativos ON planos(ativo) WHERE ativo = TRUE;

-- Índice para ordenação por preço
CREATE INDEX idx_planos_preco ON planos(preco_centavos);

-- Índice para busca por criador
CREATE INDEX idx_planos_criado_por ON planos(criado_por);

-- =====================================================
-- TRIGGER PARA ATUALIZAR data_atualizacao
-- =====================================================

CREATE TRIGGER trigger_atualizar_planos
    BEFORE UPDATE ON planos
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_data_atualizacao();

-- =====================================================
-- COMENTÁRIOS NAS TABELAS E COLUNAS
-- =====================================================

COMMENT ON TABLE planos IS 'Tabela de planos de assinatura do sistema';

COMMENT ON COLUMN planos.nome IS 'Nome do plano (ex: Básico, Premium)';
COMMENT ON COLUMN planos.descricao IS 'Descrição detalhada do plano e benefícios';
COMMENT ON COLUMN planos.ativo IS 'Indica se o plano está disponível para contratação';
COMMENT ON COLUMN planos.preco_centavos IS 'Preço do plano em centavos (para evitar problemas com ponto flutuante)';
COMMENT ON COLUMN planos.criado_por IS 'ID do usuário que criou o plano (referência à tabela usuarios)';
COMMENT ON COLUMN planos.data_criacao IS 'Data de criação do registro';
COMMENT ON COLUMN planos.data_atualizacao IS 'Data da última atualização do registro';