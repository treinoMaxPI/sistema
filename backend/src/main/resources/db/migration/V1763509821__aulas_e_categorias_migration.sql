-- Migration: Criar tabela categorias e tabela de relacionamento
-- Database: PostgreSQL

-- 1. Criar tabela categorias
CREATE TABLE categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    criado_por UUID NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    CONSTRAINT fk_categorias_criado_por 
        FOREIGN KEY (criado_por) 
        REFERENCES usuarios(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- 2. Criar tabela de relacionamento ManyToMany (categorias_planos)
CREATE TABLE categorias_planos (
    categoria_id UUID NOT NULL,
    plano_id UUID NOT NULL,
    
    -- Primary Key composta
    PRIMARY KEY (categoria_id, plano_id),
    
    -- Foreign Keys
    CONSTRAINT fk_categorias_planos_categoria 
        FOREIGN KEY (categoria_id) 
        REFERENCES categorias(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_categorias_planos_plano 
        FOREIGN KEY (plano_id) 
        REFERENCES planos(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Índices para tabela categorias
CREATE INDEX idx_categorias_nome ON categorias(nome);
CREATE INDEX idx_categorias_criado_por ON categorias(criado_por);
CREATE INDEX idx_categorias_data_criacao ON categorias(data_criacao);

-- Índices para tabela categorias_planos (relacionamento)
CREATE INDEX idx_categorias_planos_categoria ON categorias_planos(categoria_id);
CREATE INDEX idx_categorias_planos_plano ON categorias_planos(plano_id);

-- Comentários na tabela categorias
COMMENT ON TABLE categorias IS 'Tabela de categorias de planos';
COMMENT ON COLUMN categorias.id IS 'Identificador único da categoria';
COMMENT ON COLUMN categorias.nome IS 'Nome da categoria (3-100 caracteres)';
COMMENT ON COLUMN categorias.criado_por IS 'Usuário que criou a categoria';
COMMENT ON COLUMN categorias.data_criacao IS 'Data e hora de criação do registro';
COMMENT ON COLUMN categorias.data_atualizacao IS 'Data e hora da última atualização';

-- Comentários na tabela categorias_planos
COMMENT ON TABLE categorias_planos IS 'Tabela de relacionamento ManyToMany entre categorias e planos';
COMMENT ON COLUMN categorias_planos.categoria_id IS 'Referência para a categoria';
COMMENT ON COLUMN categorias_planos.plano_id IS 'Referência para o plano';

-- Trigger para atualizar data_atualizacao automaticamente
CREATE OR REPLACE FUNCTION update_categorias_data_atualizacao()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_categorias_data_atualizacao
    BEFORE UPDATE ON categorias
    FOR EACH ROW
    EXECUTE FUNCTION update_categorias_data_atualizacao();

    -- Migration: Criar tabela aulas
-- Database: PostgreSQL

CREATE TABLE aulas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo VARCHAR(100) NOT NULL,
    descricao VARCHAR(1000) NOT NULL,
    data TIMESTAMP NOT NULL,
    duracao INTEGER NOT NULL DEFAULT 0,
    usuario_personal_id UUID NOT NULL,
    categoria_id UUID NOT NULL,
    criado_por UUID NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_aulas_usuario_personal 
        FOREIGN KEY (usuario_personal_id) 
        REFERENCES usuarios(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_aulas_categoria 
        FOREIGN KEY (categoria_id) 
        REFERENCES categorias(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_aulas_criado_por 
        FOREIGN KEY (criado_por) 
        REFERENCES usuarios(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Índices para melhorar performance
CREATE INDEX idx_aulas_titulo ON aulas(titulo);
CREATE INDEX idx_aulas_data ON aulas(data);
CREATE INDEX idx_aulas_usuario_personal ON aulas(usuario_personal_id);
CREATE INDEX idx_aulas_categoria ON aulas(categoria_id);
CREATE INDEX idx_aulas_criado_por ON aulas(criado_por);
CREATE INDEX idx_aulas_data_criacao ON aulas(data_criacao);

-- Índice composto para consultas comuns (aulas por personal e data)
CREATE INDEX idx_aulas_personal_data ON aulas(usuario_personal_id, data);

-- Comentários na tabela e colunas
COMMENT ON TABLE aulas IS 'Tabela de aulas ministradas pelos personals';
COMMENT ON COLUMN aulas.id IS 'Identificador único da aula';
COMMENT ON COLUMN aulas.titulo IS 'Título da aula (3-100 caracteres)';
COMMENT ON COLUMN aulas.descricao IS 'Descrição detalhada da aula (10-1000 caracteres)';
COMMENT ON COLUMN aulas.data IS 'Data e hora da aula';
COMMENT ON COLUMN aulas.duracao IS 'Duração da aula em minutos';
COMMENT ON COLUMN aulas.usuario_personal_id IS 'Personal trainer responsável pela aula';
COMMENT ON COLUMN aulas.categoria_id IS 'Categoria da aula';
COMMENT ON COLUMN aulas.criado_por IS 'Usuário que criou o registro da aula';
COMMENT ON COLUMN aulas.data_criacao IS 'Data e hora de criação do registro';
COMMENT ON COLUMN aulas.data_atualizacao IS 'Data e hora da última atualização';

-- Trigger para atualizar data_atualizacao automaticamente
CREATE OR REPLACE FUNCTION update_aulas_data_atualizacao()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_aulas_data_atualizacao
    BEFORE UPDATE ON aulas
    FOR EACH ROW
    EXECUTE FUNCTION update_aulas_data_atualizacao();