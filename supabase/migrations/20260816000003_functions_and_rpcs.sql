-- ==============================================================================
-- BHAGWA BACKEND MIGRATION: 20260816000003_functions_and_rpcs.sql
-- ==============================================================================

-- 1. TRIGGER: AUTOMATIC PROFILE & PREFERENCES ON USER SIGNUP
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_profile_id UUID;
BEGIN
  INSERT INTO public.profiles (auth_user_id, email, display_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Devotee')
  )
  RETURNING id INTO v_profile_id;

  INSERT INTO public.user_preferences (user_id)
  VALUES (v_profile_id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 2. TOGGLE LIKE RPC
CREATE OR REPLACE FUNCTION public.toggle_like(p_post_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_user_id UUID;
  v_is_liked BOOLEAN;
  v_new_count INT;
BEGIN
  SELECT id INTO v_user_id FROM public.profiles WHERE auth_user_id = auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User profile not found or user not authenticated';
  END IF;

  IF EXISTS (SELECT 1 FROM public.post_likes WHERE post_id = p_post_id AND user_id = v_user_id) THEN
    DELETE FROM public.post_likes WHERE post_id = p_post_id AND user_id = v_user_id;
    UPDATE public.posts SET actual_likes = GREATEST(0, actual_likes - 1) WHERE id = p_post_id RETURNING actual_likes INTO v_new_count;
    v_is_liked := FALSE;
  ELSE
    INSERT INTO public.post_likes (post_id, user_id) VALUES (p_post_id, v_user_id);
    UPDATE public.posts SET actual_likes = actual_likes + 1 WHERE id = p_post_id RETURNING actual_likes INTO v_new_count;
    v_is_liked := TRUE;
  END IF;

  RETURN jsonb_build_object('is_liked', v_is_liked, 'likes_count', v_new_count);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. TOGGLE SAVE RPC
CREATE OR REPLACE FUNCTION public.toggle_save(p_post_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_user_id UUID;
  v_is_saved BOOLEAN;
  v_new_count INT;
BEGIN
  SELECT id INTO v_user_id FROM public.profiles WHERE auth_user_id = auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User profile not found or user not authenticated';
  END IF;

  IF EXISTS (SELECT 1 FROM public.post_saves WHERE post_id = p_post_id AND user_id = v_user_id) THEN
    DELETE FROM public.post_saves WHERE post_id = p_post_id AND user_id = v_user_id;
    UPDATE public.posts SET actual_saves = GREATEST(0, actual_saves - 1) WHERE id = p_post_id RETURNING actual_saves INTO v_new_count;
    v_is_saved := FALSE;
  ELSE
    INSERT INTO public.post_saves (post_id, user_id) VALUES (p_post_id, v_user_id);
    UPDATE public.posts SET actual_saves = actual_saves + 1 WHERE id = p_post_id RETURNING actual_saves INTO v_new_count;
    v_is_saved := TRUE;
  END IF;

  RETURN jsonb_build_object('is_saved', v_is_saved, 'saves_count', v_new_count);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. INCREMENT CONTENT METRIC RPC (INCREMENTS VIEWS, SHARES, PLAYS, WALLPAPER SETS)
CREATE OR REPLACE FUNCTION public.increment_content_metric(
  p_post_id UUID,
  p_metric_type TEXT
)
RETURNS VOID AS $$
BEGIN
  IF p_metric_type = 'view' THEN
    UPDATE public.posts SET actual_views = actual_views + 1 WHERE id = p_post_id;
  ELSIF p_metric_type = 'share' THEN
    UPDATE public.posts SET actual_shares = actual_shares + 1 WHERE id = p_post_id;
  ELSIF p_metric_type = 'audio_play' THEN
    UPDATE public.posts SET actual_audio_plays = actual_audio_plays + 1 WHERE id = p_post_id;
  ELSIF p_metric_type = 'wallpaper_set' THEN
    UPDATE public.posts SET actual_wallpaper_sets = actual_wallpaper_sets + 1 WHERE id = p_post_id;
  ELSIF p_metric_type = 'ringtone_set' THEN
    UPDATE public.posts SET actual_ringtone_sets = actual_ringtone_sets + 1 WHERE id = p_post_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. GET FEED RPC (RETURNS DISPLAY METRICS ACCORDING TO ADMIN OVERRIDE RULE)
CREATE OR REPLACE FUNCTION public.get_feed(
  p_category TEXT DEFAULT 'All',
  p_deity TEXT DEFAULT 'All',
  p_limit INT DEFAULT 20,
  p_offset INT DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  content_type content_type,
  title TEXT,
  title_hi TEXT,
  description TEXT,
  description_hi TEXT,
  thumbnail_url TEXT,
  media_url TEXT,
  audio_url TEXT,
  deity_name TEXT,
  category_name TEXT,
  displayed_views INT,
  displayed_likes INT,
  displayed_comments INT,
  displayed_shares INT,
  displayed_saves INT,
  is_featured BOOLEAN,
  is_pinned BOOLEAN,
  published_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.content_type,
    p.title,
    p.title_hi,
    p.description,
    p.description_hi,
    p.thumbnail_url,
    p.media_url,
    p.audio_url,
    d.name AS deity_name,
    c.name AS category_name,
    CASE WHEN p.views_override_enabled AND p.view_override IS NOT NULL THEN p.view_override ELSE p.actual_views END AS displayed_views,
    CASE WHEN p.likes_override_enabled AND p.like_override IS NOT NULL THEN p.like_override ELSE p.actual_likes END AS displayed_likes,
    CASE WHEN p.comments_override_enabled AND p.comment_override IS NOT NULL THEN p.comment_override ELSE p.actual_comments END AS displayed_comments,
    CASE WHEN p.shares_override_enabled AND p.share_override IS NOT NULL THEN p.share_override ELSE p.actual_shares END AS displayed_shares,
    CASE WHEN p.saves_override_enabled AND p.save_override IS NOT NULL THEN p.save_override ELSE p.actual_saves END AS displayed_saves,
    p.is_featured,
    p.is_pinned,
    p.published_at
  FROM public.posts p
  LEFT JOIN public.deities d ON p.deity_id = d.id
  LEFT JOIN public.categories c ON p.category_id = c.id
  WHERE p.status = 'published'
    AND p.published_at <= NOW()
    AND (p_category = 'All' OR c.name = p_category OR p.content_type::TEXT = LOWER(p_category))
    AND (p_deity = 'All' OR d.name = p_deity)
  ORDER BY p.is_pinned DESC, p.feed_priority DESC, p.published_at DESC
  LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE;

-- 6. DASHBOARD OVERVIEW STATS RPC FOR ADMIN DASHBOARD
CREATE OR REPLACE FUNCTION public.get_dashboard_overview()
RETURNS JSONB AS $$
DECLARE
  v_total_users INT;
  v_new_users_today INT;
  v_active_users INT;
  v_premium_users INT;
  v_total_revenue INT;
  v_total_views INT;
  v_total_likes INT;
BEGIN
  SELECT COUNT(*) INTO v_total_users FROM public.profiles;
  SELECT COUNT(*) INTO v_new_users_today FROM public.profiles WHERE created_at >= CURRENT_DATE;
  SELECT COUNT(*) INTO v_active_users FROM public.profiles WHERE last_active_at >= NOW() - INTERVAL '24 hours';
  SELECT COUNT(*) INTO v_premium_users FROM public.profiles WHERE is_premium = TRUE;
  SELECT COALESCE(SUM(amount), 0) INTO v_total_revenue FROM public.subscription_transactions WHERE status = 'success';
  SELECT COALESCE(SUM(actual_views), 0) INTO v_total_views FROM public.posts;
  SELECT COALESCE(SUM(actual_likes), 0) INTO v_total_likes FROM public.posts;

  RETURN jsonb_build_object(
    'total_users', v_total_users,
    'new_users_today', v_new_users_today,
    'active_users', v_active_users,
    'premium_users', v_premium_users,
    'total_revenue', v_total_revenue,
    'total_views', v_total_views,
    'total_likes', v_total_likes
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
