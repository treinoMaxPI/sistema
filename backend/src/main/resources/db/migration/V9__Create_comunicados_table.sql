-- =====================================================
-- TABELA: comunicados (Mural da Academia)
-- Avisos e comunicados publicados pela administração
-- =====================================================

CREATE TABLE comunicados (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo VARCHAR(200) NOT NULL,
    mensagem TEXT NOT NULL,
    publicado BOOLEAN NOT NULL DEFAULT TRUE,
    criado_por UUID NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (criado_por) REFERENCES usuarios(id) ON DELETE RESTRICT
);

-- Índices úteis
CREATE INDEX idx_comunicados_publicado ON comunicados(publicado);
CREATE INDEX idx_comunicados_criado_por ON comunicados(criado_por);
CREATE INDEX idx_comunicados_data_criacao ON comunicados(data_criacao);

-- Trigger para atualizar data_atualizacao
CREATE TRIGGER trigger_atualizar_comunicados
    BEFORE UPDATE ON comunicados
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_data_atualizacao();

-- Comentários
COMMENT ON TABLE comunicados IS 'Comunicados/avisos publicados no mural da academia';
COMMENT ON COLUMN comunicados.titulo IS 'Título do comunicado';
COMMENT ON COLUMN comunicados.mensagem IS 'Conteúdo do comunicado';
COMMENT ON COLUMN comunicados.publicado IS 'Indica se está visível aos usuários';
COMMENT ON COLUMN comunicados.criado_por IS 'Usuário criador do comunicado';