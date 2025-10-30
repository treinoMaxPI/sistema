-- Create authentication tables

-- Table: usuario
CREATE TABLE usuario (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    email_verificado BOOLEAN DEFAULT FALSE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: token_recuperacao_senha
CREATE TABLE token_recuperacao_senha (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token VARCHAR(255) UNIQUE NOT NULL,
    data_expiracao TIMESTAMP NOT NULL,
    utilizado BOOLEAN DEFAULT FALSE,
    usuario_id UUID NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE
);

-- Table: token_verificacao_email
CREATE TABLE token_verificacao_email (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token VARCHAR(255) UNIQUE NOT NULL,
    data_expiracao TIMESTAMP NOT NULL,
    utilizado BOOLEAN DEFAULT FALSE,
    usuario_id UUID NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE
);

-- Table: refresh_token
CREATE TABLE refresh_token (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    token VARCHAR(255) UNIQUE NOT NULL,
    data_expiracao TIMESTAMP NOT NULL,
    revogado BOOLEAN DEFAULT FALSE,
    usuario_id UUID NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_usuario_email ON usuario(email);
CREATE INDEX idx_token_recuperacao_senha_token ON token_recuperacao_senha(token);
CREATE INDEX idx_token_recuperacao_senha_usuario ON token_recuperacao_senha(usuario_id);
CREATE INDEX idx_token_verificacao_email_token ON token_verificacao_email(token);
CREATE INDEX idx_token_verificacao_email_usuario ON token_verificacao_email(usuario_id);
CREATE INDEX idx_refresh_token_token ON refresh_token(token);
CREATE INDEX idx_refresh_token_usuario ON refresh_token(usuario_id);