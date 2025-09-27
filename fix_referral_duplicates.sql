-- Script para corrigir duplicação de referrals
-- Execute este script no Supabase SQL Editor

-- 1. REMOVER O TRIGGER que está causando duplicação
DROP TRIGGER IF EXISTS trigger_process_referral ON public.users;
DROP FUNCTION IF EXISTS process_referral();

-- 2. CORRIGIR os valores dos usuários afetados
-- Eduardo deveria ter: 1 referral, $50 (não $100)
-- Enzo deveria ter: 0 referrals, $25

-- Primeiro, vamos ver os valores atuais:
SELECT 
    email, 
    first_name, 
    last_name, 
    referral_code, 
    referred_by,
    total_referrals, 
    total_earnings 
FROM public.users 
ORDER BY created_at;

-- Corrigir Eduardo (quem foi referido):
UPDATE public.users 
SET 
    total_referrals = 1,    -- 1 pessoa (Enzo) usou seu código
    total_earnings = 50.00  -- $50 por 1 referral (era $100)
WHERE email = 'eduardo.barros@gmail.com';

-- Corrigir Enzo (quem referiu):
UPDATE public.users 
SET 
    total_referrals = 0,    -- Não referiu ninguém ainda
    total_earnings = 25.00  -- $25 de bônus por usar código (já estava correto)
WHERE email = 'enzo.quental@gmail.com';

-- 3. VERIFICAR os valores corrigidos:
SELECT 
    email, 
    first_name || ' ' || last_name as nome,
    referral_code, 
    referred_by,
    total_referrals, 
    total_earnings,
    CASE 
        WHEN referred_by IS NOT NULL THEN '✅ Usou código de referral'
        ELSE '⭐ Usuário original'
    END as status
FROM public.users 
ORDER BY created_at;

-- 4. Comentário explicativo
COMMENT ON TABLE public.users IS 'Usuários do CloudWalk Referrals - Trigger removido para evitar duplicação de referrals';
