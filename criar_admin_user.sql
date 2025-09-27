-- Script para criar usuário admin e adicionar campo is_admin
-- Execute este script no SQL Editor do Supabase

-- 1. Adicionar coluna is_admin à tabela users (se não existir)
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE;

-- 2. Inserir usuário admin (será criado via código Dart também)
-- Este é apenas para garantir que existe no banco
INSERT INTO public.users (
    id,
    email, 
    first_name, 
    last_name, 
    referral_code, 
    total_referrals, 
    total_earnings,
    is_admin,
    created_at
) VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    'admin@cloudwalk.com',
    'Admin',
    'CloudWalk',
    'ADMIN001',
    0,
    0.0,
    TRUE,
    NOW()
) ON CONFLICT (email) DO UPDATE SET
    is_admin = TRUE,
    first_name = 'Admin',
    last_name = 'CloudWalk';

-- 3. Criar tabela para armazenar analytics avançados
CREATE TABLE IF NOT EXISTS public.admin_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_name VARCHAR(100) NOT NULL,
    metric_value NUMERIC,
    metric_data JSONB,
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES public.users(id)
);

-- 4. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_admin_analytics_metric_name ON public.admin_analytics(metric_name);
CREATE INDEX IF NOT EXISTS idx_admin_analytics_calculated_at ON public.admin_analytics(calculated_at);
CREATE INDEX IF NOT EXISTS idx_users_is_admin ON public.users(is_admin) WHERE is_admin = TRUE;

-- 5. RLS policies para admin_analytics
ALTER TABLE public.admin_analytics ENABLE ROW LEVEL SECURITY;

-- Apenas admins podem ver e inserir analytics
CREATE POLICY "Admin analytics - Select" ON public.admin_analytics
    FOR SELECT USING (
        auth.uid() IN (
            SELECT id FROM public.users WHERE is_admin = TRUE
        )
    );

CREATE POLICY "Admin analytics - Insert" ON public.admin_analytics
    FOR INSERT WITH CHECK (
        auth.uid() IN (
            SELECT id FROM public.users WHERE is_admin = TRUE
        )
    );

-- 6. Comentários para documentação
COMMENT ON TABLE public.admin_analytics IS 'Tabela para armazenar métricas e análises avançadas para usuários admin';
COMMENT ON COLUMN public.users.is_admin IS 'Flag para identificar usuários com privilégios administrativos';

-- 7. Verificar se tudo foi criado corretamente
SELECT 
    'users' as table_name,
    COUNT(*) as total_records,
    COUNT(*) FILTER (WHERE is_admin = TRUE) as admin_users
FROM public.users
UNION ALL
SELECT 
    'admin_analytics' as table_name,
    COUNT(*) as total_records,
    0 as admin_users
FROM public.admin_analytics;
