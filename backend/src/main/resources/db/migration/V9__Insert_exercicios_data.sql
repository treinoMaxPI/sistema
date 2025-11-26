-- =====================================================
-- INSERÇÃO DE EXERCÍCIOS COM DADOS REAIS
-- Exercícios populares e eficazes para cada grupo muscular
-- =====================================================

-- PEITO
INSERT INTO exercicio (id, nome, descricao, video_url, grupo_muscular) VALUES
(gen_random_uuid(), 'Supino Reto com Barra', 'Deite-se no banco, segure a barra com pegada média e desça até o peito, depois empurre para cima.', NULL, 'PEITO'),
(gen_random_uuid(), 'Supino Inclinado com Halteres', 'Deite-se no banco inclinado a 45°, segure halteres e execute o movimento de supino.', NULL, 'PEITO'),
(gen_random_uuid(), 'Supino Declinado', 'Deite-se no banco declinado e execute o supino com barra ou halteres.', NULL, 'PEITO'),
(gen_random_uuid(), 'Crucifixo com Halteres', 'Deite-se no banco, segure halteres com braços estendidos e abra os braços em movimento de voo.', NULL, 'PEITO'),
(gen_random_uuid(), 'Flexão de Braço', 'Apoie-se no chão com braços estendidos, desça o corpo até quase tocar o chão e empurre de volta.', NULL, 'PEITO'),
(gen_random_uuid(), 'Paralelas para Peito', 'Segure-se nas barras paralelas, incline o tronco para frente e desça o corpo flexionando os braços.', NULL, 'PEITO'),
(gen_random_uuid(), 'Crossover no Cabo', 'Fique entre duas polias, puxe os cabos em direção ao centro do peito em movimento de abraço.', NULL, 'PEITO'),
(gen_random_uuid(), 'Supino com Pegada Fechada', 'Execute o supino reto com pegada mais fechada que o normal para maior ativação do peitoral interno.', NULL, 'PEITO');

-- OMBRO
INSERT INTO exercicio (id, nome, descricao, video_url, grupo_muscular) VALUES
(gen_random_uuid(), 'Desenvolvimento com Halteres', 'Sente-se ou fique em pé, segure halteres na altura dos ombros e empurre para cima.', NULL, 'OMBRO'),
(gen_random_uuid(), 'Elevação Lateral', 'Fique em pé, segure halteres ao lado do corpo e eleve os braços lateralmente até a altura dos ombros.', NULL, 'OMBRO'),
(gen_random_uuid(), 'Elevação Frontal', 'Fique em pé, segure halteres ou barra à frente do corpo e eleve até a altura dos ombros.', NULL, 'OMBRO'),
(gen_random_uuid(), 'Remada Alta', 'Segure uma barra ou halteres, puxe verticalmente até a altura do peito, cotovelos altos.', NULL, 'OMBRO'),
(gen_random_uuid(), 'Desenvolvimento Arnold', 'Sente-se, comece com halteres na frente do peito, rotacione e empurre para cima.', NULL, 'OMBRO'),
(gen_random_uuid(), 'Elevação Lateral Inclinada', 'Deite-se de lado no banco inclinado e eleve o halter lateralmente.', NULL, 'OMBRO'),
(gen_random_uuid(), 'Crucifixo Invertido', 'Deite-se de bruços no banco inclinado e abra os braços com halteres em movimento de voo invertido.', NULL, 'OMBRO'),
(gen_random_uuid(), 'Desenvolvimento Militar', 'Fique em pé, segure a barra na altura dos ombros e empurre verticalmente para cima.', NULL, 'OMBRO');

-- COSTAS
INSERT INTO exercicio (id, nome, descricao, video_url, grupo_muscular) VALUES
(gen_random_uuid(), 'Barra Fixa', 'Segure a barra com pegada aberta, puxe o corpo até o queixo passar da barra e desça controladamente.', NULL, 'COSTAS'),
(gen_random_uuid(), 'Remada Curvada com Barra', 'Incline o tronco, segure a barra e puxe em direção ao abdômen, contraindo as costas.', NULL, 'COSTAS'),
(gen_random_uuid(), 'Puxada Frontal', 'Sente-se no aparelho, puxe a barra em direção ao peito, mantendo o tronco ereto.', NULL, 'COSTAS'),
(gen_random_uuid(), 'Remada Unilateral com Halter', 'Apoie um joelho no banco, segure um halter e puxe em direção ao tronco.', NULL, 'COSTAS'),
(gen_random_uuid(), 'Remada no Cabo Sentado', 'Sente-se no aparelho, puxe o cabo em direção ao abdômen, contraindo as costas.', NULL, 'COSTAS'),
(gen_random_uuid(), 'Puxada com Pegada Invertida', 'Execute a puxada frontal com pegada supinada (palmas voltadas para você).', NULL, 'COSTAS'),
(gen_random_uuid(), 'Remada T', 'Fique sobre o aparelho de remada T, puxe a barra em direção ao peito.', NULL, 'COSTAS'),
(gen_random_uuid(), 'Puxada Atrás da Nuca', 'Sente-se no aparelho e puxe a barra atrás da nuca, mantendo o tronco ereto.', NULL, 'COSTAS'),
(gen_random_uuid(), 'Remada Alta com Barra', 'Segure a barra, puxe verticalmente até a altura do peito, cotovelos altos.', NULL, 'COSTAS'),
(gen_random_uuid(), 'Hiperextensão Lombar', 'Deite-se de bruços no banco de hiperextensão e eleve o tronco contraindo a lombar.', NULL, 'COSTAS');

-- BICEPS
INSERT INTO exercicio (id, nome, descricao, video_url, grupo_muscular) VALUES
(gen_random_uuid(), 'Rosca Direta com Barra', 'Fique em pé, segure a barra com pegada supinada e flexione os braços contraindo o bíceps.', NULL, 'BICEPS'),
(gen_random_uuid(), 'Rosca Alternada com Halteres', 'Fique em pé, segure halteres e flexione um braço de cada vez, alternando os lados.', NULL, 'BICEPS'),
(gen_random_uuid(), 'Rosca Martelo', 'Fique em pé, segure halteres com pegada neutra e flexione os braços mantendo os punhos neutros.', NULL, 'BICEPS'),
(gen_random_uuid(), 'Rosca Concentrada', 'Sente-se no banco, apoie o cotovelo na coxa e flexione o braço isolando o bíceps.', NULL, 'BICEPS'),
(gen_random_uuid(), 'Rosca Scott', 'Sente-se no banco Scott, apoie os braços e execute a rosca isolando o bíceps.', NULL, 'BICEPS'),
(gen_random_uuid(), 'Rosca no Cabo', 'Fique em pé na frente da polia, segure a barra e execute a rosca mantendo tensão constante.', NULL, 'BICEPS'),
(gen_random_uuid(), 'Rosca 21', 'Execute 7 repetições parciais na parte inferior, 7 na superior e 7 completas.', NULL, 'BICEPS'),
(gen_random_uuid(), 'Rosca com Barra W', 'Use uma barra W para maior ativação do bíceps braquial.', NULL, 'BICEPS');

-- TRICEPS
INSERT INTO exercicio (id, nome, descricao, video_url, grupo_muscular) VALUES
(gen_random_uuid(), 'Tríceps Pulley', 'Fique em pé na frente da polia, segure a barra e estenda os braços para baixo.', NULL, 'TRICEPS'),
(gen_random_uuid(), 'Tríceps Testa', 'Deite-se no banco, segure a barra acima da testa e estenda os braços verticalmente.', NULL, 'TRICEPS'),
(gen_random_uuid(), 'Tríceps Coice', 'Incline o tronco, segure um halter e estenda o braço para trás isolando o tríceps.', NULL, 'TRICEPS'),
(gen_random_uuid(), 'Paralelas para Tríceps', 'Segure-se nas barras paralelas, mantenha o tronco ereto e desça o corpo flexionando os braços.', NULL, 'TRICEPS'),
(gen_random_uuid(), 'Mergulho no Banco', 'Apoie as mãos no banco atrás de você, desça o corpo flexionando os braços e empurre de volta.', NULL, 'TRICEPS'),
(gen_random_uuid(), 'Tríceps Francês', 'Deite-se no banco, segure halteres acima do peito e estenda os braços verticalmente.', NULL, 'TRICEPS'),
(gen_random_uuid(), 'Tríceps Corda', 'Use a corda na polia e execute extensões com pegada em V para maior ativação.', NULL, 'TRICEPS'),
(gen_random_uuid(), 'Tríceps Unilateral no Cabo', 'Execute o tríceps pulley com um braço de cada vez para maior isolamento.', NULL, 'TRICEPS');

-- PERNA
INSERT INTO exercicio (id, nome, descricao, video_url, grupo_muscular) VALUES
(gen_random_uuid(), 'Agachamento Livre', 'Fique em pé, desça o corpo flexionando joelhos e quadris até as coxas ficarem paralelas ao chão.', NULL, 'PERNA'),
(gen_random_uuid(), 'Agachamento com Barra', 'Coloque a barra nas costas e execute o agachamento mantendo o tronco ereto.', NULL, 'PERNA'),
(gen_random_uuid(), 'Leg Press 45°', 'Sente-se no aparelho, empurre a plataforma estendendo as pernas e retorne controladamente.', NULL, 'PERNA'),
(gen_random_uuid(), 'Extensão de Pernas', 'Sente-se no aparelho, estenda as pernas contraindo o quadríceps e retorne devagar.', NULL, 'PERNA'),
(gen_random_uuid(), 'Flexão de Pernas', 'Deite-se no aparelho, flexione as pernas contraindo os isquiotibiais e retorne controladamente.', NULL, 'PERNA'),
(gen_random_uuid(), 'Afundo', 'Dê um passo à frente, desça o corpo até o joelho traseiro quase tocar o chão e empurre de volta.', NULL, 'PERNA'),
(gen_random_uuid(), 'Agachamento Búlgaro', 'Apoie o pé traseiro no banco, desça o corpo com a perna da frente e empurre de volta.', NULL, 'PERNA'),
(gen_random_uuid(), 'Hack Squat', 'Fique no aparelho hack squat, desça o corpo e empurre de volta contraindo as pernas.', NULL, 'PERNA'),
(gen_random_uuid(), 'Passada', 'Dê passos largos alternando as pernas, desça o corpo a cada passo e empurre de volta.', NULL, 'PERNA'),
(gen_random_uuid(), 'Cadeira Extensora', 'Sente-se na cadeira extensora e estenda as pernas isolando o quadríceps.', NULL, 'PERNA');

-- GLUTEOS
INSERT INTO exercicio (id, nome, descricao, video_url, grupo_muscular) VALUES
(gen_random_uuid(), 'Elevação Pélvica', 'Deite-se de costas, flexione os joelhos e eleve o quadril contraindo os glúteos.', NULL, 'GLUTEOS'),
(gen_random_uuid(), 'Agachamento Sumô', 'Fique com pernas abertas e pés apontados para fora, desça o corpo mantendo o tronco ereto.', NULL, 'GLUTEOS'),
(gen_random_uuid(), 'Glúteo no Cabo', 'Fique de quatro ou em pé, puxe o cabo para trás estendendo a perna e contraindo o glúteo.', NULL, 'GLUTEOS'),
(gen_random_uuid(), 'Abdução de Quadril', 'Deite-se de lado, eleve a perna superior mantendo o tronco estável.', NULL, 'GLUTEOS'),
(gen_random_uuid(), 'Stiff', 'Fique em pé, segure a barra e incline o tronco mantendo as pernas estendidas, alongando posterior.', NULL, 'GLUTEOS'),
(gen_random_uuid(), 'Elevação Pélvica com Barra', 'Deite-se de costas, coloque a barra sobre o quadril e eleve contraindo os glúteos.', NULL, 'GLUTEOS'),
(gen_random_uuid(), 'Agachamento com Salto', 'Execute o agachamento e no final do movimento impulsione o corpo para cima com um salto.', NULL, 'GLUTEOS'),
(gen_random_uuid(), 'Glúteo no Aparelho', 'Fique no aparelho de glúteo, empurre a plataforma para trás contraindo os glúteos.', NULL, 'GLUTEOS');

-- ABDOMEN
INSERT INTO exercicio (id, nome, descricao, video_url, grupo_muscular) VALUES
(gen_random_uuid(), 'Abdominal Reto', 'Deite-se de costas, flexione os joelhos e eleve o tronco contraindo o abdômen.', NULL, 'ABDOMEN'),
(gen_random_uuid(), 'Prancha', 'Apoie-se nos antebraços e pés, mantenha o corpo alinhado e contraia o core.', NULL, 'ABDOMEN'),
(gen_random_uuid(), 'Abdominal Infra', 'Deite-se de costas, eleve as pernas mantendo os joelhos levemente flexionados.', NULL, 'ABDOMEN'),
(gen_random_uuid(), 'Abdominal Bicicleta', 'Deite-se de costas, simule pedalar no ar alternando os lados e tocando o cotovelo no joelho oposto.', NULL, 'ABDOMEN'),
(gen_random_uuid(), 'Mountain Climber', 'Fique em posição de flexão, alterne trazendo os joelhos em direção ao peito rapidamente.', NULL, 'ABDOMEN'),
(gen_random_uuid(), 'Abdominal Lateral', 'Deite-se de lado, eleve o tronco lateralmente contraindo o oblíquo.', NULL, 'ABDOMEN'),
(gen_random_uuid(), 'Prancha Lateral', 'Apoie-se no antebraço lateral, mantenha o corpo alinhado e contraia o core.', NULL, 'ABDOMEN'),
(gen_random_uuid(), 'Abdominal com Perna Elevada', 'Deite-se de costas com pernas elevadas, eleve o tronco contraindo o abdômen.', NULL, 'ABDOMEN'),
(gen_random_uuid(), 'Russian Twist', 'Sente-se, incline o tronco levemente e rotacione o tronco de um lado para o outro.', NULL, 'ABDOMEN'),
(gen_random_uuid(), 'Abdominal Reverso', 'Deite-se de costas, eleve os joelhos em direção ao peito contraindo o abdômen inferior.', NULL, 'ABDOMEN');

-- BRAÇO (exercícios compostos que trabalham braço completo)
INSERT INTO exercicio (id, nome, descricao, video_url, grupo_muscular) VALUES
(gen_random_uuid(), 'Rosca e Extensão Alternada', 'Execute rosca para bíceps seguida de extensão para tríceps, alternando os braços.', NULL, 'BRAÇO'),
(gen_random_uuid(), 'Flexão Diamante', 'Execute flexão de braço com as mãos formando um diamante, ativando tríceps e peito.', NULL, 'BRAÇO'),
(gen_random_uuid(), 'Flexão com Apoio Inclinado', 'Apoie os pés em elevação e execute flexão para maior ativação dos braços.', NULL, 'BRAÇO');

-- =====================================================
-- INSERÇÃO DE ATIVAÇÕES MUSCULARES
-- =====================================================

-- PEITO
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'PEITO', NULL, e.id
FROM exercicio e
WHERE e.nome IN (
    'Supino Reto com Barra', 'Supino Inclinado com Halteres', 'Supino Declinado',
    'Crucifixo com Halteres', 'Flexão de Braço', 'Paralelas para Peito',
    'Crossover no Cabo', 'Supino com Pegada Fechada'
);

-- OMBRO
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'OMBRO', NULL, e.id
FROM exercicio e
WHERE e.nome IN (
    'Desenvolvimento com Halteres', 'Elevação Lateral', 'Elevação Frontal',
    'Remada Alta', 'Desenvolvimento Arnold', 'Elevação Lateral Inclinada',
    'Crucifixo Invertido', 'Desenvolvimento Militar'
);

-- COSTAS
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'COSTAS', NULL, e.id
FROM exercicio e
WHERE e.nome IN (
    'Barra Fixa', 'Remada Curvada com Barra', 'Puxada Frontal',
    'Remada Unilateral com Halter', 'Remada no Cabo Sentado', 'Puxada com Pegada Invertida',
    'Remada T', 'Puxada Atrás da Nuca', 'Remada Alta com Barra', 'Hiperextensão Lombar'
);

-- BICEPS
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'BICEPS', NULL, e.id
FROM exercicio e
WHERE e.nome IN (
    'Rosca Direta com Barra', 'Rosca Alternada com Halteres', 'Rosca Martelo',
    'Rosca Concentrada', 'Rosca Scott', 'Rosca no Cabo',
    'Rosca 21', 'Rosca com Barra W'
);

-- TRICEPS
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'TRICEPS', NULL, e.id
FROM exercicio e
WHERE e.nome IN (
    'Tríceps Pulley', 'Tríceps Testa', 'Tríceps Coice',
    'Paralelas para Tríceps', 'Mergulho no Banco', 'Tríceps Francês',
    'Tríceps Corda', 'Tríceps Unilateral no Cabo'
);

-- PERNA
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'PERNA', NULL, e.id
FROM exercicio e
WHERE e.nome IN (
    'Agachamento Livre', 'Agachamento com Barra', 'Leg Press 45°',
    'Extensão de Pernas', 'Flexão de Pernas', 'Afundo',
    'Agachamento Búlgaro', 'Hack Squat', 'Passada', 'Cadeira Extensora'
);

-- GLUTEOS
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'GLUTEOS', NULL, e.id
FROM exercicio e
WHERE e.nome IN (
    'Elevação Pélvica', 'Agachamento Sumô', 'Glúteo no Cabo',
    'Abdução de Quadril', 'Stiff', 'Elevação Pélvica com Barra',
    'Agachamento com Salto', 'Glúteo no Aparelho'
);

-- ABDOMEN
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'ABDOMEN', NULL, e.id
FROM exercicio e
WHERE e.nome IN (
    'Abdominal Reto', 'Prancha', 'Abdominal Infra',
    'Abdominal Bicicleta', 'Mountain Climber', 'Abdominal Lateral',
    'Prancha Lateral', 'Abdominal com Perna Elevada', 'Russian Twist', 'Abdominal Reverso'
);

-- BRAÇO (exercícios compostos)
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'BRAÇO', NULL, e.id
FROM exercicio e
WHERE e.nome IN (
    'Rosca e Extensão Alternada', 'Flexão Diamante', 'Flexão com Apoio Inclinado'
);

-- Exercícios que ativam múltiplos grupos musculares
-- Supino também ativa tríceps e ombro
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'TRICEPS', NULL, e.id
FROM exercicio e
WHERE e.nome IN ('Supino Reto com Barra', 'Supino Inclinado com Halteres', 'Supino Declinado', 'Supino com Pegada Fechada');

INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'OMBRO', NULL, e.id
FROM exercicio e
WHERE e.nome IN ('Supino Reto com Barra', 'Supino Inclinado com Halteres', 'Supino Declinado', 'Supino com Pegada Fechada');

-- Barra fixa e puxadas também ativam bíceps
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'BICEPS', NULL, e.id
FROM exercicio e
WHERE e.nome IN ('Barra Fixa', 'Puxada Frontal', 'Puxada com Pegada Invertida', 'Puxada Atrás da Nuca');

-- Remadas também ativam bíceps
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'BICEPS', NULL, e.id
FROM exercicio e
WHERE e.nome IN ('Remada Curvada com Barra', 'Remada Unilateral com Halter', 'Remada no Cabo Sentado', 'Remada T', 'Remada Alta com Barra');

-- Agachamentos também ativam glúteos
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'GLUTEOS', NULL, e.id
FROM exercicio e
WHERE e.nome IN ('Agachamento Livre', 'Agachamento com Barra', 'Leg Press 45°', 'Afundo', 'Agachamento Búlgaro', 'Hack Squat', 'Passada');

-- Flexões também ativam tríceps e ombro
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'TRICEPS', NULL, e.id
FROM exercicio e
WHERE e.nome IN ('Flexão de Braço', 'Flexão Diamante', 'Flexão com Apoio Inclinado');

INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'OMBRO', NULL, e.id
FROM exercicio e
WHERE e.nome IN ('Flexão de Braço', 'Flexão Diamante', 'Flexão com Apoio Inclinado');

-- Stiff também ativa perna (isquiotibiais)
INSERT INTO ativacao_muscular (id, grupo_muscular, peso, exercicio_id)
SELECT gen_random_uuid(), 'PERNA', NULL, e.id
FROM exercicio e
WHERE e.nome = 'Stiff';

