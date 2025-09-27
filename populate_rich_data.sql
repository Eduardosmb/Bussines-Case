-- POPULATE RICH DATA FOR ADVANCED ANALYTICS
-- This will create more diverse and realistic data for better AI analysis

-- Add more user metadata columns for advanced analytics
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS signup_source VARCHAR(50) DEFAULT 'organic';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS last_login TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS engagement_score INTEGER DEFAULT 50;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS user_segment VARCHAR(20) DEFAULT 'casual';
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS lifetime_value DECIMAL(10,2) DEFAULT 0.0;

-- Create referral_clicks table for funnel analysis
CREATE TABLE IF NOT EXISTS public.referral_clicks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referral_code VARCHAR(20) NOT NULL,
    clicked_at TIMESTAMPTZ DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT,
    converted BOOLEAN DEFAULT FALSE,
    conversion_time TIMESTAMPTZ,
    source VARCHAR(50) DEFAULT 'direct'
);

-- Create user_sessions table for engagement tracking
CREATE TABLE IF NOT EXISTS public.user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id),
    session_start TIMESTAMPTZ DEFAULT NOW(),
    session_end TIMESTAMPTZ,
    pages_viewed INTEGER DEFAULT 1,
    actions_taken INTEGER DEFAULT 0,
    device_type VARCHAR(20) DEFAULT 'web'
);

-- Create campaign_performance table
CREATE TABLE IF NOT EXISTS public.campaign_performance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    campaign_name VARCHAR(100) NOT NULL,
    start_date TIMESTAMPTZ DEFAULT NOW(),
    end_date TIMESTAMPTZ,
    budget DECIMAL(10,2) DEFAULT 0,
    clicks INTEGER DEFAULT 0,
    conversions INTEGER DEFAULT 0,
    revenue DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active'
);

-- Update existing users with rich data
UPDATE public.users SET 
    signup_source = CASE 
        WHEN random() < 0.3 THEN 'google_ads'
        WHEN random() < 0.5 THEN 'facebook_ads'
        WHEN random() < 0.7 THEN 'instagram'
        WHEN random() < 0.85 THEN 'referral'
        ELSE 'organic'
    END,
    last_login = created_at + INTERVAL '1 day' * (random() * 30),
    engagement_score = 20 + (random() * 60)::INTEGER,
    user_segment = CASE 
        WHEN total_referrals >= 10 THEN 'super_user'
        WHEN total_referrals >= 5 THEN 'active_user'
        WHEN total_referrals >= 1 THEN 'moderate_user'
        ELSE 'casual_user'
    END,
    lifetime_value = total_earnings * (1.5 + random());

-- Insert realistic referral clicks data
INSERT INTO public.referral_clicks (referral_code, clicked_at, converted, conversion_time, source)
SELECT 
    u.referral_code,
    u.created_at + INTERVAL '1 hour' * (random() * 720), -- Clicks within 30 days
    CASE WHEN random() < 0.15 THEN TRUE ELSE FALSE END, -- 15% conversion rate
    CASE WHEN random() < 0.15 THEN u.created_at + INTERVAL '1 hour' * (random() * 48) ELSE NULL END,
    CASE 
        WHEN random() < 0.4 THEN 'whatsapp'
        WHEN random() < 0.6 THEN 'instagram'
        WHEN random() < 0.8 THEN 'facebook'
        ELSE 'direct'
    END
FROM public.users u
CROSS JOIN generate_series(1, (3 + random() * 7)::INTEGER) -- 3-10 clicks per user
WHERE u.total_referrals > 0;

-- Insert user session data for engagement analysis
INSERT INTO public.user_sessions (user_id, session_start, session_end, pages_viewed, actions_taken, device_type)
SELECT 
    u.id,
    u.created_at + INTERVAL '1 day' * (random() * 30),
    u.created_at + INTERVAL '1 day' * (random() * 30) + INTERVAL '1 minute' * (5 + random() * 30),
    1 + (random() * 10)::INTEGER,
    (random() * 5)::INTEGER,
    CASE 
        WHEN random() < 0.6 THEN 'mobile'
        WHEN random() < 0.8 THEN 'desktop'
        ELSE 'tablet'
    END
FROM public.users u
CROSS JOIN generate_series(1, (2 + random() * 8)::INTEGER); -- 2-10 sessions per user

-- Insert campaign performance data
INSERT INTO public.campaign_performance (campaign_name, start_date, end_date, budget, clicks, conversions, revenue, status)
VALUES 
('Google Ads Q4', NOW() - INTERVAL '30 days', NOW() - INTERVAL '1 day', 5000.00, 12500, 1875, 46875.00, 'completed'),
('Facebook Campaign', NOW() - INTERVAL '60 days', NOW() - INTERVAL '30 days', 3000.00, 8200, 1230, 30750.00, 'completed'),
('Instagram Influencer', NOW() - INTERVAL '90 days', NOW() - INTERVAL '60 days', 2000.00, 5500, 825, 20625.00, 'completed'),
('Referral Boost', NOW() - INTERVAL '15 days', NOW() + INTERVAL '15 days', 1500.00, 3200, 480, 12000.00, 'active'),
('Holiday Special', NOW() - INTERVAL '7 days', NOW() + INTERVAL '23 days', 4000.00, 1800, 270, 6750.00, 'active');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_referral_clicks_code ON public.referral_clicks(referral_code);
CREATE INDEX IF NOT EXISTS idx_referral_clicks_date ON public.referral_clicks(clicked_at);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user ON public.user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_date ON public.user_sessions(session_start);
CREATE INDEX IF NOT EXISTS idx_users_segment ON public.users(user_segment);
CREATE INDEX IF NOT EXISTS idx_users_source ON public.users(signup_source);

-- Enable RLS for new tables
ALTER TABLE public.referral_clicks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaign_performance ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for admins
CREATE POLICY "Admins can view all referral clicks" ON public.referral_clicks
FOR SELECT USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = TRUE));

CREATE POLICY "Admins can view all user sessions" ON public.user_sessions
FOR SELECT USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = TRUE));

CREATE POLICY "Admins can view all campaign performance" ON public.campaign_performance
FOR SELECT USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND is_admin = TRUE));

-- Verify rich data creation
SELECT 
    'Rich Data Summary' as metric,
    COUNT(*) as total_users,
    COUNT(DISTINCT signup_source) as unique_sources,
    AVG(engagement_score) as avg_engagement,
    COUNT(DISTINCT user_segment) as segments
FROM public.users;

SELECT 'Referral Clicks' as table_name, COUNT(*) as records FROM public.referral_clicks
UNION ALL
SELECT 'User Sessions' as table_name, COUNT(*) as records FROM public.user_sessions
UNION ALL
SELECT 'Campaign Performance' as table_name, COUNT(*) as records FROM public.campaign_performance;
