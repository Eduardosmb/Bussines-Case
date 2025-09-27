-- CloudWalk Referrals - Script SQL Limpo
-- Execute este script no Supabase SQL Editor

-- Tabela de usuários (usa UUID do auth.users automaticamente)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    referral_code VARCHAR(20) UNIQUE NOT NULL,
    referred_by VARCHAR(20),
    total_referrals INTEGER DEFAULT 0,
    total_earnings DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de links de referência
CREATE TABLE IF NOT EXISTS public.referral_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    user_name VARCHAR(255) NOT NULL,
    link_code VARCHAR(20) UNIQUE NOT NULL,
    full_url TEXT NOT NULL,
    click_count INTEGER DEFAULT 0,
    registration_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de cliques nos links
CREATE TABLE IF NOT EXISTS public.referral_clicks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    link_code VARCHAR(20) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    clicked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_registration BOOLEAN DEFAULT FALSE,
    completed_email VARCHAR(255)
);

-- Tabela de conquistas/achievements
CREATE TABLE IF NOT EXISTS public.achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(10),
    type VARCHAR(50) NOT NULL,
    target_value INTEGER NOT NULL,
    reward_amount DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela de conquistas dos usuários
CREATE TABLE IF NOT EXISTS public.user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    achievement_id UUID REFERENCES public.achievements(id) ON DELETE CASCADE,
    is_unlocked BOOLEAN DEFAULT FALSE,
    unlocked_at TIMESTAMP WITH TIME ZONE,
    progress INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- Habilitar Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_clicks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança simples
CREATE POLICY "users_policy" ON public.users FOR ALL USING (true);
CREATE POLICY "referral_links_policy" ON public.referral_links FOR ALL USING (true);
CREATE POLICY "referral_clicks_policy" ON public.referral_clicks FOR ALL USING (true);
CREATE POLICY "achievements_policy" ON public.achievements FOR ALL USING (true);
CREATE POLICY "user_achievements_policy" ON public.user_achievements FOR ALL USING (true);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_referral_code ON public.users(referral_code);
CREATE INDEX IF NOT EXISTS idx_referral_links_user_id ON public.referral_links(user_id);
CREATE INDEX IF NOT EXISTS idx_referral_links_link_code ON public.referral_links(link_code);

-- NOTA: Não usamos triggers automáticos para referrals
-- O processamento é feito no código Dart para evitar duplicação

-- Comentários
COMMENT ON TABLE public.users IS 'Usuários do CloudWalk Referrals';
COMMENT ON TABLE public.referral_links IS 'Links de referência dos usuários';
COMMENT ON TABLE public.achievements IS 'Sistema de conquistas';
COMMENT ON TABLE public.user_achievements IS 'Conquistas desbloqueadas pelos usuários';

-- Exemplos de types válidos para achievements: 'referrals', 'earnings', 'streak', 'special'
