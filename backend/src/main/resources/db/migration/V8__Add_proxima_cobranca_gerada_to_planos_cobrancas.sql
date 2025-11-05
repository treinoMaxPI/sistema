-- Adiciona campo para controlar se a próxima cobrança já foi gerada
ALTER TABLE planos_cobrancas
ADD COLUMN proxima_cobranca_gerada BOOLEAN NOT NULL DEFAULT FALSE;

-- Comentário opcional (melhor documentação no banco)
COMMENT ON COLUMN planos_cobrancas.proxima_cobranca_gerada IS 'Indica se a próxima cobrança já foi gerada.';
