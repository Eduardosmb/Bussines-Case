-- Script para corrigir o ID do admin e sincronizar com Supabase Auth
-- Execute este script no SQL Editor do Supabase

-- 1. Primeiro, vamos ver o usuário admin atual
SELECT id, email, first_name, last_name, is_admin 
FROM public.users 
WHERE email = 'admin@cloudwalk.com';

-- 2. Atualizar o ID do admin para corresponder ao Supabase Auth
-- SUBSTITUA 'f2566745-e6ad-4ea4-ba6c-9952c72dbbe3' pelo ID real que apareceu nos logs
UPDATE public.users 
SET id = 'f2566745-e6ad-4ea4-ba6c-9952c72dbbe3'::uuid
WHERE email = 'admin@cloudwalk.com';

-- 3. Verificar se a atualização funcionou
SELECT id, email, first_name, last_name, is_admin 
FROM public.users 
WHERE email = 'admin@cloudwalk.com';

-- 4. Se houver problemas de constraint, remova o admin antigo e recrie:
-- DELETE FROM public.users WHERE email = 'admin@cloudwalk.com';
-- INSERT INTO public.users (
--     id,
--     email, 
--     first_name, 
--     last_name, 
--     referral_code, 
--     total_referrals, 
--     total_earnings,
--     is_admin
-- ) VALUES (
--     'f2566745-e6ad-4ea4-ba6c-9952c72dbbe3'::uuid,
--     'admin@cloudwalk.com',
--     'Admin',
--     'CloudWalk',
--     'ADMIN001',
--     0,
--     0.0,
--     TRUE
-- );

-- 5. Confirmar que está tudo certo
SELECT 'Admin setup completed!' as status,
       COUNT(*) as admin_count,
       id as admin_id
FROM public.users 
WHERE email = 'admin@cloudwalk.com' AND is_admin = TRUE
GROUP BY id;
