-- LIMPAR TUDO E CORRIGIR DUPLICAÇÃO DEFINITIVAMENTE
-- Execute este script no Supabase SQL Editor

-- 1. REMOVER TODOS os triggers e funções (causa da duplicação)
DROP TRIGGER IF EXISTS trigger_process_referral ON public.users CASCADE;
DROP TRIGGER IF EXISTS trigger_update_referrer_stats ON public.users CASCADE;
DROP TRIGGER IF EXISTS process_referral_trigger ON public.users CASCADE;
DROP TRIGGER IF EXISTS update_referrer_trigger ON public.users CASCADE;
DROP TRIGGER IF EXISTS referral_trigger ON public.users CASCADE;

DROP FUNCTION IF EXISTS process_referral() CASCADE;
DROP FUNCTION IF EXISTS update_referrer_stats() CASCADE;
DROP FUNCTION IF EXISTS handle_referral() CASCADE;
DROP FUNCTION IF EXISTS process_referral_bonus() CASCADE;

-- 2. LIMPAR todas as tabelas (começar do zero)
DELETE FROM public.user_achievements;
DELETE FROM public.referral_clicks;
DELETE FROM public.referral_links;
DELETE FROM public.users;

-- 3. VERIFICAR se triggers foram removidos
SELECT 
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ SUCESSO: Nenhum trigger encontrado!'
        ELSE '❌ ERRO: Ainda há ' || COUNT(*) || ' trigger(s): ' || STRING_AGG(trigger_name, ', ')
    END as status_triggers
FROM information_schema.triggers 
WHERE trigger_schema = 'public' 
AND event_object_table = 'users';

-- 4. CONFIRMAR que tabelas estão vazias
SELECT 'users' as tabela, COUNT(*) as registros FROM public.users
UNION ALL
SELECT 'referral_links' as tabela, COUNT(*) as registros FROM public.referral_links
UNION ALL
SELECT 'user_achievements' as tabela, COUNT(*) as registros FROM public.user_achievements
UNION ALL
SELECT 'referral_clicks' as tabela, COUNT(*) as registros FROM public.referral_clicks;

-- 5. COMENTÁRIO EXPLICATIVO
COMMENT ON TABLE public.users IS 'CloudWalk Referrals - Limpo e sem triggers. Processamento apenas via código Dart.';

-- 6. MENSAGEM FINAL
SELECT '🎉 BANCO LIMPO E CORRIGIDO!' as titulo;
SELECT 'Agora pode registrar usuários sem duplicação de referrals' as instrucao_1;
SELECT 'Apenas o código Dart processará os referrals (+$25 usuário, +$50 referrer)' as instrucao_2;
SELECT 'Triggers removidos permanentemente' as instrucao_3;
