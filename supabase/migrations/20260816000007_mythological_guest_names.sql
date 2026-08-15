-- ==============================================================================
-- BHAGWA BACKEND MIGRATION: 20260816000007_mythological_guest_names.sql
-- Hindu Mythological Default User Names for Skip/Guest Logins
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  v_profile_id UUID;
  v_user_id BIGINT;
  v_login_method TEXT;
  v_is_anonymous BOOLEAN;
  v_display_name TEXT;
  v_mythological_prefix TEXT;
  v_prefixes TEXT[] := ARRAY[
    'Shiv_Bhakta',
    'Ram_Bhakta',
    'Hanuman_Sevak',
    'Krishna_Prem',
    'Mahakal_Bhakta',
    'Narayan_Bhakta',
    'Durga_Bhakta',
    'Ganesh_Bhakta',
    'Bhole_Bhakta',
    'Pawanputra_Bhakta'
  ];
BEGIN
  -- Determine provider from auth metadata
  v_login_method := COALESCE(NEW.raw_app_meta_data->>'provider', 'skip');
  IF v_login_method = 'anonymous' THEN
    v_login_method := 'skip';
    v_is_anonymous := TRUE;
  ELSE
    v_is_anonymous := COALESCE((NEW.raw_user_meta_data->>'is_anonymous')::boolean, FALSE);
  END IF;

  v_display_name := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'name'
  );

  -- If name is empty or user is anonymous guest, pick a Hindu mythological name
  IF v_display_name IS NULL OR v_display_name = '' OR v_is_anonymous THEN
    v_mythological_prefix := v_prefixes[1 + floor(random() * array_length(v_prefixes, 1))::int];
    -- Generate placeholder name; will be appended with sequence in trigger or update
    v_display_name := v_mythological_prefix || '_' || floor(random() * 8999 + 1000)::text;
  END IF;

  INSERT INTO public.profiles (
    auth_user_id,
    email,
    phone_number,
    display_name,
    avatar_url,
    login_method,
    is_anonymous
  )
  VALUES (
    NEW.id,
    NEW.email,
    NEW.phone,
    v_display_name,
    NEW.raw_user_meta_data->>'avatar_url',
    v_login_method,
    v_is_anonymous
  )
  ON CONFLICT (auth_user_id) DO UPDATE SET
    last_active_at = NOW()
  RETURNING id, user_id INTO v_profile_id, v_user_id;

  -- If it was a guest creation, update display name with actual sequence numeric ID
  IF v_is_anonymous OR NEW.raw_user_meta_data->>'name' IS NULL THEN
    UPDATE public.profiles
    SET display_name = v_mythological_prefix || '_' || v_user_id
    WHERE id = v_profile_id;
  END IF;

  -- Create default user preferences if not existing
  INSERT INTO public.user_preferences (user_id)
  VALUES (v_profile_id)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
