-- LIMPAR USUÁRIOS DO SUPABASE AUTH
-- Execute este script no Supabase SQL Editor para remover usuários órfãos

-- Ver todos os usuários no Supabase Auth
SELECT 
    id,
    email,
    created_at,
    email_confirmed_at
FROM auth.users
ORDER BY created_at DESC;

-- OPÇÃO 1: Deletar usuários específicos (mais seguro)
-- Descomente e execute apenas as linhas dos usuários que quer remover:

-- DELETE FROM auth.users WHERE email = 'sergio.ramella@gmail.com';
-- DELETE FROM auth.users WHERE email = 'alexandre.wagner@gmail.com';
-- DELETE FROM auth.users WHERE email = 'enzo.quental@gmail.com';

-- OPÇÃO 2: Deletar TODOS os usuários do Auth (cuidado!)
-- Descomente apenas se quer começar completamente do zero:

-- DELETE FROM auth.users;

-- Verificar se usuários foram removidos
SELECT 
    COUNT(*) as total_users_auth,
    'Usuários restantes no Supabase Auth' as status
FROM auth.users;
