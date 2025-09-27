-- Script para criar alguns usuários também no Supabase Auth
-- IMPORTANTE: Execute este script no SQL Editor do Supabase

-- Este script vai criar 5 usuários principais no Supabase Auth para que possam fazer login
-- Os outros 45 usuários ficam apenas como dados de análise

-- Função para criar usuários no Auth (via SQL)
-- ATENÇÃO: Esta função só funciona se você tiver acesso de admin ao Supabase

-- Para criar usuários de teste que possam fazer login, você precisa:
-- 1. Ir no painel do Supabase > Authentication > Users
-- 2. Clicar em "Add user" manualmente para cada um dos 5 usuários principais
-- 3. Ou usar a API REST do Supabase

-- USUÁRIOS PARA CRIAR MANUALMENTE NO PAINEL SUPABASE:

/*
1. Email: marcos.antonio@gmail.com
   Password: 123456
   Confirm: ✅

2. Email: ana.silva@gmail.com  
   Password: 123456
   Confirm: ✅

3. Email: bruno.santos@gmail.com
   Password: 123456
   Confirm: ✅

4. Email: carla.oliveira@gmail.com
   Password: 123456
   Confirm: ✅

5. Email: diego.costa@gmail.com
   Password: 123456
   Confirm: ✅
*/

-- Depois de criar no painel, execute estas queries para sincronizar os IDs:

-- Buscar o ID do Marcos no Auth e atualizar na nossa tabela
-- SUBSTITUA 'NOVO_ID_DO_MARCOS' pelo ID real que o Supabase Auth gerou
/*
UPDATE public.users 
SET id = 'NOVO_ID_DO_MARCOS'::uuid
WHERE email = 'marcos.antonio@gmail.com';
*/

-- Verificar se a sincronização funcionou
SELECT 
    'USUÁRIOS CRIADOS NO AUTH' as status,
    email,
    first_name || ' ' || last_name as nome,
    total_referrals,
    total_earnings,
    created_at::date as data_cadastro
FROM public.users 
WHERE email IN (
    'marcos.antonio@gmail.com',
    'ana.silva@gmail.com', 
    'bruno.santos@gmail.com',
    'carla.oliveira@gmail.com',
    'diego.costa@gmail.com'
)
ORDER BY total_referrals DESC;
