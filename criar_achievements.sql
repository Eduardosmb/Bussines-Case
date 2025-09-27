-- CRIAR ACHIEVEMENTS DO SISTEMA CLOUDWALK
-- Execute este script no Supabase SQL Editor

-- Insert requested achievements in English
INSERT INTO public.achievements (title, description, icon, type, target_value, reward_amount) VALUES
('First Success', 'Your referral code was used 1 time', '🎯', 'referrals', 1, 10.00),
('Bronze Influencer', 'Your referral code was used 5 times', '🏆', 'referrals', 5, 15.00),
('Silver Influencer', 'Your referral code was used 15 times', '👑', 'referrals', 15, 25.00),
('Gold Influencer', 'Your referral code was used 30 times', '💎', 'referrals', 30, 50.00),
('Top Performer', 'Reached top 3 in leaderboard', '🥇', 'special', 3, 25.00),
('Millionaire', 'Accumulated more than $1000 in earnings', '💰', 'earnings', 1000, 100.00)
ON CONFLICT DO NOTHING;

-- Verify created achievements
SELECT 
    title,
    description,
    icon,
    type,
    target_value,
    reward_amount
FROM public.achievements
ORDER BY 
    CASE type 
        WHEN 'referrals' THEN 1
        WHEN 'earnings' THEN 2  
        WHEN 'special' THEN 3
        ELSE 4
    END,
    target_value;

-- Count created achievements
SELECT 
    COUNT(*) as total_achievements,
    '✅ Achievements created successfully!' as status
FROM public.achievements;
