-- ==============================================================================
-- BHAGWA BACKEND SEED DATA: supabase/seed.sql
-- ==============================================================================

-- 1. SEED DEITIES
INSERT INTO public.deities (id, name, slug, title, symbol, icon_key, description) VALUES
('11111111-1111-1111-1111-111111111111', 'Mahadev', 'mahadev', 'Lord Shiva', '🔱', 'om', 'The supreme lord of destruction, meditation, and cosmic dance.'),
('22222222-2222-2222-2222-222222222222', 'Hanuman', 'hanuman', 'Sankat Mochan', '🙏', 'gada', 'The ultimate symbol of devotion, strength, and protection.'),
('33333333-3333-3333-3333-333333333333', 'Krishna', 'krishna', 'Murlidhar', '🦚', 'flute', 'The divine flute player, embodiment of love and wisdom.'),
('44444444-4444-4444-4444-444444444444', 'Shri Ram', 'ram', 'Maryada Purushottam', '🏹', 'bow', 'The ideal man, protector of righteousness and virtue.'),
('55555555-5555-5555-5555-555555555555', 'Ganesh', 'ganesh', 'Vighnaharta', '🐘', 'modak', 'The remover of all obstacles and harbinger of wisdom.'),
('66666666-6666-6666-6666-666666666666', 'Durga', 'durga', 'Maa Ambe', '🌺', 'trishul', 'The supreme divine mother and destroyer of negativity.'),
('77777777-7777-7777-7777-777777777777', 'Lakshmi', 'lakshmi', 'Maa Lakshmi', '✨', 'lotus', 'The goddess of wealth, prosperity, and spiritual abundance.'),
('88888888-8888-8888-8888-888888888888', 'Saraswati', 'saraswati', 'Maa Sharda', '🎻', 'veena', 'The goddess of knowledge, music, arts, and wisdom.')
ON CONFLICT (name) DO NOTHING;

-- 2. SEED CATEGORIES
INSERT INTO public.categories (id, name, slug, emoji, sub_label, gradient_colors) VALUES
('a1111111-1111-1111-1111-111111111111', 'All', 'all', '🚩', 'पावन संगम', ARRAY['#D84315', '#FF6D00', '#FFB300']),
('a2222222-2222-2222-2222-222222222222', 'Wallpaper', 'wallpaper', '🖼', 'HD वॉलपेपर', ARRAY['#E65100', '#F57C00', '#FFB74D']),
('a3333333-3333-3333-3333-333333333333', 'Bhajan', 'bhajan', '🙏', 'मधुर भजन', ARRAY['#C2185B', '#E91E63', '#F48FB1']),
('a4444444-4444-4444-4444-444444444444', 'Music', 'music', '🎵', 'भक्ति संगीत', ARRAY['#7B1FA2', '#9C27B0', '#CE93D8']),
('a5555555-5555-5555-5555-555555555555', 'Ringtone', 'ringtone', '🔔', 'फोन रिंगटोन', ARRAY['#0097A7', '#00BCD4', '#80DEEA']),
('a6666666-6666-6666-6666-666666666666', 'Mantra', 'mantra', '🕉', 'वेदिक मंत्र', ARRAY['#388E3C', '#4CAF50', '#A5D6A7']),
('a7777777-7777-7777-7777-777777777777', 'Stuti', 'stuti', '📖', 'पवित्र स्तुति', ARRAY['#F57F17', '#FBC02D', '#FFF59D']),
('a8888888-8888-8888-8888-888888888888', 'Horoscope', 'horoscope', '🔮', 'आज का राशिफल', ARRAY['#512DA8', '#673AB7', '#B39DDB']),
('a9999999-9999-9999-9999-999999999999', 'Status', 'status', '📱', 'स्टेटस शेयर', ARRAY['#D32F2F', '#F44336', '#EF9A9A'])
ON CONFLICT (name) DO NOTHING;

-- 3. SEED SAMPLE POSTS
INSERT INTO public.posts (
  id, content_type, title, title_hi, description, description_hi, deity_id, category_id,
  language, action_type, action_label, action_label_hi, author_name, thumbnail_url, media_url, audio_url,
  actual_views, actual_likes, actual_comments, actual_shares, actual_saves, is_featured, is_pinned, status
) VALUES
(
  'b1111111-1111-1111-1111-111111111111',
  'status',
  '🙏 Good Morning - Har Har Mahadev',
  '🙏 शुभ प्रभात - हर हर महादेव',
  'May Lord Shiva shower endless peace, good health, and prosperous energy upon you and your family today. Har Har Mahadev! 🔱',
  'भगवान शिव आपके और आपके परिवार पर सुख, शांति, उत्तम स्वास्थ्य और समृद्धि की वर्षा करें।',
  '11111111-1111-1111-1111-111111111111',
  'a9999999-9999-9999-9999-999999999999',
  'Hindi',
  'shareStatus',
  'Share on WhatsApp',
  'व्हाट्सएप पर शेयर करें',
  'Mahakal Darshan',
  'https://images.unsplash.com/photo-1567157577867-05ccb1388e66?q=80&w=800&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1567157577867-05ccb1388e66?q=80&w=1200&auto=format&fit=crop',
  NULL,
  82400, 24500, 1830, 12400, 5120, TRUE, TRUE, 'published'
),
(
  'b2222222-2222-2222-2222-222222222222',
  'wallpaper',
  '🖼 Sacred 4K Mahadev Meditation Wallpaper',
  '🖼 अलौकिक 4K महादेव ध्यान वॉलपेपर',
  'Ultra HD 4K Sacred Mahadev Meditation Wallpaper. Set this divine image on your home screen or lock screen.',
  'अल्ट्रा एचडी ४के दिव्य महादेव ध्यान वॉलपेपर। इसे अपनी होम स्क्रीन पर लगाएं।',
  '11111111-1111-1111-1111-111111111111',
  'a2222222-2222-2222-2222-222222222222',
  'Hindi',
  'setWallpaper',
  'Set Wallpaper',
  'वॉलपेपर लगाएं',
  'Divine Wallpapers',
  'https://images.unsplash.com/photo-1609137144813-7d9921338f24?q=80&w=800&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1609137144813-7d9921338f24?q=80&w=1600&auto=format&fit=crop',
  NULL,
  120500, 32000, 2100, 8900, 14200, TRUE, FALSE, 'published'
),
(
  'b3333333-3333-3333-3333-333333333333',
  'bhajan',
  '🎵 Mera Bhola Hai Bhandari Kare Nandi Ki Sawari',
  '🎵 मेरा भोला है भंडारी करे नंदी की सवारी',
  'Listen to the soulful Mahadev Bhajan filled with divine flute harmony and peaceful chanting.',
  'सुनिए मनमोहक महादेव भजन "मेरा भोला है भंडारी करे नंदी की सवारी"।',
  '11111111-1111-1111-1111-111111111111',
  'a3333333-3333-3333-3333-333333333333',
  'Hindi',
  'playBhajan',
  'Play Bhajan',
  'भजन बजाएं',
  'Bhakti Sagar',
  'https://images.unsplash.com/photo-1544717305-2782549b5136?q=80&w=800&auto=format&fit=crop',
  NULL,
  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  54000, 18000, 920, 4100, 6300, FALSE, FALSE, 'published'
)
ON CONFLICT (id) DO NOTHING;

-- 4. SEED MANTRA DETAILS
INSERT INTO public.mantras (post_id, mantra_text, mantra_meaning, mantra_meaning_hi, chanting_count) VALUES
(
  'b1111111-1111-1111-1111-111111111111',
  'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्। उर्वारुकमिव बन्धनान्मृत्योर्मुक्षीय माऽमृतात्॥',
  'We worship the Three-eyed Lord Shiva who is fragrant and nourishes all beings.',
  'हम तीन नेत्रों वाले सुगन्धित और सम्पूर्ण जगत् के पालनकर्ता भगवान शिव की आराधना करते हैं।',
  108
)
ON CONFLICT (post_id) DO NOTHING;

-- 5. SEED APP SETTINGS & FEATURE FLAGS
INSERT INTO public.app_settings (setting_key, setting_value, description) VALUES
('comments_enabled', 'true'::jsonb, 'Global toggle to enable or disable post comment section'),
('sharing_enabled', 'true'::jsonb, 'Global toggle for social share links'),
('maintenance_mode', 'false'::jsonb, 'Puts mobile application into maintenance mode'),
('min_app_version', '"1.0.0"'::jsonb, 'Minimum supported mobile app version')
ON CONFLICT (setting_key) DO NOTHING;

INSERT INTO public.feature_flags (flag_key, enabled, description) VALUES
('ringtones_enabled', true, 'Enable devotional ringtones feature'),
('horoscope_enabled', true, 'Enable daily rashifal & panchang feature'),
('music_enabled', true, 'Enable audio player & music library'),
('wallpapers_enabled', true, 'Enable HD 4K wallpapers section')
ON CONFLICT (flag_key) DO NOTHING;
