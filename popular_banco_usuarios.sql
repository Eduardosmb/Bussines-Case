-- Script para popular o banco de dados com usuários realistas
-- IMPORTANTE: Execute este script no SQL Editor do Supabase
-- Certifique-se de que a tabela users já existe e tem a coluna is_admin

-- Estrutura lógica dos referrals (matemática que bate):
-- João (pioneiro) -> convidou: Maria, Pedro, Ana (3 pessoas)
-- Maria -> convidou: Carlos, Lucia (2 pessoas)  
-- Pedro -> convidou: Bruno, Sofia, Daniel (3 pessoas)
-- Ana -> convidou: Rafael (1 pessoa)
-- Carlos -> convidou: Fernanda (1 pessoa)
-- Resto não convidou ninguém (0 pessoas cada)
-- Total: 11 usuários, 10 referrals (faz sentido!)

-- 1. USUÁRIO PIONEIRO (1 semana atrás, muito ativo)
INSERT INTO public.users (
    id, email, first_name, last_name, referral_code, 
    total_referrals, total_earnings, is_admin, created_at
) VALUES (
    gen_random_uuid(),
    'joao.silva@gmail.com',
    'João',
    'Silva',
    'JOAO001',
    3, -- Convidou 3 pessoas
    175.0, -- $25 signup + $150 por 3 referrals ($50 cada)
    FALSE,
    NOW() - INTERVAL '7 days'
);

-- 2. USUÁRIA ATIVA (6 dias atrás, convidada por João)
INSERT INTO public.users (
    id, email, first_name, last_name, referral_code, referred_by,
    total_referrals, total_earnings, is_admin, created_at
) VALUES (
    gen_random_uuid(),
    'maria.santos@gmail.com',
    'Maria',
    'Santos', 
    'MARIA02',
    'JOAO001',
    2, -- Convidou 2 pessoas
    125.0, -- $25 signup + $100 por 2 referrals
    FALSE,
    NOW() - INTERVAL '6 days'
);

-- 3. USUÁRIO MODERADO (5 dias atrás, convidado por João)
INSERT INTO public.users (
    id, email, first_name, last_name, referral_code, referred_by,
    total_referrals, total_earnings, is_admin, created_at
) VALUES (
    gen_random_uuid(),
    'pedro.oliveira@gmail.com',
    'Pedro',
    'Oliveira',
    'PEDRO03', 
    'JOAO001',
    3, -- Convidou 3 pessoas
    175.0, -- $25 signup + $150 por 3 referrals
    FALSE,
    NOW() - INTERVAL '5 days'
);

-- 4. USUÁRIA INICIANTE (4 dias atrás, convidada por João)
INSERT INTO public.users (
    id, email, first_name, last_name, referral_code, referred_by,
    total_referrals, total_earnings, is_admin, created_at
) VALUES (
    gen_random_uuid(),
    'ana.costa@gmail.com',
    'Ana',
    'Costa',
    'ANA0004',
    'JOAO001', 
    1, -- Convidou 1 pessoa
    75.0, -- $25 signup + $50 por 1 referral
    FALSE,
    NOW() - INTERVAL '4 days'
);

-- 5. USUÁRIO RECENTE ATIVO (3 dias atrás, convidado por Maria)
INSERT INTO public.users (
    id, email, first_name, last_name, referral_code, referred_by,
    total_referrals, total_earnings, is_admin, created_at
) VALUES (
    gen_random_uuid(),
    'carlos.ferreira@gmail.com',
    'Carlos',
    'Ferreira',
    'CARL005',
    'MARIA02',
    1, -- Convidou 1 pessoa
    75.0, -- $25 signup + $50 por 1 referral
    FALSE,
    NOW() - INTERVAL '3 days'
);

-- 6. USUÁRIA PASSIVA (3 dias atrás, convidada por Maria)
INSERT INTO public.users (
    id, email, first_name, last_name, referral_code, referred_by,
    total_referrals, total_earnings, is_admin, created_at
) VALUES (
    gen_random_uuid(),
    'lucia.almeida@gmail.com',
    'Lucia',
    'Almeida',
    'LUCIA06',
    'MARIA02',
    0, -- Não convidou ninguém
    25.0, -- Apenas $25 signup
    FALSE,
    NOW() - INTERVAL '3 days'
);

-- 7. USUÁRIO PASSIVO (2 dias atrás, convidado por Pedro)
INSERT INTO public.users (
    id, email, first_name, last_name, referral_code, referred_by,
    total_referrals, total_earnings, is_admin, created_at
) VALUES (
    gen_random_uuid(),
    'bruno.lima@gmail.com',
    'Bruno',
    'Lima',
    'BRUNO07',
    'PEDRO03',
    0, -- Não convidou ninguém
    25.0, -- Apenas $25 signup
    FALSE,
    NOW() - INTERVAL '2 days'
);

-- 8. USUÁRIA PASSIVA (2 dias atrás, convidada por Pedro)
INSERT INTO public.users (
    id, email, first_name, last_name, referral_code, referred_by,
    total_referrals, total_earnings, is_admin, created_at
) VALUES (
    gen_random_uuid(),
    'sofia.rodrigues@gmail.com',
    'Sofia',
    'Rodrigues',
    'SOFIA08',
    'PEDRO03',
    0, -- Não convidou ninguém
    25.0, -- Apenas $25 signup
    FALSE,
    NOW() - INTERVAL '2 days'
);

-- 9. USUÁRIO PASSIVO (1 dia atrás, convidado por Pedro)
INSERT INTO public.users (
    id, email, first_name, last_name, referral_code, referred_by,
    total_referrals, total_earnings, is_admin, created_at
) VALUES (
    gen_random_uuid(),
    'daniel.martins@gmail.com',
    'Daniel',
    'Martins',
    'DANIEL9',
    'PEDRO03',
    0, -- Não convidou ninguém
    25.0, -- Apenas $25 signup
    FALSE,
    NOW() - INTERVAL '1 day'
);

-- 10. USUÁRIO NOVO (1 dia atrás, convidado por Ana)
INSERT INTO public.users (
    id, email, first_name, last_name, referral_code, referred_by,
    total_referrals, total_earnings, is_admin, created_at
) VALUES (
    gen_random_uuid(),
    'rafael.souza@gmail.com',
    'Rafael',
    'Souza',
    'RAFA010',
    'ANA0004',
    0, -- Não convidou ninguém
    25.0, -- Apenas $25 signup
    FALSE,
    NOW() - INTERVAL '1 day'
);

-- 11. USUÁRIA NOVÍSSIMA (hoje, convidada por Carlos)
INSERT INTO public.users (
    id, email, first_name, last_name, referral_code, referred_by,
    total_referrals, total_earnings, is_admin, created_at
) VALUES (
    gen_random_uuid(),
    'fernanda.pereira@gmail.com',
    'Fernanda',
    'Pereira',
    'FERN011',
    'CARL005',
    0, -- Não convidou ninguém (acabou de entrar)
    25.0, -- Apenas $25 signup
    FALSE,
    NOW() - INTERVAL '2 hours'
);

-- 12. Verificar se os dados foram inseridos corretamente
SELECT 
    'VERIFICAÇÃO DOS DADOS INSERIDOS' as status,
    COUNT(*) as total_usuarios,
    SUM(total_referrals) as total_referrals_somados,
    ROUND(AVG(total_referrals)::numeric, 2) as media_referrals,
    SUM(total_earnings) as total_ganhos
FROM public.users 
WHERE email LIKE '%@gmail.com' AND is_admin = FALSE;

-- 13. Mostrar hierarquia de referrals
SELECT 
    u.first_name || ' ' || u.last_name as usuario,
    u.email,
    u.referral_code,
    u.referred_by as referenciado_por,
    u.total_referrals as convidou_quantos,
    u.total_earnings as ganhos,
    u.created_at::date as data_cadastro
FROM public.users u
WHERE u.email LIKE '%@gmail.com' AND u.is_admin = FALSE
ORDER BY u.created_at;

-- 14. Verificação da matemática
SELECT 
    'ANÁLISE MATEMÁTICA' as verificacao,
    (SELECT COUNT(*) FROM public.users WHERE email LIKE '%@gmail.com' AND is_admin = FALSE) as usuarios_totais,
    (SELECT COUNT(*) FROM public.users WHERE email LIKE '%@gmail.com' AND is_admin = FALSE AND referred_by IS NOT NULL) as usuarios_referenciados,
    (SELECT SUM(total_referrals) FROM public.users WHERE email LIKE '%@gmail.com' AND is_admin = FALSE) as total_convites_feitos,
    CASE 
        WHEN (SELECT COUNT(*) FROM public.users WHERE email LIKE '%@gmail.com' AND is_admin = FALSE AND referred_by IS NOT NULL) = 
             (SELECT SUM(total_referrals) FROM public.users WHERE email LIKE '%@gmail.com' AND is_admin = FALSE)
        THEN '✅ MATEMÁTICA CORRETA!'
        ELSE '❌ ERRO: Números não batem'
    END as status_matematico;
