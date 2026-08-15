-- ==============================================================================
-- BHAGWA BACKEND MIGRATION: 20260816000006_fix_settings_rls.sql
-- Allow updating app_settings table
-- ==============================================================================

-- Drop existing policies on app_settings if exist
DROP POLICY IF EXISTS "Admin full settings access" ON public.app_settings;
DROP POLICY IF EXISTS "Public app settings write" ON public.app_settings;
DROP POLICY IF EXISTS "Public app settings read" ON public.app_settings;

-- Allow public read of app_settings
CREATE POLICY "Public app settings read"
ON public.app_settings FOR SELECT
TO public
USING (true);

-- Allow modifying app_settings for service_role and admin dashboard clients
CREATE POLICY "Public app settings write"
ON public.app_settings FOR ALL
TO public
USING (true)
WITH CHECK (true);
