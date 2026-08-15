-- ==============================================================================
-- BHAGWA BACKEND MIGRATION: 20260816000002_rls_policies.sql
-- ==============================================================================

-- 1. ENABLE ROW LEVEL SECURITY ON ALL TABLES
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mantras ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stutis ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.horoscopes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_saves ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feed_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.moderation_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feature_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_content_metrics ENABLE ROW LEVEL SECURITY;

-- 2. HELPER FUNCTION TO CHECK IF CURRENT USER IS AN ADMIN
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.admin_users
    WHERE auth_user_id = auth.uid()
      AND is_active = TRUE
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. PUBLIC READ POLICIES (EVERYONE CAN READ)
CREATE POLICY "Public deities read" ON public.deities FOR SELECT USING (is_active = TRUE);
CREATE POLICY "Public categories read" ON public.categories FOR SELECT USING (is_active = TRUE);
CREATE POLICY "Public published posts read" ON public.posts FOR SELECT USING (status = 'published' AND published_at <= NOW());
CREATE POLICY "Public post media read" ON public.post_media FOR SELECT USING (TRUE);
CREATE POLICY "Public mantras read" ON public.mantras FOR SELECT USING (TRUE);
CREATE POLICY "Public stutis read" ON public.stutis FOR SELECT USING (TRUE);
CREATE POLICY "Public horoscopes read" ON public.horoscopes FOR SELECT USING (TRUE);
CREATE POLICY "Public active comments read" ON public.post_comments FOR SELECT USING (status = 'active');
CREATE POLICY "Public feed items read" ON public.feed_items FOR SELECT USING (is_visible = TRUE);
CREATE POLICY "Public app settings read" ON public.app_settings FOR SELECT USING (TRUE);
CREATE POLICY "Public feature flags read" ON public.feature_flags FOR SELECT USING (enabled = TRUE);

-- 4. USER PROFILE & PREFERENCES POLICIES
CREATE POLICY "Users view own profile" ON public.profiles FOR SELECT USING (auth_user_id = auth.uid());
CREATE POLICY "Users update own profile" ON public.profiles FOR UPDATE USING (auth_user_id = auth.uid());

CREATE POLICY "Users view own preferences" ON public.user_preferences FOR SELECT USING (
  user_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())
);
CREATE POLICY "Users update own preferences" ON public.user_preferences FOR UPDATE USING (
  user_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid())
);

-- 5. USER INTERACTION POLICIES (LIKES, SAVES, COMMENTS, SHARES)
CREATE POLICY "Users manage own likes" ON public.post_likes
  FOR ALL USING (user_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users manage own saves" ON public.post_saves
  FOR ALL USING (user_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users create comments" ON public.post_comments
  FOR INSERT WITH CHECK (user_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users edit/delete own comments" ON public.post_comments
  FOR UPDATE USING (user_id IN (SELECT id FROM public.profiles WHERE auth_user_id = auth.uid()));

CREATE POLICY "Users insert shares" ON public.post_shares
  FOR INSERT WITH CHECK (TRUE);

CREATE POLICY "Users insert views" ON public.post_views
  FOR INSERT WITH CHECK (TRUE);

CREATE POLICY "Users insert analytics events" ON public.analytics_events
  FOR INSERT WITH CHECK (TRUE);

-- 6. ADMIN FULL ACCESS POLICIES (ADMINS CAN MANAGE ALL CONTENT)
CREATE POLICY "Admin full posts access" ON public.posts FOR ALL USING (public.is_admin());
CREATE POLICY "Admin full media access" ON public.post_media FOR ALL USING (public.is_admin());
CREATE POLICY "Admin full deities access" ON public.deities FOR ALL USING (public.is_admin());
CREATE POLICY "Admin full categories access" ON public.categories FOR ALL USING (public.is_admin());
CREATE POLICY "Admin full feed access" ON public.feed_items FOR ALL USING (public.is_admin());
CREATE POLICY "Admin full notifications access" ON public.notification_campaigns FOR ALL USING (public.is_admin());
CREATE POLICY "Admin full moderation access" ON public.reports FOR ALL USING (public.is_admin());
CREATE POLICY "Admin full audit log access" ON public.admin_audit_logs FOR ALL USING (public.is_admin());
CREATE POLICY "Admin full settings access" ON public.app_settings FOR ALL USING (public.is_admin());
CREATE POLICY "Admin full feature flags access" ON public.feature_flags FOR ALL USING (public.is_admin());
