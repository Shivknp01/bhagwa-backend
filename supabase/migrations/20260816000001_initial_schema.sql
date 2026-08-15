-- ==============================================================================
-- BHAGWA BACKEND MIGRATION: 20260816000001_initial_schema.sql
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. ENUMS
CREATE TYPE content_type AS ENUM (
  'wallpaper',
  'video',
  'music',
  'bhajan',
  'ringtone',
  'mantra',
  'stuti',
  'status',
  'horoscope'
);

CREATE TYPE post_status AS ENUM (
  'draft',
  'published',
  'scheduled',
  'archived'
);

CREATE TYPE user_status AS ENUM (
  'active',
  'inactive',
  'banned'
);

CREATE TYPE report_reason AS ENUM (
  'spam',
  'abuse',
  'inappropriate',
  'copyright',
  'other'
);

CREATE TYPE report_status AS ENUM (
  'pending',
  'reviewed',
  'resolved',
  'dismissed'
);

CREATE TYPE comment_status AS ENUM (
  'active',
  'hidden',
  'deleted'
);

CREATE TYPE payment_status AS ENUM (
  'success',
  'pending',
  'refunded',
  'failed'
);

CREATE TYPE payment_platform AS ENUM (
  'google_play',
  'apple',
  'web_upi'
);

CREATE TYPE notification_status AS ENUM (
  'draft',
  'scheduled',
  'sent'
);

CREATE TYPE admin_role AS ENUM (
  'super_admin',
  'content_admin',
  'moderator',
  'analyst'
);

-- 3. CORE USER & PROFILES TABLES
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL DEFAULT 'Devotee',
  phone_number TEXT,
  email TEXT,
  avatar_url TEXT,
  language TEXT NOT NULL DEFAULT 'en',
  is_premium BOOLEAN NOT NULL DEFAULT FALSE,
  status user_status NOT NULL DEFAULT 'active',
  last_active_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  app_language TEXT NOT NULL DEFAULT 'en',
  preferred_deities TEXT[] DEFAULT ARRAY['Mahadev', 'Hanuman', 'Krishna'],
  preferred_content_types TEXT[] DEFAULT ARRAY['Bhajans', 'Wallpapers', 'Mantras'],
  notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  morning_notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  night_notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  comment_notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  marketing_notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. DEITIES & CATEGORIES
CREATE TABLE public.deities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  slug TEXT NOT NULL UNIQUE,
  title TEXT,
  symbol TEXT NOT NULL DEFAULT '🚩',
  icon_key TEXT,
  image_url TEXT,
  description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  slug TEXT NOT NULL UNIQUE,
  emoji TEXT NOT NULL DEFAULT '🚩',
  sub_label TEXT,
  gradient_colors TEXT[],
  description TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. CENTRAL POSTS TABLE
CREATE TABLE public.posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_type content_type NOT NULL,
  title TEXT NOT NULL,
  title_hi TEXT,
  description TEXT,
  description_hi TEXT,
  deity_id UUID REFERENCES public.deities(id) ON DELETE SET NULL,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  language TEXT NOT NULL DEFAULT 'Hindi',
  tags TEXT[] DEFAULT ARRAY[]::TEXT[],
  action_type TEXT NOT NULL,
  action_label TEXT NOT NULL,
  action_label_hi TEXT,
  author_name TEXT NOT NULL DEFAULT 'Bhakti Media',
  thumbnail_url TEXT,
  media_url TEXT,
  audio_url TEXT,
  duration_text TEXT,
  
  -- Actual Analytics Counters (Aggregated)
  actual_views INT NOT NULL DEFAULT 0,
  actual_likes INT NOT NULL DEFAULT 0,
  actual_comments INT NOT NULL DEFAULT 0,
  actual_shares INT NOT NULL DEFAULT 0,
  actual_saves INT NOT NULL DEFAULT 0,
  actual_audio_plays INT NOT NULL DEFAULT 0,
  actual_wallpaper_sets INT NOT NULL DEFAULT 0,
  actual_ringtone_sets INT NOT NULL DEFAULT 0,

  -- Admin Display Overrides (Independent of Actuals)
  view_override INT,
  like_override INT,
  comment_override INT,
  share_override INT,
  save_override INT,
  audio_play_override INT,
  wallpaper_set_override INT,
  ringtone_set_override INT,

  views_override_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  likes_override_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  comments_override_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  shares_override_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  saves_override_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  audio_plays_override_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  wallpaper_sets_override_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  ringtone_sets_override_enabled BOOLEAN NOT NULL DEFAULT FALSE,

  is_featured BOOLEAN NOT NULL DEFAULT FALSE,
  is_pinned BOOLEAN NOT NULL DEFAULT FALSE,
  is_premium BOOLEAN NOT NULL DEFAULT FALSE,
  status post_status NOT NULL DEFAULT 'published',
  feed_priority INT NOT NULL DEFAULT 0,
  published_at TIMESTAMPTZ DEFAULT NOW(),
  scheduled_at TIMESTAMPTZ,
  created_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. MEDIA METADATA (CLOUDFLARE R2 REFERENCES)
CREATE TABLE public.post_media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  media_type TEXT NOT NULL, -- 'image', 'video', 'audio'
  r2_key TEXT NOT NULL,
  media_url TEXT NOT NULL,
  thumbnail_url TEXT,
  mime_type TEXT,
  file_size INT,
  duration_seconds INT,
  width INT,
  height INT,
  source_type TEXT, -- 'original', 'youtube', 'custom'
  source_url TEXT,
  source_creator TEXT,
  license_type TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. CONTENT SPECIFIC TABLES
CREATE TABLE public.mantras (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID UNIQUE NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  mantra_text TEXT NOT NULL,
  mantra_meaning TEXT,
  mantra_meaning_hi TEXT,
  chanting_count INT DEFAULT 108,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.stutis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID UNIQUE NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  stuti_text TEXT NOT NULL,
  stuti_meaning TEXT,
  stuti_meaning_hi TEXT,
  author TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.horoscopes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  zodiac_sign TEXT NOT NULL,
  zodiac_sign_hi TEXT,
  symbol TEXT NOT NULL,
  date TEXT NOT NULL DEFAULT 'Today',
  overview TEXT NOT NULL,
  overview_hi TEXT,
  lucky_number TEXT,
  lucky_color TEXT,
  lucky_time TEXT,
  advice TEXT,
  advice_hi TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. USER INTERACTION TABLES (LIKES, COMMENTS, SAVES, SHARES, VIEWS)
CREATE TABLE public.post_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_post_user_like UNIQUE (post_id, user_id)
);

CREATE TABLE public.post_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  parent_comment_id UUID REFERENCES public.post_comments(id) ON DELETE CASCADE,
  comment_text TEXT NOT NULL,
  status comment_status NOT NULL DEFAULT 'active',
  likes_count INT NOT NULL DEFAULT 0,
  reports_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.post_saves (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_post_user_save UNIQUE (post_id, user_id)
);

CREATE TABLE public.post_shares (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  platform TEXT NOT NULL DEFAULT 'whatsapp',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.post_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  view_duration_seconds INT DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9. FEED ITEMS (FEED ORDER & PINNING)
CREATE TABLE public.feed_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  position INT NOT NULL DEFAULT 0,
  is_pinned BOOLEAN NOT NULL DEFAULT FALSE,
  is_featured BOOLEAN NOT NULL DEFAULT FALSE,
  is_visible BOOLEAN NOT NULL DEFAULT TRUE,
  scheduled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 10. NOTIFICATION CAMPAIGNS & FCM DEVICES
CREATE TABLE public.notification_campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  image_url TEXT,
  deep_link TEXT,
  audience TEXT NOT NULL DEFAULT 'All Users',
  scheduled_at TIMESTAMPTZ,
  sent_at TIMESTAMPTZ,
  status notification_status NOT NULL DEFAULT 'draft',
  sent_count INT NOT NULL DEFAULT 0,
  delivered_count INT NOT NULL DEFAULT 0,
  opened_count INT NOT NULL DEFAULT 0,
  created_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.user_devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL UNIQUE,
  platform TEXT NOT NULL DEFAULT 'android',
  app_version TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_seen_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 11. REFERRAL SYSTEM
CREATE TABLE public.referral_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  code TEXT UNIQUE NOT NULL,
  shares_count INT NOT NULL DEFAULT 0,
  clicks_count INT NOT NULL DEFAULT 0,
  installs_count INT NOT NULL DEFAULT 0,
  registrations_count INT NOT NULL DEFAULT 0,
  paid_conversions_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.referrals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  referred_user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  referral_code TEXT NOT NULL,
  source TEXT NOT NULL DEFAULT 'whatsapp',
  has_purchased BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 12. PAYMENTS & SUBSCRIPTIONS
CREATE TABLE public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  plan TEXT NOT NULL,
  amount INT NOT NULL,
  currency TEXT NOT NULL DEFAULT 'INR',
  status TEXT NOT NULL DEFAULT 'active',
  auto_renew BOOLEAN NOT NULL DEFAULT TRUE,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.subscription_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id UUID REFERENCES public.subscriptions(id) ON DELETE SET NULL,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  transaction_id TEXT UNIQUE NOT NULL,
  platform payment_platform NOT NULL DEFAULT 'google_play',
  product_id TEXT NOT NULL,
  amount INT NOT NULL,
  currency TEXT NOT NULL DEFAULT 'INR',
  status payment_status NOT NULL DEFAULT 'success',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 13. MODERATION & REPORTS
CREATE TABLE public.reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  content_type TEXT NOT NULL,
  content_id UUID NOT NULL,
  reason report_reason NOT NULL,
  description TEXT,
  status report_status NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.moderation_actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_user_id UUID NOT NULL,
  action_type TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id UUID NOT NULL,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 14. ADMIN SECURITY & AUDIT LOGS
CREATE TABLE public.admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  role admin_role NOT NULL DEFAULT 'content_admin',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.admin_audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_user_id UUID NOT NULL REFERENCES public.admin_users(id) ON DELETE CASCADE,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  action TEXT NOT NULL,
  old_value JSONB,
  new_value JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 15. APP SETTINGS & FEATURE FLAGS
CREATE TABLE public.app_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  setting_key TEXT UNIQUE NOT NULL,
  setting_value JSONB NOT NULL,
  description TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.feature_flags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  flag_key TEXT UNIQUE NOT NULL,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  metadata JSONB,
  description TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 16. ANALYTICS EVENTS & DAILY AGGREGATIONS
CREATE TABLE public.analytics_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  event_name TEXT NOT NULL,
  post_id UUID REFERENCES public.posts(id) ON DELETE SET NULL,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.daily_content_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL,
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  views_count INT DEFAULT 0,
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  shares_count INT DEFAULT 0,
  saves_count INT DEFAULT 0,
  audio_plays_count INT DEFAULT 0,
  wallpaper_sets_count INT DEFAULT 0,
  ringtone_sets_count INT DEFAULT 0,
  CONSTRAINT unique_daily_post_metric UNIQUE (date, post_id)
);

-- 17. PERFORMANCE INDEXES
CREATE INDEX idx_posts_status ON public.posts(status);
CREATE INDEX idx_posts_content_type ON public.posts(content_type);
CREATE INDEX idx_posts_published_at ON public.posts(published_at DESC);
CREATE INDEX idx_posts_deity_id ON public.posts(deity_id);
CREATE INDEX idx_posts_category_id ON public.posts(category_id);

CREATE INDEX idx_feed_items_position ON public.feed_items(position);
CREATE INDEX idx_feed_items_is_pinned ON public.feed_items(is_pinned);

CREATE INDEX idx_post_likes_post_id ON public.post_likes(post_id);
CREATE INDEX idx_post_likes_user_id ON public.post_likes(user_id);
CREATE INDEX idx_post_comments_post_id ON public.post_comments(post_id);
CREATE INDEX idx_post_saves_user_id ON public.post_saves(user_id);

CREATE INDEX idx_analytics_events_created_at ON public.analytics_events(created_at DESC);
CREATE INDEX idx_analytics_events_event_name ON public.analytics_events(event_name);
CREATE INDEX idx_subscriptions_user_id ON public.subscriptions(user_id);
