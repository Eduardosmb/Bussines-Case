-- Script para popular o banco de dados com 50 usuários realistas
-- IMPORTANTE: Execute este script no SQL Editor do Supabase
-- Estrutura: 1 pioneiro + 49 referenciados = 50 usuários total

-- MATEMÁTICA QUE BATE:
-- 1 super influencer: 12 referrals
-- 2 grandes influencers: 7 referrals cada = 14 total  
-- 3 médios influencers: 4 referrals cada = 12 total
-- 4 pequenos influencers: 2 referrals cada = 8 total
-- 3 iniciantes: 1 referral cada = 3 total
-- 36 passivos: 0 referrals = 0 total
-- TOTAL REFERRALS: 12+14+12+8+3 = 49 ✅
-- TOTAL REFERENCIADOS: 49 ✅ (matemática perfeita!)

-- Limpar dados existentes (opcional)
-- DELETE FROM public.users WHERE email LIKE '%@gmail.com' AND is_admin = FALSE;

-- ==================== USUÁRIO PIONEIRO (não foi referenciado) ====================
INSERT INTO public.users (id, email, first_name, last_name, referral_code, total_referrals, total_earnings, is_admin, created_at) VALUES 
(gen_random_uuid(), 'marcos.antonio@gmail.com', 'Marcos', 'Antonio', 'MARC001', 12, 625.0, FALSE, NOW() - INTERVAL '30 days');

-- ==================== SUPER INFLUENCER (12 referrals) ====================
-- Usuários referenciados por Marcos
INSERT INTO public.users (id, email, first_name, last_name, referral_code, referred_by, total_referrals, total_earnings, is_admin, created_at) VALUES 
(gen_random_uuid(), 'ana.silva@gmail.com', 'Ana', 'Silva', 'ANA0002', 'MARC001', 7, 375.0, FALSE, NOW() - INTERVAL '28 days'),
(gen_random_uuid(), 'bruno.santos@gmail.com', 'Bruno', 'Santos', 'BRUN003', 'MARC001', 7, 375.0, FALSE, NOW() - INTERVAL '27 days'),
(gen_random_uuid(), 'carla.oliveira@gmail.com', 'Carla', 'Oliveira', 'CARL004', 'MARC001', 4, 225.0, FALSE, NOW() - INTERVAL '26 days'),
(gen_random_uuid(), 'diego.costa@gmail.com', 'Diego', 'Costa', 'DIEG005', 'MARC001', 4, 225.0, FALSE, NOW() - INTERVAL '25 days'),
(gen_random_uuid(), 'elena.ferreira@gmail.com', 'Elena', 'Ferreira', 'ELEN006', 'MARC001', 4, 225.0, FALSE, NOW() - INTERVAL '24 days'),
(gen_random_uuid(), 'felipe.almeida@gmail.com', 'Felipe', 'Almeida', 'FELI007', 'MARC001', 2, 125.0, FALSE, NOW() - INTERVAL '23 days'),
(gen_random_uuid(), 'gabriela.lima@gmail.com', 'Gabriela', 'Lima', 'GABR008', 'MARC001', 2, 125.0, FALSE, NOW() - INTERVAL '22 days'),
(gen_random_uuid(), 'henrique.rodrigues@gmail.com', 'Henrique', 'Rodrigues', 'HENR009', 'MARC001', 2, 125.0, FALSE, NOW() - INTERVAL '21 days'),
(gen_random_uuid(), 'isabela.martins@gmail.com', 'Isabela', 'Martins', 'ISAB010', 'MARC001', 2, 125.0, FALSE, NOW() - INTERVAL '20 days'),
(gen_random_uuid(), 'joao.souza@gmail.com', 'João', 'Souza', 'JOAO011', 'MARC001', 1, 75.0, FALSE, NOW() - INTERVAL '19 days'),
(gen_random_uuid(), 'karen.pereira@gmail.com', 'Karen', 'Pereira', 'KARE012', 'MARC001', 1, 75.0, FALSE, NOW() - INTERVAL '18 days'),
(gen_random_uuid(), 'lucas.barbosa@gmail.com', 'Lucas', 'Barbosa', 'LUCA013', 'MARC001', 1, 75.0, FALSE, NOW() - INTERVAL '17 days');

-- ==================== GRANDES INFLUENCERS (7 referrals cada) ====================
-- Usuários referenciados por Ana (7)
INSERT INTO public.users (id, email, first_name, last_name, referral_code, referred_by, total_referrals, total_earnings, is_admin, created_at) VALUES 
(gen_random_uuid(), 'marina.gomes@gmail.com', 'Marina', 'Gomes', 'MARI014', 'ANA0002', 0, 25.0, FALSE, NOW() - INTERVAL '16 days'),
(gen_random_uuid(), 'nicolas.ribeiro@gmail.com', 'Nicolas', 'Ribeiro', 'NICO015', 'ANA0002', 0, 25.0, FALSE, NOW() - INTERVAL '15 days'),
(gen_random_uuid(), 'olivia.carvalho@gmail.com', 'Olivia', 'Carvalho', 'OLIV016', 'ANA0002', 0, 25.0, FALSE, NOW() - INTERVAL '14 days'),
(gen_random_uuid(), 'paulo.vieira@gmail.com', 'Paulo', 'Vieira', 'PAUL017', 'ANA0002', 0, 25.0, FALSE, NOW() - INTERVAL '13 days'),
(gen_random_uuid(), 'quiteria.nunes@gmail.com', 'Quitéria', 'Nunes', 'QUIT018', 'ANA0002', 0, 25.0, FALSE, NOW() - INTERVAL '12 days'),
(gen_random_uuid(), 'rodrigo.castro@gmail.com', 'Rodrigo', 'Castro', 'RODR019', 'ANA0002', 0, 25.0, FALSE, NOW() - INTERVAL '11 days'),
(gen_random_uuid(), 'sabrina.moreira@gmail.com', 'Sabrina', 'Moreira', 'SABR020', 'ANA0002', 0, 25.0, FALSE, NOW() - INTERVAL '10 days');

-- Usuários referenciados por Bruno (7)
INSERT INTO public.users (id, email, first_name, last_name, referral_code, referred_by, total_referrals, total_earnings, is_admin, created_at) VALUES 
(gen_random_uuid(), 'thiago.teixeira@gmail.com', 'Thiago', 'Teixeira', 'THIA021', 'BRUN003', 0, 25.0, FALSE, NOW() - INTERVAL '9 days'),
(gen_random_uuid(), 'ursula.freitas@gmail.com', 'Ursula', 'Freitas', 'URSU022', 'BRUN003', 0, 25.0, FALSE, NOW() - INTERVAL '8 days'),
(gen_random_uuid(), 'vinicius.lopes@gmail.com', 'Vinicius', 'Lopes', 'VINI023', 'BRUN003', 0, 25.0, FALSE, NOW() - INTERVAL '7 days'),
(gen_random_uuid(), 'wanda.campos@gmail.com', 'Wanda', 'Campos', 'WAND024', 'BRUN003', 0, 25.0, FALSE, NOW() - INTERVAL '6 days'),
(gen_random_uuid(), 'xavier.monteiro@gmail.com', 'Xavier', 'Monteiro', 'XAVI025', 'BRUN003', 0, 25.0, FALSE, NOW() - INTERVAL '5 days'),
(gen_random_uuid(), 'yasmin.cardoso@gmail.com', 'Yasmin', 'Cardoso', 'YASM026', 'BRUN003', 0, 25.0, FALSE, NOW() - INTERVAL '4 days'),
(gen_random_uuid(), 'zeca.mendes@gmail.com', 'Zeca', 'Mendes', 'ZECA027', 'BRUN003', 0, 25.0, FALSE, NOW() - INTERVAL '3 days');

-- ==================== MÉDIOS INFLUENCERS (4 referrals cada) ====================
-- Usuários referenciados por Carla (4)
INSERT INTO public.users (id, email, first_name, last_name, referral_code, referred_by, total_referrals, total_earnings, is_admin, created_at) VALUES 
(gen_random_uuid(), 'amanda.rocha@gmail.com', 'Amanda', 'Rocha', 'AMAN028', 'CARL004', 0, 25.0, FALSE, NOW() - INTERVAL '2 days'),
(gen_random_uuid(), 'bernardo.pinto@gmail.com', 'Bernardo', 'Pinto', 'BERN029', 'CARL004', 0, 25.0, FALSE, NOW() - INTERVAL '1 day'),
(gen_random_uuid(), 'camila.azevedo@gmail.com', 'Camila', 'Azevedo', 'CAMI030', 'CARL004', 0, 25.0, FALSE, NOW() - INTERVAL '12 hours'),
(gen_random_uuid(), 'danilo.nogueira@gmail.com', 'Danilo', 'Nogueira', 'DANI031', 'CARL004', 0, 25.0, FALSE, NOW() - INTERVAL '6 hours');

-- Usuários referenciados por Diego (4)  
INSERT INTO public.users (id, email, first_name, last_name, referral_code, referred_by, total_referrals, total_earnings, is_admin, created_at) VALUES 
(gen_random_uuid(), 'elisa.batista@gmail.com', 'Elisa', 'Batista', 'ELIS032', 'DIEG005', 0, 25.0, FALSE, NOW() - INTERVAL '3 hours'),
(gen_random_uuid(), 'fabricio.torres@gmail.com', 'Fabricio', 'Torres', 'FABR033', 'DIEG005', 0, 25.0, FALSE, NOW() - INTERVAL '2 hours'),
(gen_random_uuid(), 'giulia.correa@gmail.com', 'Giulia', 'Correa', 'GIUL034', 'DIEG005', 0, 25.0, FALSE, NOW() - INTERVAL '1 hour'),
(gen_random_uuid(), 'heitor.melo@gmail.com', 'Heitor', 'Melo', 'HEIT035', 'DIEG005', 0, 25.0, FALSE, NOW() - INTERVAL '30 minutes');

-- Usuários referenciados por Elena (4)
INSERT INTO public.users (id, email, first_name, last_name, referral_code, referred_by, total_referrals, total_earnings, is_admin, created_at) VALUES 
(gen_random_uuid(), 'iris.fonseca@gmail.com', 'Iris', 'Fonseca', 'IRIS036', 'ELEN006', 0, 25.0, FALSE, NOW() - INTERVAL '15 minutes'),
(gen_random_uuid(), 'julio.fernandes@gmail.com', 'Julio', 'Fernandes', 'JULI037', 'ELEN006', 0, 25.0, FALSE, NOW() - INTERVAL '10 minutes'),
(gen_random_uuid(), 'karina.macedo@gmail.com', 'Karina', 'Macedo', 'KARI038', 'ELEN006', 0, 25.0, FALSE, NOW() - INTERVAL '5 minutes'),
(gen_random_uuid(), 'leonardo.cunha@gmail.com', 'Leonardo', 'Cunha', 'LEON039', 'ELEN006', 0, 25.0, FALSE, NOW() - INTERVAL '2 minutes');

-- ==================== PEQUENOS INFLUENCERS (2 referrals cada) ====================
-- Usuários referenciados por Felipe (2)
INSERT INTO public.users (id, email, first_name, last_name, referral_code, referred_by, total_referrals, total_earnings, is_admin, created_at) VALUES 
(gen_random_uuid(), 'melissa.araujo@gmail.com', 'Melissa', 'Araujo', 'MELI040', 'FELI007', 0, 25.0, FALSE, NOW() - INTERVAL '1 minute'),
(gen_random_uuid(), 'natanael.silva@gmail.com', 'Natanael', 'Silva', 'NATA041', 'FELI007', 0, 25.0, FALSE, NOW() - INTERVAL '30 seconds');

-- Usuários referenciados por Gabriela (2)
INSERT INTO public.users (id, email, first_name, last_name, referral_code, referred_by, total_referrals, total_earnings, is_admin, created_at) VALUES 
(gen_random_uuid(), 'otavio.nascimento@gmail.com', 'Otavio', 'Nascimento', 'OTAV042', 'GABR008', 0, 25.0, FALSE, NOW() - INTERVAL '15 seconds'),
(gen_random_uuid(), 'priscila.moura@gmail.com', 'Priscila', 'Moura', 'PRIS043', 'GABR008', 0, 25.0, FALSE, NOW() - INTERVAL '10 seconds');

-- Usuários referenciados por Henrique (2)
INSERT INTO public.users (id, email, first_name, last_name, referral_code, referred_by, total_referrals, total_earnings, is_admin, created_at) VALUES 
(gen_random_uuid(), 'quintino.ramos@gmail.com', 'Quintino', 'Ramos', 'QUIN044', 'HENR009', 0, 25.0, FALSE, NOW() - INTERVAL '5 seconds'),
(gen_random_uuid(), 'renata.duarte@gmail.com', 'Renata', 'Duarte', 'RENA045', 'HENR009', 0, 25.0, FALSE, NOW());

-- Usuários referenciados por Isabela (2)
INSERT INTO public.users (id, email, first_name, last_name, referral_code, referred_by, total_referrals, total_earnings, is_admin, created_at) VALUES 
(gen_random_uuid(), 'sergio.caldeira@gmail.com', 'Sergio', 'Caldeira', 'SERG046', 'ISAB010', 0, 25.0, FALSE, NOW()),
(gen_random_uuid(), 'tatiana.vasconcelos@gmail.com', 'Tatiana', 'Vasconcelos', 'TATI047', 'ISAB010', 0, 25.0, FALSE, NOW());

-- ==================== INICIANTES (1 referral cada) ====================
-- Usuários referenciados por João (1)
INSERT INTO public.users (id, email, first_name, last_name, referral_code, referred_by, total_referrals, total_earnings, is_admin, created_at) VALUES 
(gen_random_uuid(), 'ulysses.braga@gmail.com', 'Ulysses', 'Braga', 'ULYS048', 'JOAO011', 0, 25.0, FALSE, NOW());

-- Usuários referenciados por Karen (1)
INSERT INTO public.users (id, email, first_name, last_name, referral_code, referred_by, total_referrals, total_earnings, is_admin, created_at) VALUES 
(gen_random_uuid(), 'valeria.xavier@gmail.com', 'Valéria', 'Xavier', 'VALE049', 'KARE012', 0, 25.0, FALSE, NOW());

-- Usuários referenciados por Lucas (1)
INSERT INTO public.users (id, email, first_name, last_name, referral_code, referred_by, total_referrals, total_earnings, is_admin, created_at) VALUES 
(gen_random_uuid(), 'wellington.farias@gmail.com', 'Wellington', 'Farias', 'WELL050', 'LUCA013', 0, 25.0, FALSE, NOW());

-- ==================== VERIFICAÇÕES ====================

-- 1. Contagem total
SELECT 
    'VERIFICAÇÃO GERAL' as tipo,
    COUNT(*) as total_usuarios,
    SUM(total_referrals) as total_referrals_feitos,
    COUNT(*) FILTER (WHERE referred_by IS NOT NULL) as usuarios_referenciados,
    ROUND(AVG(total_referrals)::numeric, 2) as media_referrals,
    SUM(total_earnings) as total_ganhos_plataforma
FROM public.users 
WHERE email LIKE '%@gmail.com' AND is_admin = FALSE;

-- 2. Verificação matemática
SELECT 
    'VERIFICAÇÃO MATEMÁTICA' as tipo,
    (SELECT SUM(total_referrals) FROM public.users WHERE email LIKE '%@gmail.com' AND is_admin = FALSE) as referrals_feitos,
    (SELECT COUNT(*) FROM public.users WHERE email LIKE '%@gmail.com' AND is_admin = FALSE AND referred_by IS NOT NULL) as usuarios_referenciados,
    CASE 
        WHEN (SELECT SUM(total_referrals) FROM public.users WHERE email LIKE '%@gmail.com' AND is_admin = FALSE) = 
             (SELECT COUNT(*) FROM public.users WHERE email LIKE '%@gmail.com' AND is_admin = FALSE AND referred_by IS NOT NULL)
        THEN '✅ MATEMÁTICA PERFEITA!'
        ELSE '❌ ERRO: Números não batem'
    END as status_matematico;

-- 3. Top performers
SELECT 
    'TOP 10 PERFORMERS' as tipo,
    first_name || ' ' || last_name as nome,
    total_referrals as convites_feitos,
    total_earnings as ganhos,
    created_at::date as data_cadastro
FROM public.users 
WHERE email LIKE '%@gmail.com' AND is_admin = FALSE
ORDER BY total_referrals DESC, total_earnings DESC
LIMIT 10;

-- 4. Análise de conversão
SELECT 
    'ANÁLISE DE CONVERSÃO' as tipo,
    COUNT(*) FILTER (WHERE total_referrals > 0) as usuarios_ativos,
    COUNT(*) FILTER (WHERE total_referrals = 0) as usuarios_passivos,
    ROUND((COUNT(*) FILTER (WHERE total_referrals > 0)::numeric / COUNT(*) * 100), 2) as taxa_conversao_percent
FROM public.users 
WHERE email LIKE '%@gmail.com' AND is_admin = FALSE;

-- 5. Distribuição temporal
SELECT 
    'USUÁRIOS POR PERÍODO' as tipo,
    COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '7 days') as ultimos_7_dias,
    COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '14 days' AND created_at < NOW() - INTERVAL '7 days') as entre_7_14_dias,
    COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '30 days' AND created_at < NOW() - INTERVAL '14 days') as entre_14_30_dias,
    COUNT(*) FILTER (WHERE created_at < NOW() - INTERVAL '30 days') as mais_30_dias
FROM public.users 
WHERE email LIKE '%@gmail.com' AND is_admin = FALSE;
