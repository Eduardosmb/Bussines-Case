-- CloudWalk Referrals Database Schema
-- Execute este script no Supabase SQL Editor

-- Tabela de usuários
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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

-- Tabela de cliques nos links de referência
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

-- Tabela de conquistas do usuário
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

-- Tabelas criadas sem dados iniciais - você criará os dados através da aplicação

-- Habilitar RLS (Row Level Security)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_clicks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para users
CREATE POLICY "Users can view own data" ON public.users
    FOR SELECT USING (auth.uid() = id::uuid);

CREATE POLICY "Users can update own data" ON public.users
    FOR UPDATE USING (auth.uid() = id::uuid);

CREATE POLICY "Anyone can insert users" ON public.users
    FOR INSERT WITH CHECK (true);

-- Políticas RLS para referral_links
CREATE POLICY "Users can view own referral links" ON public.referral_links
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own referral links" ON public.referral_links
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas RLS para achievements (todos podem ver)
CREATE POLICY "Anyone can view achievements" ON public.achievements
    FOR SELECT USING (true);

-- Políticas RLS para user_achievements
CREATE POLICY "Users can view own achievements" ON public.user_achievements
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own achievements" ON public.user_achievements
    FOR ALL USING (auth.uid() = user_id);

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_referral_code ON public.users(referral_code);
CREATE INDEX IF NOT EXISTS idx_referral_links_user_id ON public.referral_links(user_id);
CREATE INDEX IF NOT EXISTS idx_referral_links_link_code ON public.referral_links(link_code);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON public.user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_referral_clicks_link_code ON public.referral_clicks(link_code);

-- Função para atualizar total_referrals automaticamente
CREATE OR REPLACE FUNCTION update_referrer_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.referred_by IS NOT NULL THEN
        UPDATE public.users 
        SET 
            total_referrals = total_referrals + 1,
            total_earnings = total_earnings + 50.00
        WHERE referral_code = NEW.referred_by;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para chamar a função quando um novo usuário é inserido
CREATE TRIGGER trigger_update_referrer_stats
    AFTER INSERT ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_referrer_stats();

COMMENT ON TABLE public.users IS 'Tabela principal de usuários do sistema CloudWalk Referrals';
COMMENT ON TABLE public.referral_links IS 'Links de referência gerados pelos usuários';
COMMENT ON TABLE public.achievements IS 'Conquistas disponíveis no sistema';
COMMENT ON TABLE public.user_achievements IS 'Conquistas dos usuários';
