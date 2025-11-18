-- =====================================================
-- Migration: Add imagem_url column to comunicados
-- Author: automated
-- =====================================================

ALTER TABLE comunicados
    ADD COLUMN IF NOT EXISTS imagem_url VARCHAR(255);

-- Optional index if filtering by presence later
-- CREATE INDEX IF NOT EXISTS idx_comunicados_imagem_url ON comunicados(imagem_url);