-- Adiciona campo para controlar se a inadimplência já foi processada
ALTER TABLE planos_cobrancas
ADD COLUMN inadimplencia_processada BOOLEAN NOT NULL DEFAULT FALSE;

-- Comentário opcional (melhor documentação no banco)
COMMENT ON COLUMN planos_cobrancas.inadimplencia_processada IS 'Indica se a inadimplência da cobrança já foi processada.';
