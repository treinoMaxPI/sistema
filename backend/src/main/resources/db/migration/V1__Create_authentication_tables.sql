-- =====================================================
-- SCHEMA DE AUTENTICAÇÃO
-- Sistema completo de autenticação com JWT e recuperação
-- =====================================================

-- Tabela: usuarios
-- Armazena informações básicas dos usuários do sistema
CREATE TABLE usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    email_verificado BOOLEAN DEFAULT FALSE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabela: tokens_recuperacao_senha
-- Tokens temporários para resetar senha
CREATE TABLE tokens_recuperacao_senha (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token VARCHAR(255) UNIQUE NOT NULL,
    data_expiracao TIMESTAMP NOT NULL,
    utilizado BOOLEAN DEFAULT FALSE,
    usuario_id UUID NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Tabela: tokens_verificacao_email
-- Tokens para verificação de email no cadastro
CREATE TABLE tokens_verificacao_email (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token VARCHAR(255) UNIQUE NOT NULL,
    data_expiracao TIMESTAMP NOT NULL,
    utilizado BOOLEAN DEFAULT FALSE,
    usuario_id UUID NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- Tabela: refresh_tokens
-- Tokens de atualização para renovar access tokens JWT
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token VARCHAR(255) UNIQUE NOT NULL,
    data_expiracao TIMESTAMP NOT NULL,
    revogado BOOLEAN DEFAULT FALSE,
    usuario_id UUID NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
);

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

-- Índices para tabela usuarios
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_ativo ON usuarios(ativo) WHERE ativo = TRUE;

-- Índices para tokens_recuperacao_senha
CREATE INDEX idx_tokens_recuperacao_token ON tokens_recuperacao_senha(token);
CREATE INDEX idx_tokens_recuperacao_usuario ON tokens_recuperacao_senha(usuario_id);
CREATE INDEX idx_tokens_recuperacao_validos ON tokens_recuperacao_senha(usuario_id, utilizado, data_expiracao) 
    WHERE utilizado = FALSE;

-- Índices para tokens_verificacao_email
CREATE INDEX idx_tokens_verificacao_token ON tokens_verificacao_email(token);
CREATE INDEX idx_tokens_verificacao_usuario ON tokens_verificacao_email(usuario_id);
CREATE INDEX idx_tokens_verificacao_validos ON tokens_verificacao_email(usuario_id, utilizado, data_expiracao) 
    WHERE utilizado = FALSE;

-- Índices para refresh_tokens
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX idx_refresh_tokens_usuario ON refresh_tokens(usuario_id);
CREATE INDEX idx_refresh_tokens_validos ON refresh_tokens(usuario_id, revogado, data_expiracao) 
    WHERE revogado = FALSE;

-- =====================================================
-- TRIGGER PARA ATUALIZAR data_atualizacao
-- =====================================================

CREATE OR REPLACE FUNCTION atualizar_data_atualizacao()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualizar_usuarios
    BEFORE UPDATE ON usuarios
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_data_atualizacao();

-- =====================================================
-- FUNÇÃO PARA LIMPAR TOKENS EXPIRADOS
-- =====================================================

CREATE OR REPLACE FUNCTION limpar_tokens_expirados()
RETURNS void AS $$
BEGIN
    -- Limpar tokens de recuperação de senha expirados
    DELETE FROM tokens_recuperacao_senha 
    WHERE data_expiracao < CURRENT_TIMESTAMP 
       OR (utilizado = TRUE AND data_criacao < CURRENT_TIMESTAMP - INTERVAL '30 days');
    
    -- Limpar tokens de verificação de email expirados
    DELETE FROM tokens_verificacao_email 
    WHERE data_expiracao < CURRENT_TIMESTAMP 
       OR (utilizado = TRUE AND data_criacao < CURRENT_TIMESTAMP - INTERVAL '30 days');
    
    -- Limpar refresh tokens expirados ou revogados
    DELETE FROM refresh_tokens 
    WHERE data_expiracao < CURRENT_TIMESTAMP 
       OR (revogado = TRUE AND data_criacao < CURRENT_TIMESTAMP - INTERVAL '30 days');
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTÁRIOS NAS TABELAS E COLUNAS
-- =====================================================

COMMENT ON TABLE usuarios IS 'Tabela principal de usuários do sistema';
COMMENT ON TABLE tokens_recuperacao_senha IS 'Tokens temporários para recuperação de senha';
COMMENT ON TABLE tokens_verificacao_email IS 'Tokens para verificação de email no cadastro';
COMMENT ON TABLE refresh_tokens IS 'Tokens de atualização para renovação de JWT';

COMMENT ON COLUMN usuarios.senha IS 'Senha criptografada com bcrypt ou argon2';
COMMENT ON COLUMN usuarios.email_verificado IS 'Indica se o email foi verificado via token';
COMMENT ON COLUMN tokens_recuperacao_senha.utilizado IS 'Indica se o token já foi usado (one-time use)';
COMMENT ON COLUMN refresh_tokens.revogado IS 'Permite invalidar tokens antes da expiração';