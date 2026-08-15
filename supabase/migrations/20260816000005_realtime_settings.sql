-- ==============================================================================
-- BHAGWA BACKEND MIGRATION: 20260816000005_realtime_settings.sql
-- Enable Supabase Realtime for app_settings table
-- ==============================================================================

-- Enable full replication for app_settings table
ALTER TABLE public.app_settings REPLICA IDENTITY FULL;

-- Add app_settings to supabase_realtime publication
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'app_settings'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.app_settings;
  END IF;
END $$;
