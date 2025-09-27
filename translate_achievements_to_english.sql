-- TRANSLATE ACHIEVEMENTS TO ENGLISH
-- Execute this script in Supabase SQL Editor

-- Update existing achievements to English
UPDATE public.achievements 
SET 
    title = 'First Success',
    description = 'Your referral code was used 1 time'
WHERE title = 'Primeiro Sucesso';

UPDATE public.achievements 
SET 
    title = 'Bronze Influencer',
    description = 'Your referral code was used 5 times'
WHERE title = 'Influencer Bronze';

UPDATE public.achievements 
SET 
    title = 'Silver Influencer',
    description = 'Your referral code was used 15 times'
WHERE title = 'Influencer Prata';

UPDATE public.achievements 
SET 
    title = 'Gold Influencer',
    description = 'Your referral code was used 30 times'
WHERE title = 'Influencer Ouro';

UPDATE public.achievements 
SET 
    title = 'Top Performer',
    description = 'Reached top 3 in leaderboard'
WHERE title = 'Top Performer' AND description != 'Reached top 3 in leaderboard';

UPDATE public.achievements 
SET 
    title = 'Millionaire',
    description = 'Accumulated more than $1000 in earnings'
WHERE title = 'Milionário';

-- Verify all achievements are now in English
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

-- Count updated achievements
SELECT 
    COUNT(*) as total_achievements,
    '✅ Achievements translated to English successfully!' as status
FROM public.achievements;
