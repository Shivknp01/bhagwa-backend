export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type ContentType =
  | "wallpaper"
  | "video"
  | "music"
  | "bhajan"
  | "ringtone"
  | "mantra"
  | "stuti"
  | "status"
  | "horoscope";

export type PostStatus = "draft" | "published" | "scheduled" | "archived";
export type UserStatus = "active" | "inactive" | "banned";
export type PaymentStatus = "success" | "pending" | "refunded" | "failed";
export type PaymentPlatform = "google_play" | "apple" | "web_upi";
export type AdminRole = "super_admin" | "content_admin" | "moderator" | "analyst";

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          auth_user_id: string | null;
          display_name: string;
          phone_number: string | null;
          email: string | null;
          avatar_url: string | null;
          language: string;
          is_premium: boolean;
          status: UserStatus;
          last_active_at: string;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database["public"]["Tables"]["profiles"]["Row"], "id" | "created_at" | "updated_at">;
        Update: Partial<Database["public"]["Tables"]["profiles"]["Insert"]>;
      };
      user_preferences: {
        Row: {
          id: string;
          user_id: string;
          app_language: string;
          preferred_deities: string[];
          preferred_content_types: string[];
          notifications_enabled: boolean;
          morning_notifications_enabled: boolean;
          night_notifications_enabled: boolean;
          comment_notifications_enabled: boolean;
          marketing_notifications_enabled: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database["public"]["Tables"]["user_preferences"]["Row"], "id" | "created_at" | "updated_at">;
        Update: Partial<Database["public"]["Tables"]["user_preferences"]["Insert"]>;
      };
      deities: {
        Row: {
          id: string;
          name: string;
          slug: string;
          title: string | null;
          symbol: string;
          icon_key: string | null;
          image_url: string | null;
          description: string | null;
          is_active: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database["public"]["Tables"]["deities"]["Row"], "id" | "created_at" | "updated_at">;
        Update: Partial<Database["public"]["Tables"]["deities"]["Insert"]>;
      };
      categories: {
        Row: {
          id: string;
          name: string;
          slug: string;
          emoji: string;
          sub_label: string | null;
          gradient_colors: string[] | null;
          description: string | null;
          is_active: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database["public"]["Tables"]["categories"]["Row"], "id" | "created_at" | "updated_at">;
        Update: Partial<Database["public"]["Tables"]["categories"]["Insert"]>;
      };
      posts: {
        Row: {
          id: string;
          content_type: ContentType;
          title: string;
          title_hi: string | null;
          description: string | null;
          description_hi: string | null;
          deity_id: string | null;
          category_id: string | null;
          language: string;
          tags: string[];
          action_type: string;
          action_label: string;
          action_label_hi: string | null;
          author_name: string;
          thumbnail_url: string | null;
          media_url: string | null;
          audio_url: string | null;
          duration_text: string | null;
          actual_views: number;
          actual_likes: number;
          actual_comments: number;
          actual_shares: number;
          actual_saves: number;
          actual_audio_plays: number;
          actual_wallpaper_sets: number;
          actual_ringtone_sets: number;
          view_override: number | null;
          like_override: number | null;
          comment_override: number | null;
          share_override: number | null;
          save_override: number | null;
          audio_play_override: number | null;
          wallpaper_set_override: number | null;
          ringtone_set_override: number | null;
          views_override_enabled: boolean;
          likes_override_enabled: boolean;
          comments_override_enabled: boolean;
          shares_override_enabled: boolean;
          saves_override_enabled: boolean;
          audio_plays_override_enabled: boolean;
          wallpaper_sets_override_enabled: boolean;
          ringtone_sets_override_enabled: boolean;
          is_featured: boolean;
          is_pinned: boolean;
          is_premium: boolean;
          status: PostStatus;
          feed_priority: number;
          published_at: string | null;
          scheduled_at: string | null;
          created_by: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database["public"]["Tables"]["posts"]["Row"], "id" | "created_at" | "updated_at">;
        Update: Partial<Database["public"]["Tables"]["posts"]["Insert"]>;
      };
      post_media: {
        Row: {
          id: string;
          post_id: string;
          media_type: string;
          r2_key: string;
          media_url: string;
          thumbnail_url: string | null;
          mime_type: string | null;
          file_size: number | null;
          duration_seconds: number | null;
          width: number | null;
          height: number | null;
          source_type: string | null;
          source_url: string | null;
          source_creator: string | null;
          license_type: string | null;
          created_at: string;
        };
        Insert: Omit<Database["public"]["Tables"]["post_media"]["Row"], "id" | "created_at">;
        Update: Partial<Database["public"]["Tables"]["post_media"]["Insert"]>;
      };
      post_likes: {
        Row: {
          id: string;
          post_id: string;
          user_id: string;
          created_at: string;
        };
        Insert: Omit<Database["public"]["Tables"]["post_likes"]["Row"], "id" | "created_at">;
        Update: Partial<Database["public"]["Tables"]["post_likes"]["Insert"]>;
      };
      post_comments: {
        Row: {
          id: string;
          post_id: string;
          user_id: string;
          parent_comment_id: string | null;
          comment_text: string;
          status: string;
          likes_count: number;
          reports_count: number;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database["public"]["Tables"]["post_comments"]["Row"], "id" | "created_at" | "updated_at">;
        Update: Partial<Database["public"]["Tables"]["post_comments"]["Insert"]>;
      };
      post_saves: {
        Row: {
          id: string;
          post_id: string;
          user_id: string;
          created_at: string;
        };
        Insert: Omit<Database["public"]["Tables"]["post_saves"]["Row"], "id" | "created_at">;
        Update: Partial<Database["public"]["Tables"]["post_saves"]["Insert"]>;
      };
      admin_users: {
        Row: {
          id: string;
          auth_user_id: string | null;
          name: string;
          email: string;
          role: AdminRole;
          is_active: boolean;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database["public"]["Tables"]["admin_users"]["Row"], "id" | "created_at" | "updated_at">;
        Update: Partial<Database["public"]["Tables"]["admin_users"]["Insert"]>;
      };
      admin_audit_logs: {
        Row: {
          id: string;
          admin_user_id: string;
          entity_type: string;
          entity_id: string;
          action: string;
          old_value: Json | null;
          new_value: Json | null;
          created_at: string;
        };
        Insert: Omit<Database["public"]["Tables"]["admin_audit_logs"]["Row"], "id" | "created_at">;
        Update: Partial<Database["public"]["Tables"]["admin_audit_logs"]["Insert"]>;
      };
    };
  };
}
