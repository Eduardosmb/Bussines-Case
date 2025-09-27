-- CRIAR ACHIEVEMENTS DO SISTEMA CLOUDWALK
-- Execute este script no Supabase SQL Editor

-- Inserir os achievements solicitados
INSERT INTO public.achievements (title, description, icon, type, target_value, reward_amount) VALUES
('Primeiro Sucesso', 'Seu código foi usado 1 vez', '🎯', 'referrals', 1, 10.00),
('Influencer Bronze', 'Seu código foi usado 5 vezes', '🏆', 'referrals', 5, 15.00),
('Influencer Prata', 'Seu código foi usado 15 vezes', '👑', 'referrals', 15, 25.00),
('Influencer Ouro', 'Seu código foi usado 30 vezes', '💎', 'referrals', 30, 50.00),
('Top Performer', 'Ficou no top 3 do leaderboard', '🥇', 'special', 3, 25.00),
('Milionário', 'Acumulou mais de $1000', '💰', 'earnings', 1000, 100.00)
ON CONFLICT DO NOTHING;

-- Verificar achievements criados
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

-- Contar achievements criados
SELECT 
    COUNT(*) as total_achievements,
    '✅ Achievements criados com sucesso!' as status
FROM public.achievements;
