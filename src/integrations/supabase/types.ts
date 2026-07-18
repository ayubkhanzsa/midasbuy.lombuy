export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      admin_logs: {
        Row: {
          action: string
          admin_id: string
          created_at: string
          details: Json | null
          id: string
          target_id: string | null
          target_type: string | null
        }
        Insert: {
          action: string
          admin_id: string
          created_at?: string
          details?: Json | null
          id?: string
          target_id?: string | null
          target_type?: string | null
        }
        Update: {
          action?: string
          admin_id?: string
          created_at?: string
          details?: Json | null
          id?: string
          target_id?: string | null
          target_type?: string | null
        }
        Relationships: []
      }
      admin_notification_history: {
        Row: {
          body: string
          created_at: string
          event_type: string
          id: string
          order_id: string | null
          package_name: string | null
          player_id: string | null
          price: number | null
          sent_to_count: number | null
          title: string
          total_admins: number | null
        }
        Insert: {
          body: string
          created_at?: string
          event_type: string
          id?: string
          order_id?: string | null
          package_name?: string | null
          player_id?: string | null
          price?: number | null
          sent_to_count?: number | null
          title: string
          total_admins?: number | null
        }
        Update: {
          body?: string
          created_at?: string
          event_type?: string
          id?: string
          order_id?: string | null
          package_name?: string | null
          player_id?: string | null
          price?: number | null
          sent_to_count?: number | null
          title?: string
          total_admins?: number | null
        }
        Relationships: []
      }
      analytics: {
        Row: {
          date: string
          id: string
          ip_address: string
          visit_time: string
        }
        Insert: {
          date?: string
          id?: string
          ip_address: string
          visit_time?: string
        }
        Update: {
          date?: string
          id?: string
          ip_address?: string
          visit_time?: string
        }
        Relationships: []
      }
      auth_attempts: {
        Row: {
          attempts: number
          email: string
          id: string
          locked_until: string | null
          updated_at: string
        }
        Insert: {
          attempts?: number
          email: string
          id?: string
          locked_until?: string | null
          updated_at?: string
        }
        Update: {
          attempts?: number
          email?: string
          id?: string
          locked_until?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      blogs: {
        Row: {
          author: string | null
          content: string
          created_at: string
          excerpt: string | null
          featured_image_url: string | null
          id: string
          meta_description: string | null
          meta_title: string | null
          published: boolean | null
          slug: string
          tags: string[] | null
          title: string
          updated_at: string
        }
        Insert: {
          author?: string | null
          content: string
          created_at?: string
          excerpt?: string | null
          featured_image_url?: string | null
          id?: string
          meta_description?: string | null
          meta_title?: string | null
          published?: boolean | null
          slug: string
          tags?: string[] | null
          title: string
          updated_at?: string
        }
        Update: {
          author?: string | null
          content?: string
          created_at?: string
          excerpt?: string | null
          featured_image_url?: string | null
          id?: string
          meta_description?: string | null
          meta_title?: string | null
          published?: boolean | null
          slug?: string
          tags?: string[] | null
          title?: string
          updated_at?: string
        }
        Relationships: []
      }
      chat_history: {
        Row: {
          content: string | null
          created_at: string
          id: string
          messages: Json | null
          metadata: Json | null
          role: string | null
          session_id: string | null
          updated_at: string | null
          user_id: string | null
        }
        Insert: {
          content?: string | null
          created_at?: string
          id?: string
          messages?: Json | null
          metadata?: Json | null
          role?: string | null
          session_id?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Update: {
          content?: string | null
          created_at?: string
          id?: string
          messages?: Json | null
          metadata?: Json | null
          role?: string | null
          session_id?: string | null
          updated_at?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      content_blocks: {
        Row: {
          content: string | null
          content_key: string
          created_at: string
          id: string
          title: string | null
          updated_at: string
        }
        Insert: {
          content?: string | null
          content_key: string
          created_at?: string
          id?: string
          title?: string | null
          updated_at?: string
        }
        Update: {
          content?: string | null
          content_key?: string
          created_at?: string
          id?: string
          title?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      customer_inquiries: {
        Row: {
          admin_notes: string | null
          created_at: string
          email: string
          id: string
          is_read: boolean
          message: string
          name: string
          phone: string | null
          status: string
          subject: string | null
          updated_at: string
          user_id: string | null
        }
        Insert: {
          admin_notes?: string | null
          created_at?: string
          email: string
          id?: string
          is_read?: boolean
          message: string
          name: string
          phone?: string | null
          status?: string
          subject?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          admin_notes?: string | null
          created_at?: string
          email?: string
          id?: string
          is_read?: boolean
          message?: string
          name?: string
          phone?: string | null
          status?: string
          subject?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Relationships: []
      }
      customer_inquiries_archive: {
        Row: {
          admin_notes: string | null
          archived_at: string | null
          archived_by: string | null
          created_at: string
          email: string
          id: string
          is_read: boolean | null
          message: string
          name: string
          original_created_at: string | null
          original_id: string | null
          original_updated_at: string | null
          phone: string | null
          status: string
          subject: string | null
          updated_at: string
          user_id: string | null
        }
        Insert: {
          admin_notes?: string | null
          archived_at?: string | null
          archived_by?: string | null
          created_at?: string
          email: string
          id?: string
          is_read?: boolean | null
          message: string
          name: string
          original_created_at?: string | null
          original_id?: string | null
          original_updated_at?: string | null
          phone?: string | null
          status?: string
          subject?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          admin_notes?: string | null
          archived_at?: string | null
          archived_by?: string | null
          created_at?: string
          email?: string
          id?: string
          is_read?: boolean | null
          message?: string
          name?: string
          original_created_at?: string | null
          original_id?: string | null
          original_updated_at?: string | null
          phone?: string | null
          status?: string
          subject?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Relationships: []
      }
      game_profiles: {
        Row: {
          created_at: string
          game: string
          id: string
          player_id: string
          region: string | null
          server: string | null
          updated_at: string
          user_id: string
          username: string | null
        }
        Insert: {
          created_at?: string
          game: string
          id?: string
          player_id: string
          region?: string | null
          server?: string | null
          updated_at?: string
          user_id: string
          username?: string | null
        }
        Update: {
          created_at?: string
          game?: string
          id?: string
          player_id?: string
          region?: string | null
          server?: string | null
          updated_at?: string
          user_id?: string
          username?: string | null
        }
        Relationships: []
      }
      inquiry_email_log: {
        Row: {
          body: string | null
          created_at: string
          customer_email: string | null
          email_to: string | null
          error_message: string | null
          id: string
          inquiry_id: string | null
          sent_by: string | null
          status: string | null
          subject: string | null
          template_type: string | null
        }
        Insert: {
          body?: string | null
          created_at?: string
          customer_email?: string | null
          email_to?: string | null
          error_message?: string | null
          id?: string
          inquiry_id?: string | null
          sent_by?: string | null
          status?: string | null
          subject?: string | null
          template_type?: string | null
        }
        Update: {
          body?: string | null
          created_at?: string
          customer_email?: string | null
          email_to?: string | null
          error_message?: string | null
          id?: string
          inquiry_id?: string | null
          sent_by?: string | null
          status?: string | null
          subject?: string | null
          template_type?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "inquiry_email_log_inquiry_id_fkey"
            columns: ["inquiry_id"]
            isOneToOne: false
            referencedRelation: "customer_inquiries"
            referencedColumns: ["id"]
          },
        ]
      }
      live_users: {
        Row: {
          created_at: string
          id: string
          last_seen: string
          path: string
          session_id: string
          user_agent: string | null
          user_id: string | null
        }
        Insert: {
          created_at?: string
          id?: string
          last_seen?: string
          path: string
          session_id: string
          user_agent?: string | null
          user_id?: string | null
        }
        Update: {
          created_at?: string
          id?: string
          last_seen?: string
          path?: string
          session_id?: string
          user_agent?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      notifications: {
        Row: {
          action_url: string | null
          created_at: string
          icon_url: string | null
          id: string
          message: string
          sent_at: string
          sent_by: string | null
          title: string
          type: string
        }
        Insert: {
          action_url?: string | null
          created_at?: string
          icon_url?: string | null
          id?: string
          message: string
          sent_at?: string
          sent_by?: string | null
          title: string
          type?: string
        }
        Update: {
          action_url?: string | null
          created_at?: string
          icon_url?: string | null
          id?: string
          message?: string
          sent_at?: string
          sent_by?: string | null
          title?: string
          type?: string
        }
        Relationships: []
      }
      orders: {
        Row: {
          amount: number
          created_at: string
          currency_code: string | null
          email_sent_at: string | null
          exchange_rate: number | null
          id: string
          package_id: string | null
          payment_method: string | null
          pkr_amount: number | null
          player_id: string | null
          price: number
          product_amount: string | null
          product_code: string | null
          product_name: string | null
          product_type: string | null
          server_name: string | null
          status: string
          transaction_id: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          amount: number
          created_at?: string
          currency_code?: string | null
          email_sent_at?: string | null
          exchange_rate?: number | null
          id?: string
          package_id?: string | null
          payment_method?: string | null
          pkr_amount?: number | null
          player_id?: string | null
          price: number
          product_amount?: string | null
          product_code?: string | null
          product_name?: string | null
          product_type?: string | null
          server_name?: string | null
          status?: string
          transaction_id?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          amount?: number
          created_at?: string
          currency_code?: string | null
          email_sent_at?: string | null
          exchange_rate?: number | null
          id?: string
          package_id?: string | null
          payment_method?: string | null
          pkr_amount?: number | null
          player_id?: string | null
          price?: number
          product_amount?: string | null
          product_code?: string | null
          product_name?: string | null
          product_type?: string | null
          server_name?: string | null
          status?: string
          transaction_id?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "orders_package_id_fkey"
            columns: ["package_id"]
            isOneToOne: false
            referencedRelation: "uc_packages"
            referencedColumns: ["id"]
          },
        ]
      }
      orders_archive: {
        Row: {
          amount: number
          archived_at: string | null
          archived_by: string | null
          archived_reason: string | null
          created_at: string
          currency_code: string | null
          email_sent_at: string | null
          id: string
          original_created_at: string | null
          original_id: string | null
          original_updated_at: string | null
          package_id: string | null
          payment_method: string | null
          player_id: string | null
          price: number
          product_amount: string | null
          product_name: string | null
          product_type: string | null
          server_name: string | null
          status: string
          transaction_id: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          amount: number
          archived_at?: string | null
          archived_by?: string | null
          archived_reason?: string | null
          created_at?: string
          currency_code?: string | null
          email_sent_at?: string | null
          id?: string
          original_created_at?: string | null
          original_id?: string | null
          original_updated_at?: string | null
          package_id?: string | null
          payment_method?: string | null
          player_id?: string | null
          price: number
          product_amount?: string | null
          product_name?: string | null
          product_type?: string | null
          server_name?: string | null
          status?: string
          transaction_id?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          amount?: number
          archived_at?: string | null
          archived_by?: string | null
          archived_reason?: string | null
          created_at?: string
          currency_code?: string | null
          email_sent_at?: string | null
          id?: string
          original_created_at?: string | null
          original_id?: string | null
          original_updated_at?: string | null
          package_id?: string | null
          payment_method?: string | null
          player_id?: string | null
          price?: number
          product_amount?: string | null
          product_name?: string | null
          product_type?: string | null
          server_name?: string | null
          status?: string
          transaction_id?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: []
      }
      page_meta: {
        Row: {
          canonical_url: string | null
          created_at: string | null
          id: string
          meta_description: string | null
          meta_keywords: string | null
          meta_title: string | null
          og_image_url: string | null
          page_id: string
          path: string | null
          title: string | null
          updated_at: string | null
        }
        Insert: {
          canonical_url?: string | null
          created_at?: string | null
          id?: string
          meta_description?: string | null
          meta_keywords?: string | null
          meta_title?: string | null
          og_image_url?: string | null
          page_id: string
          path?: string | null
          title?: string | null
          updated_at?: string | null
        }
        Update: {
          canonical_url?: string | null
          created_at?: string | null
          id?: string
          meta_description?: string | null
          meta_keywords?: string | null
          meta_title?: string | null
          og_image_url?: string | null
          page_id?: string
          path?: string | null
          title?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
      page_views: {
        Row: {
          country_name: string | null
          created_at: string
          device_type: string | null
          id: string
          ip_address: string | null
          path: string
          referrer: string | null
          session_id: string | null
          user_agent: string | null
          user_id: string | null
        }
        Insert: {
          country_name?: string | null
          created_at?: string
          device_type?: string | null
          id?: string
          ip_address?: string | null
          path: string
          referrer?: string | null
          session_id?: string | null
          user_agent?: string | null
          user_id?: string | null
        }
        Update: {
          country_name?: string | null
          created_at?: string
          device_type?: string | null
          id?: string
          ip_address?: string | null
          path?: string
          referrer?: string | null
          session_id?: string | null
          user_agent?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      payment_credentials: {
        Row: {
          created_at: string
          id: string
          method: string
          name: string
          updated_at: string
          value: string
        }
        Insert: {
          created_at?: string
          id?: string
          method: string
          name: string
          updated_at?: string
          value: string
        }
        Update: {
          created_at?: string
          id?: string
          method?: string
          name?: string
          updated_at?: string
          value?: string
        }
        Relationships: []
      }
      payment_gateways: {
        Row: {
          code: string
          created_at: string
          id: string
          is_enabled: boolean
          logo_url: string | null
          name: string
          sort_order: number
          updated_at: string
        }
        Insert: {
          code: string
          created_at?: string
          id?: string
          is_enabled?: boolean
          logo_url?: string | null
          name: string
          sort_order?: number
          updated_at?: string
        }
        Update: {
          code?: string
          created_at?: string
          id?: string
          is_enabled?: boolean
          logo_url?: string | null
          name?: string
          sort_order?: number
          updated_at?: string
        }
        Relationships: []
      }
      payment_logs: {
        Row: {
          created_at: string
          gateway: string | null
          id: string
          order_id: string | null
          payload: Json | null
          status: string | null
          transaction_id: string | null
        }
        Insert: {
          created_at?: string
          gateway?: string | null
          id?: string
          order_id?: string | null
          payload?: Json | null
          status?: string | null
          transaction_id?: string | null
        }
        Update: {
          created_at?: string
          gateway?: string | null
          id?: string
          order_id?: string | null
          payload?: Json | null
          status?: string | null
          transaction_id?: string | null
        }
        Relationships: []
      }
      profiles: {
        Row: {
          auth_attempts: number | null
          avatar_imported: boolean | null
          avatar_url: string | null
          blocked_at: string | null
          created_at: string
          email: string | null
          email_verified: boolean | null
          facebook_id: string | null
          full_name: string | null
          id: string
          last_sign_in: string | null
          locked_until: string | null
          phone: string | null
          provider: string | null
          role: string | null
          status: string | null
          total_orders: number | null
          total_spent: number | null
          updated_at: string
          user_id: string | null
        }
        Insert: {
          auth_attempts?: number | null
          avatar_imported?: boolean | null
          avatar_url?: string | null
          blocked_at?: string | null
          created_at?: string
          email?: string | null
          email_verified?: boolean | null
          facebook_id?: string | null
          full_name?: string | null
          id?: string
          last_sign_in?: string | null
          locked_until?: string | null
          phone?: string | null
          provider?: string | null
          role?: string | null
          status?: string | null
          total_orders?: number | null
          total_spent?: number | null
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          auth_attempts?: number | null
          avatar_imported?: boolean | null
          avatar_url?: string | null
          blocked_at?: string | null
          created_at?: string
          email?: string | null
          email_verified?: boolean | null
          facebook_id?: string | null
          full_name?: string | null
          id?: string
          last_sign_in?: string | null
          locked_until?: string | null
          phone?: string | null
          provider?: string | null
          role?: string | null
          status?: string | null
          total_orders?: number | null
          total_spent?: number | null
          updated_at?: string
          user_id?: string | null
        }
        Relationships: []
      }
      pubg_account_credentials: {
        Row: {
          account_id: string
          created_at: string
          id: string
          login_email: string | null
          login_password: string | null
          recovery_info: string | null
          updated_at: string
        }
        Insert: {
          account_id: string
          created_at?: string
          id?: string
          login_email?: string | null
          login_password?: string | null
          recovery_info?: string | null
          updated_at?: string
        }
        Update: {
          account_id?: string
          created_at?: string
          id?: string
          login_email?: string | null
          login_password?: string | null
          recovery_info?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "pubg_account_credentials_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: true
            referencedRelation: "pubg_accounts"
            referencedColumns: ["id"]
          },
        ]
      }
      pubg_account_orders: {
        Row: {
          account_id: string | null
          amount: number
          buyer_email: string | null
          created_at: string
          id: string
          payment_method: string | null
          status: string
          transaction_id: string | null
          updated_at: string
          user_id: string | null
        }
        Insert: {
          account_id?: string | null
          amount: number
          buyer_email?: string | null
          created_at?: string
          id?: string
          payment_method?: string | null
          status?: string
          transaction_id?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          account_id?: string | null
          amount?: number
          buyer_email?: string | null
          created_at?: string
          id?: string
          payment_method?: string | null
          status?: string
          transaction_id?: string | null
          updated_at?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "pubg_account_orders_account_id_fkey"
            columns: ["account_id"]
            isOneToOne: false
            referencedRelation: "pubg_accounts"
            referencedColumns: ["id"]
          },
        ]
      }
      pubg_accounts: {
        Row: {
          created_at: string
          description: string | null
          discount: number | null
          id: string
          login_email: string | null
          login_password: string | null
          price: number
          recovery_info: string | null
          status: string
          thumbnail_url: string | null
          title: string
          updated_at: string
          video_duration: number | null
          video_url: string | null
        }
        Insert: {
          created_at?: string
          description?: string | null
          discount?: number | null
          id?: string
          login_email?: string | null
          login_password?: string | null
          price: number
          recovery_info?: string | null
          status?: string
          thumbnail_url?: string | null
          title: string
          updated_at?: string
          video_duration?: number | null
          video_url?: string | null
        }
        Update: {
          created_at?: string
          description?: string | null
          discount?: number | null
          id?: string
          login_email?: string | null
          login_password?: string | null
          price?: number
          recovery_info?: string | null
          status?: string
          thumbnail_url?: string | null
          title?: string
          updated_at?: string
          video_duration?: number | null
          video_url?: string | null
        }
        Relationships: []
      }
      pubg_uc_page_content: {
        Row: {
          active: boolean
          content: string | null
          content_key: string
          created_at: string
          id: string
          image_url: string | null
          order_position: number
          title: string | null
          updated_at: string
        }
        Insert: {
          active?: boolean
          content?: string | null
          content_key: string
          created_at?: string
          id?: string
          image_url?: string | null
          order_position?: number
          title?: string | null
          updated_at?: string
        }
        Update: {
          active?: boolean
          content?: string | null
          content_key?: string
          created_at?: string
          id?: string
          image_url?: string | null
          order_position?: number
          title?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      push_subscriptions: {
        Row: {
          auth: string | null
          created_at: string
          endpoint: string
          id: string
          p256dh: string | null
          updated_at: string
          user_agent: string | null
          user_id: string | null
        }
        Insert: {
          auth?: string | null
          created_at?: string
          endpoint: string
          id?: string
          p256dh?: string | null
          updated_at?: string
          user_agent?: string | null
          user_id?: string | null
        }
        Update: {
          auth?: string | null
          created_at?: string
          endpoint?: string
          id?: string
          p256dh?: string | null
          updated_at?: string
          user_agent?: string | null
          user_id?: string | null
        }
        Relationships: []
      }
      redeem_codes: {
        Row: {
          admin_notes: string | null
          created_at: string
          expire_at: string | null
          id: string
          notes: string | null
          order_id: string | null
          package_name: string | null
          player_id: string | null
          redeem_code: string
          reviewed_at: string | null
          reviewed_by: string | null
          status: string | null
          uc_amount: number | null
          updated_at: string
          used: boolean
          used_at: string | null
          used_by: string | null
          username: string | null
        }
        Insert: {
          admin_notes?: string | null
          created_at?: string
          expire_at?: string | null
          id?: string
          notes?: string | null
          order_id?: string | null
          package_name?: string | null
          player_id?: string | null
          redeem_code: string
          reviewed_at?: string | null
          reviewed_by?: string | null
          status?: string | null
          uc_amount?: number | null
          updated_at?: string
          used?: boolean
          used_at?: string | null
          used_by?: string | null
          username?: string | null
        }
        Update: {
          admin_notes?: string | null
          created_at?: string
          expire_at?: string | null
          id?: string
          notes?: string | null
          order_id?: string | null
          package_name?: string | null
          player_id?: string | null
          redeem_code?: string
          reviewed_at?: string | null
          reviewed_by?: string | null
          status?: string | null
          uc_amount?: number | null
          updated_at?: string
          used?: boolean
          used_at?: string | null
          used_by?: string | null
          username?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "redeem_codes_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
        ]
      }
      redeem_codes_archive: {
        Row: {
          admin_notes: string | null
          created_at: string
          expire_at: string | null
          id: string
          notes: string | null
          order_id: string | null
          package_name: string | null
          player_id: string | null
          redeem_code: string
          reviewed_at: string | null
          reviewed_by: string | null
          status: string | null
          uc_amount: number | null
          updated_at: string
          used: boolean
          used_at: string | null
          used_by: string | null
          username: string | null
        }
        Insert: {
          admin_notes?: string | null
          created_at?: string
          expire_at?: string | null
          id?: string
          notes?: string | null
          order_id?: string | null
          package_name?: string | null
          player_id?: string | null
          redeem_code: string
          reviewed_at?: string | null
          reviewed_by?: string | null
          status?: string | null
          uc_amount?: number | null
          updated_at?: string
          used?: boolean
          used_at?: string | null
          used_by?: string | null
          username?: string | null
        }
        Update: {
          admin_notes?: string | null
          created_at?: string
          expire_at?: string | null
          id?: string
          notes?: string | null
          order_id?: string | null
          package_name?: string | null
          player_id?: string | null
          redeem_code?: string
          reviewed_at?: string | null
          reviewed_by?: string | null
          status?: string | null
          uc_amount?: number | null
          updated_at?: string
          used?: boolean
          used_at?: string | null
          used_by?: string | null
          username?: string | null
        }
        Relationships: []
      }
      saved_cards: {
        Row: {
          card_holder_name: string | null
          card_type: string | null
          created_at: string
          expiry_month: number | null
          expiry_year: number | null
          id: string
          is_default: boolean | null
          last_four: string
          user_id: string
        }
        Insert: {
          card_holder_name?: string | null
          card_type?: string | null
          created_at?: string
          expiry_month?: number | null
          expiry_year?: number | null
          id?: string
          is_default?: boolean | null
          last_four: string
          user_id: string
        }
        Update: {
          card_holder_name?: string | null
          card_type?: string | null
          created_at?: string
          expiry_month?: number | null
          expiry_year?: number | null
          id?: string
          is_default?: boolean | null
          last_four?: string
          user_id?: string
        }
        Relationships: []
      }
      site_assets: {
        Row: {
          asset_key: string
          created_at: string
          id: string
          updated_at: string
          updated_by: string | null
          url: string
        }
        Insert: {
          asset_key: string
          created_at?: string
          id?: string
          updated_at?: string
          updated_by?: string | null
          url: string
        }
        Update: {
          asset_key?: string
          created_at?: string
          id?: string
          updated_at?: string
          updated_by?: string | null
          url?: string
        }
        Relationships: []
      }
      site_banners: {
        Row: {
          banner_key: string
          created_at: string
          description: string | null
          device_type: string
          display_order: number | null
          id: string
          image_url: string
          is_active: boolean
          light_color: string | null
          light_effect: boolean | null
          light_enabled: boolean | null
          light_intensity: number | null
          light_spread: number | null
          page_name: string
          position_x: number | null
          position_y: number | null
          title: string
          updated_at: string
          zoom_level: number | null
        }
        Insert: {
          banner_key: string
          created_at?: string
          description?: string | null
          device_type?: string
          display_order?: number | null
          id?: string
          image_url: string
          is_active?: boolean
          light_color?: string | null
          light_effect?: boolean | null
          light_enabled?: boolean | null
          light_intensity?: number | null
          light_spread?: number | null
          page_name: string
          position_x?: number | null
          position_y?: number | null
          title: string
          updated_at?: string
          zoom_level?: number | null
        }
        Update: {
          banner_key?: string
          created_at?: string
          description?: string | null
          device_type?: string
          display_order?: number | null
          id?: string
          image_url?: string
          is_active?: boolean
          light_color?: string | null
          light_effect?: boolean | null
          light_enabled?: boolean | null
          light_intensity?: number | null
          light_spread?: number | null
          page_name?: string
          position_x?: number | null
          position_y?: number | null
          title?: string
          updated_at?: string
          zoom_level?: number | null
        }
        Relationships: []
      }
      uc_packages: {
        Row: {
          active: boolean
          amount: number | null
          created_at: string
          id: string
          name: string
          price: number
          uc_amount: number | null
          updated_at: string
        }
        Insert: {
          active?: boolean
          amount?: number | null
          created_at?: string
          id?: string
          name: string
          price: number
          uc_amount?: number | null
          updated_at?: string
        }
        Update: {
          active?: boolean
          amount?: number | null
          created_at?: string
          id?: string
          name?: string
          price?: number
          uc_amount?: number | null
          updated_at?: string
        }
        Relationships: []
      }
      user_notifications: {
        Row: {
          created_at: string
          delivered: boolean
          delivered_at: string | null
          id: string
          notification_id: string
          read: boolean
          read_at: string | null
          user_id: string
        }
        Insert: {
          created_at?: string
          delivered?: boolean
          delivered_at?: string | null
          id?: string
          notification_id: string
          read?: boolean
          read_at?: string | null
          user_id: string
        }
        Update: {
          created_at?: string
          delivered?: boolean
          delivered_at?: string | null
          id?: string
          notification_id?: string
          read?: boolean
          read_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_notifications_notification_id_fkey"
            columns: ["notification_id"]
            isOneToOne: false
            referencedRelation: "notifications"
            referencedColumns: ["id"]
          },
        ]
      }
      user_roles: {
        Row: {
          created_at: string
          id: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id?: string
        }
        Relationships: []
      }
      whatsapp_conversations: {
        Row: {
          contact_name: string | null
          created_at: string
          id: string
          is_active: boolean | null
          last_message_at: string | null
          phone_number: string
          profile_pic_url: string | null
          updated_at: string
        }
        Insert: {
          contact_name?: string | null
          created_at?: string
          id?: string
          is_active?: boolean | null
          last_message_at?: string | null
          phone_number: string
          profile_pic_url?: string | null
          updated_at?: string
        }
        Update: {
          contact_name?: string | null
          created_at?: string
          id?: string
          is_active?: boolean | null
          last_message_at?: string | null
          phone_number?: string
          profile_pic_url?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      whatsapp_messages: {
        Row: {
          conversation_id: string
          created_at: string
          id: string
          is_outgoing: boolean
          media_url: string | null
          message_id: string | null
          message_text: string | null
          message_type: string | null
          phone_number: string
          status: string | null
          timestamp: string
        }
        Insert: {
          conversation_id: string
          created_at?: string
          id?: string
          is_outgoing?: boolean
          media_url?: string | null
          message_id?: string | null
          message_text?: string | null
          message_type?: string | null
          phone_number: string
          status?: string | null
          timestamp?: string
        }
        Update: {
          conversation_id?: string
          created_at?: string
          id?: string
          is_outgoing?: boolean
          media_url?: string | null
          message_id?: string | null
          message_text?: string | null
          message_type?: string | null
          phone_number?: string
          status?: string | null
          timestamp?: string
        }
        Relationships: [
          {
            foreignKeyName: "whatsapp_messages_conversation_id_fkey"
            columns: ["conversation_id"]
            isOneToOne: false
            referencedRelation: "whatsapp_conversations"
            referencedColumns: ["id"]
          },
        ]
      }
      whatsapp_settings: {
        Row: {
          created_at: string
          id: string
          is_active: boolean
          phone_number: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          id?: string
          is_active?: boolean
          phone_number: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          id?: string
          is_active?: boolean
          phone_number?: string
          updated_at?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      assign_default_role: { Args: { p_user_id: string }; Returns: undefined }
      check_auth_rate_limit: { Args: { p_email: string }; Returns: boolean }
      cleanup_live_users: { Args: never; Returns: undefined }
      get_page_views_analytics: {
        Args: { days_back?: number }
        Returns: {
          top_pages: Json
          total_views: number
          unique_visitors: number
        }[]
      }
      get_purchased_account_credentials: {
        Args: { p_account_id: string }
        Returns: {
          login_email: string
          login_password: string
          recovery_info: string
        }[]
      }
      grant_role_by_email: {
        Args: {
          target_role: Database["public"]["Enums"]["app_role"]
          user_email: string
        }
        Returns: boolean
      }
      has_role: {
        Args: {
          _role: Database["public"]["Enums"]["app_role"]
          _user_id: string
        }
        Returns: boolean
      }
      increment_auth_attempts: { Args: { p_email: string }; Returns: undefined }
      list_admins: {
        Args: never
        Returns: {
          email: string
          since: string
          user_id: string
        }[]
      }
      list_users_with_admin: {
        Args: never
        Returns: {
          email: string
          is_admin: boolean
          user_id: string
        }[]
      }
      list_users_with_admin_status: {
        Args: never
        Returns: {
          email: string
          is_admin: boolean
          user_id: string
        }[]
      }
      log_admin_action:
        | {
            Args: {
              p_action: string
              p_details?: Json
              p_target_id?: string
              p_target_type?: string
            }
            Returns: undefined
          }
        | {
            Args: {
              p_action_type: string
              p_admin_id: string
              p_details?: Json
              p_target_id?: string
              p_target_type?: string
            }
            Returns: undefined
          }
      reset_auth_attempts: { Args: { p_user_id: string }; Returns: undefined }
      revoke_role_by_email: {
        Args: {
          target_role: Database["public"]["Enums"]["app_role"]
          user_email: string
        }
        Returns: boolean
      }
      submit_redeem_code: {
        Args: {
          p_package_name?: string
          p_player_id?: string
          p_redeem_code: string
          p_uc_amount?: number
          p_username?: string
        }
        Returns: Json
      }
    }
    Enums: {
      app_role: "admin" | "user"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      app_role: ["admin", "user"],
    },
  },
} as const
