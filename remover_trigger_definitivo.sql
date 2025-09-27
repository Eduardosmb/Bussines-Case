-- REMOVER TRIGGER DEFINITIVAMENTE PARA RESOLVER DUPLICAÇÃO FUTURA
-- Execute este script no Supabase SQL Editor

-- 1. LISTAR todos os triggers na tabela users (para debug)
SELECT 
    trigger_name,
    event_manipulation,
    action_timing,
    action_statement
FROM information_schema.triggers 
WHERE trigger_schema = 'public' 
AND event_object_table = 'users';

-- 2. REMOVER TODOS os triggers possíveis (força bruta)
DROP TRIGGER IF EXISTS trigger_process_referral ON public.users CASCADE;
DROP TRIGGER IF EXISTS trigger_update_referrer_stats ON public.users CASCADE;
DROP TRIGGER IF EXISTS process_referral_trigger ON public.users CASCADE;
DROP TRIGGER IF EXISTS update_referrer_trigger ON public.users CASCADE;
DROP TRIGGER IF EXISTS referral_trigger ON public.users CASCADE;

-- 3. REMOVER TODAS as funções possíveis
DROP FUNCTION IF EXISTS process_referral() CASCADE;
DROP FUNCTION IF EXISTS update_referrer_stats() CASCADE;
DROP FUNCTION IF EXISTS handle_referral() CASCADE;
DROP FUNCTION IF EXISTS process_referral_bonus() CASCADE;

-- 4. VERIFICAR se ainda existem triggers
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ SUCESSO: Nenhum trigger encontrado!'
        ELSE '❌ PROBLEMA: Ainda há ' || COUNT(*) || ' trigger(s): ' || STRING_AGG(trigger_name, ', ')
    END as status_final
FROM information_schema.triggers 
WHERE trigger_schema = 'public' 
AND event_object_table = 'users';

-- 5. TESTE: Inserir usuário fictício para verificar se trigger foi removido
-- (Este usuário será removido depois)
INSERT INTO public.users (
    id, 
    email, 
    first_name, 
    last_name, 
    referral_code, 
    referred_by, 
    total_referrals, 
    total_earnings
) VALUES (
    gen_random_uuid(),
    'teste_trigger@exemplo.com',
    'Teste',
    'Trigger',
    'TEST99',
    'Z01234', -- Código do Sergio
    0,
    25.00
);

-- 6. VERIFICAR se o Sergio recebeu +$50 automaticamente (não deveria)
SELECT 
    email,
    total_referrals,
    total_earnings,
    CASE 
        WHEN email = 'sergio.ramella@gmail.com' AND total_earnings > 125 
        THEN '❌ TRIGGER AINDA ATIVO - Sergio recebeu mais $50'
        WHEN email = 'sergio.ramella@gmail.com' 
        THEN '✅ TRIGGER REMOVIDO - Sergio não recebeu $50 extra'
        ELSE 'Outro usuário'
    END as status_trigger
FROM public.users 
WHERE email IN ('sergio.ramella@gmail.com', 'teste_trigger@exemplo.com')
ORDER BY email;

-- 7. REMOVER usuário de teste
DELETE FROM public.users WHERE email = 'teste_trigger@exemplo.com';

-- 8. CONFIRMAÇÃO FINAL
SELECT '🎯 INSTRUÇÕES APÓS ESTE SCRIPT:' as titulo;
SELECT 'Se Sergio NÃO recebeu $50 extra, o trigger foi removido com sucesso!' as instrucao_1;
SELECT 'Agora apenas o código Dart processará referrals (sem duplicação)' as instrucao_2;
SELECT 'Teste registrando um novo usuário com código do Sergio' as instrucao_3;
