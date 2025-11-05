-- Criação da tabela de tarefas executadas
CREATE TABLE tarefas_executadas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tipo VARCHAR(100) NOT NULL,
    sucesso BOOLEAN NOT NULL,
    mensagem_erro VARCHAR(1000),
    data_hora_execucao TIMESTAMP NOT NULL DEFAULT NOW(),
    dia_execucao DATE NOT NULL
);

-- Comentários para documentação no banco (opcional, mas útil)
COMMENT ON TABLE tarefas_executadas IS 'Registra execuções de tarefas automáticas do sistema.';
COMMENT ON COLUMN tarefas_executadas.tipo IS 'Tipo da tarefa executada (ex: MENSAL_VERIFICAR_PLANOS).';
COMMENT ON COLUMN tarefas_executadas.sucesso IS 'Indica se a execução foi bem-sucedida.';
COMMENT ON COLUMN tarefas_executadas.mensagem_erro IS 'Mensagem de erro (limitada a 1000 caracteres).';
COMMENT ON COLUMN tarefas_executadas.data_hora_execucao IS 'Data e hora da execução.';
COMMENT ON COLUMN tarefas_executadas.dia_execucao IS 'Dia da execução, considerando fuso horário de São Paulo.';

-- Index para consultas por data
CREATE INDEX idx_tarefas_executadas_dia_execucao ON tarefas_executadas (dia_execucao);
CREATE INDEX idx_tarefas_executadas_tipo ON tarefas_executadas (tipo);
