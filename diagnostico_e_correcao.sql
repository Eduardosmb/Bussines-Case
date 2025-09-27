-- DIAGNÓSTICO E CORREÇÃO COMPLETA DA DUPLICAÇÃO
-- Execute este script no Supabase SQL Editor

-- 1. VERIFICAR se o trigger ainda existe
SELECT 
    trigger_name,
    event_manipulation,
    action_statement,
    action_timing
FROM information_schema.triggers 
WHERE trigger_schema = 'public' 
AND event_object_table = 'users';

-- 2. FORÇAR REMOÇÃO do trigger e função (mesmo se não aparecer acima)
DROP TRIGGER IF EXISTS trigger_process_referral ON public.users;
DROP TRIGGER IF EXISTS trigger_update_referrer_stats ON public.users;
DROP FUNCTION IF EXISTS process_referral();
DROP FUNCTION IF EXISTS update_referrer_stats();

-- 3. VERIFICAR valores atuais dos usuários afetados
SELECT 
    email,
    first_name || ' ' || last_name as nome,
    referral_code,
    referred_by,
    total_referrals,
    total_earnings,
    created_at
FROM public.users 
ORDER BY created_at;

-- 4. CORRIGIR valores específicos baseado no problema reportado

-- Sergio Ramella: deveria ter $75 (era $25, +$50 por Alexandre)
-- Mas foi para $125, então precisa ser corrigido
UPDATE public.users 
SET 
    total_earnings = 75.00,  -- $25 inicial + $50 por Alexandre = $75
    total_referrals = 1      -- 1 pessoa (Alexandre) usou seu código
WHERE email = 'sergio.ramella@gmail.com';

-- Alexandre Wagner: deveria manter $25 (bônus por usar código)
UPDATE public.users 
SET 
    total_earnings = 25.00,  -- $25 de bônus por usar código do Sergio
    total_referrals = 0      -- Não referiu ninguém ainda
WHERE email = 'alexandre.wagner@gmail.com';

-- Eduardo Barros: corrigir se ainda estiver com $100
UPDATE public.users 
SET 
    total_earnings = 50.00,  -- $50 por ter referido Enzo
    total_referrals = 1      -- 1 pessoa (Enzo) usou seu código
WHERE email = 'eduardo.barros@gmail.com' 
AND total_earnings > 50;

-- Enzo Quental: manter $25
UPDATE public.users 
SET 
    total_earnings = 25.00,  -- $25 de bônus por usar código do Eduardo
    total_referrals = 0      -- Não referiu ninguém ainda
WHERE email = 'enzo.quental@gmail.com';

-- 5. VERIFICAR valores corrigidos
SELECT 
    '=== VALORES CORRIGIDOS ===' as status;

SELECT 
    email,
    first_name || ' ' || last_name as nome,
    referral_code,
    referred_by,
    total_referrals,
    total_earnings,
    CASE 
        WHEN referred_by IS NOT NULL THEN '✅ Usou código: +$25'
        WHEN total_referrals > 0 THEN '⭐ Referiu pessoas: +$' || (total_referrals * 50)::text
        ELSE '🆕 Usuário sem referrals'
    END as status_detalhado
FROM public.users 
ORDER BY created_at;

-- 6. CONFIRMAR que não há mais triggers
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ Nenhum trigger encontrado - duplicação resolvida!'
        ELSE '❌ Ainda há ' || COUNT(*) || ' trigger(s) ativos'
    END as status_triggers
FROM information_schema.triggers 
WHERE trigger_schema = 'public' 
AND event_object_table = 'users';

-- 7. COMENTÁRIO FINAL
COMMENT ON TABLE public.users IS 'CloudWalk Referrals - Triggers removidos para evitar duplicação. Processamento apenas via código Dart.';
