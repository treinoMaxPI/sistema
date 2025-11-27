-- =====================================================
-- Migration: Adicionar último treino ao usuário e criar tabela de execuções
-- =====================================================

-- Adicionar coluna ultimo_treino_id à tabela usuarios
ALTER TABLE usuarios 
ADD COLUMN ultimo_treino_id UUID;

-- Adicionar chave estrangeira para a tabela treino
ALTER TABLE usuarios 
ADD CONSTRAINT fk_usuarios_ultimo_treino 
FOREIGN KEY (ultimo_treino_id) REFERENCES treino(id) ON DELETE SET NULL;

-- Índice para busca por último treino
CREATE INDEX idx_usuarios_ultimo_treino_id ON usuarios(ultimo_treino_id);

-- =====================================================
-- Tabela: execucoes_treino
-- Armazena o histórico de execuções de treinos pelos alunos
-- =====================================================

CREATE TABLE execucoes_treino (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    treino_id UUID NOT NULL,
    usuario_id UUID NOT NULL,
    data_inicio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_fim TIMESTAMP,
    finalizada BOOLEAN NOT NULL DEFAULT FALSE,
    duracao_segundos INTEGER,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_execucoes_treino_treino 
        FOREIGN KEY (treino_id) 
        REFERENCES treino(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_execucoes_treino_usuario 
        FOREIGN KEY (usuario_id) 
        REFERENCES usuarios(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Índices para melhorar performance
CREATE INDEX idx_execucoes_treino_treino_id ON execucoes_treino(treino_id);
CREATE INDEX idx_execucoes_treino_usuario_id ON execucoes_treino(usuario_id);
CREATE INDEX idx_execucoes_treino_data_inicio ON execucoes_treino(data_inicio);
CREATE INDEX idx_execucoes_treino_finalizada ON execucoes_treino(finalizada);
CREATE INDEX idx_execucoes_treino_usuario_finalizada ON execucoes_treino(usuario_id, finalizada);

-- Comentários
COMMENT ON COLUMN usuarios.ultimo_treino_id IS 'ID do último treino que o usuário iniciou (ainda não finalizado)';
COMMENT ON TABLE execucoes_treino IS 'Histórico de execuções de treinos pelos alunos';
COMMENT ON COLUMN execucoes_treino.treino_id IS 'Referência para o treino executado';
COMMENT ON COLUMN execucoes_treino.usuario_id IS 'Referência para o usuário que executou o treino';
COMMENT ON COLUMN execucoes_treino.data_inicio IS 'Data e hora de início da execução';
COMMENT ON COLUMN execucoes_treino.data_fim IS 'Data e hora de finalização da execução (null se ainda não finalizado)';
COMMENT ON COLUMN execucoes_treino.finalizada IS 'Indica se o treino foi finalizado';
COMMENT ON COLUMN execucoes_treino.duracao_segundos IS 'Duração total do treino em segundos (calculado ao finalizar)';

