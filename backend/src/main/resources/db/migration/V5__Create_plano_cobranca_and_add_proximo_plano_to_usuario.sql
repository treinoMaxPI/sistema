-- Criação da tabela de cobranças de planos e adição da coluna proximo_plano_id em usuario
ALTER TABLE usuarios
ADD COLUMN proximo_plano_id UUID NULL,
ADD CONSTRAINT fk_usuario_proximo_plano
    FOREIGN KEY (proximo_plano_id)
    REFERENCES planos(id)
    ON DELETE SET NULL;

CREATE TABLE planos_cobrancas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    usuario_id UUID NOT NULL,
    plano_id UUID NOT NULL,

    mes_referencia VARCHAR(7) NOT NULL, -- formato YYYY-MM
    valor_centavos INTEGER NOT NULL,

    pago BOOLEAN NOT NULL DEFAULT FALSE,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE NULL,

    observacoes VARCHAR(500) NULL,

    data_criacao TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'America/Sao_Paulo'),
    data_atualizacao TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'America/Sao_Paulo'),

    CONSTRAINT fk_plano_cobranca_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_plano_cobranca_plano FOREIGN KEY (plano_id) REFERENCES planos(id) ON DELETE CASCADE,
    CONSTRAINT uq_plano_cobranca_usuario_mes UNIQUE (usuario_id, mes_referencia)
);

CREATE OR REPLACE FUNCTION update_planos_cobrancas_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = (NOW() AT TIME ZONE 'America/Sao_Paulo');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_planos_cobrancas_timestamp
BEFORE UPDATE ON planos_cobrancas
FOR EACH ROW
EXECUTE FUNCTION update_planos_cobrancas_timestamp();
