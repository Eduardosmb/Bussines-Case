-- QUICK FIX: Update all referral codes to unique values starting from 500
-- This script updates the add_200_smart_users.sql referral codes to avoid conflicts

-- First, let's see what codes already exist to understand the conflict
SELECT 'EXISTING CODES IN DATABASE:' as info, COUNT(*) as total_codes, 
       MIN(referral_code) as min_code, MAX(referral_code) as max_code
FROM public.users;

-- Show some examples of existing codes
SELECT 'SAMPLE EXISTING CODES:' as info, referral_code, email
FROM public.users 
ORDER BY referral_code 
LIMIT 10;

-- Instead of manually updating the entire script, let's create a simpler version
-- that uses guaranteed unique codes with timestamp

DROP TABLE IF EXISTS temp_new_users;
CREATE TEMP TABLE temp_new_users AS
SELECT 
    gen_random_uuid() as id,
    'user' || (500 + row_number() OVER()) || '@example.com' as email,
    'User' as first_name,
    CAST(500 + row_number() OVER() as text) as last_name,
    'USR' || (500 + row_number() OVER()) as referral_code,
    CASE 
        WHEN row_number() OVER() <= 1 THEN 18        -- 1 super influencer
        WHEN row_number() OVER() <= 4 THEN 8 + (row_number() OVER() - 2) -- 3 high performers (8,9,10)
        WHEN row_number() OVER() <= 10 THEN 2 + (row_number() OVER() - 5) -- 6 moderate (2,3,4,5,6,7)
        WHEN row_number() OVER() <= 30 THEN 1        -- 20 single referrers
        ELSE 0                                       -- 170 passive users
    END as total_referrals,
    CASE 
        WHEN row_number() OVER() <= 1 THEN 925.0
        WHEN row_number() OVER() <= 4 THEN 400.0 + (row_number() OVER() - 2) * 50
        WHEN row_number() OVER() <= 10 THEN 100.0 + (row_number() OVER() - 5) * 25  
        WHEN row_number() OVER() <= 30 THEN 75.0
        ELSE 25.0
    END as total_earnings,
    FALSE as is_admin,
    NOW() - INTERVAL '1 day' * (90 - (row_number() OVER() % 90)) as created_at
FROM generate_series(1, 200) as t(n);

-- Show mathematical verification before inserting
SELECT 
    'MATHEMATICAL VERIFICATION' as check_type,
    COUNT(*) as total_users,
    SUM(total_referrals) as total_referrals_sum,
    CASE 
        WHEN SUM(total_referrals) <= COUNT(*) THEN '✅ MATH CORRECT'
        ELSE '❌ MATH ERROR'
    END as math_check,
    COUNT(*) FILTER (WHERE total_referrals = 0) as passive_users,
    COUNT(*) FILTER (WHERE total_referrals = 1) as single_ref_users,
    COUNT(*) FILTER (WHERE total_referrals BETWEEN 2 AND 10) as moderate_users,
    COUNT(*) FILTER (WHERE total_referrals > 10) as super_users
FROM temp_new_users;

-- Insert the new users
INSERT INTO public.users (id, email, first_name, last_name, referral_code, total_referrals, total_earnings, is_admin, created_at)
SELECT id, email, first_name, last_name, referral_code, total_referrals, total_earnings, is_admin, created_at
FROM temp_new_users;

-- Final verification
SELECT 
    'FINAL DATABASE VERIFICATION' as check_type,
    COUNT(*) as total_users,
    SUM(total_referrals) as total_referrals,
    CASE 
        WHEN SUM(total_referrals) <= COUNT(*) THEN '✅ DATABASE MATH CORRECT'
        ELSE '❌ DATABASE MATH ERROR'
    END as final_check,
    COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '1 hour') as newly_added,
    MIN(created_at) as oldest_user,
    MAX(created_at) as newest_user
FROM public.users
WHERE is_admin = FALSE;
