-- =====================================================
-- Migration: migration_aulas_categorias_agendamentos
-- Author: AugustoMorais222
-- Created: 2025-11-18 21:20:37
-- Version: V1763511637
-- =====================================================

-- Migration: Criar tabela agendamentos
-- Database: PostgreSQL

CREATE TABLE agendamentos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    aula_id UUID NOT NULL,
    recorrente BOOLEAN NOT NULL,
    horario_recorrente INTEGER NOT NULL,
    dia_recorrente INTEGER NOT NULL,
    data_exata TIMESTAMP NOT NULL,
    
    -- Foreign Key
    CONSTRAINT fk_agendamentos_aula 
        FOREIGN KEY (aula_id) 
        REFERENCES aulas(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    -- Constraints de validação
    CONSTRAINT chk_dia_recorrente_range 
        CHECK (dia_recorrente >= 1 AND dia_recorrente <= 7)
);

-- Índices para melhorar performance
CREATE INDEX idx_agendamentos_aula ON agendamentos(aula_id);
CREATE INDEX idx_agendamentos_recorrente ON agendamentos(recorrente);
CREATE INDEX idx_agendamentos_data_exata ON agendamentos(data_exata);
CREATE INDEX idx_agendamentos_dia_recorrente ON agendamentos(dia_recorrente);

-- Índice composto para consultas de agendamentos recorrentes
CREATE INDEX idx_agendamentos_recorrente_dia ON agendamentos(recorrente, dia_recorrente) 
    WHERE recorrente = true;

-- Comentários na tabela e colunas
COMMENT ON TABLE agendamentos IS 'Tabela de agendamentos das aulas';
COMMENT ON COLUMN agendamentos.id IS 'Identificador único do agendamento';
COMMENT ON COLUMN agendamentos.aula_id IS 'Referência para a aula agendada';
COMMENT ON COLUMN agendamentos.recorrente IS 'Indica se o agendamento é recorrente';
COMMENT ON COLUMN agendamentos.horario_recorrente IS 'Horário da recorrência (provavelmente em minutos ou hora do dia)';
COMMENT ON COLUMN agendamentos.dia_recorrente IS 'Dia da semana da recorrência (1=Domingo até 7=Sábado)';
COMMENT ON COLUMN agendamentos.data_exata IS 'Data e hora exata do agendamento';