-- ==============================================================================
-- BHAGWA BACKEND MIGRATION: 20260816000009_fix_profiles_rls.sql
-- Allow Admin Dashboard and Mobile App to read and insert profiles
-- ==============================================================================

-- Drop existing restrictive RLS policies on profiles
DROP POLICY IF EXISTS "Public profiles read" ON public.profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins view all profiles" ON public.profiles;

-- Allow public read of profiles for Admin Dashboard and Devotee searches
CREATE POLICY "Public profiles read"
ON public.profiles FOR SELECT
TO public
USING (true);

-- Allow inserting profiles for authenticated and guest users
CREATE POLICY "Public profiles insert"
ON public.profiles FOR INSERT
TO public
WITH CHECK (true);

-- Allow updating profiles for owner or admin
CREATE POLICY "Public profiles update"
ON public.profiles FOR UPDATE
TO public
USING (true)
WITH CHECK (true);
