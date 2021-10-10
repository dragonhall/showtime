# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_10_10_124017) do

  create_table "admins", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", collation: "utf8_general_ci"
    t.string "email", default: "", null: false, collation: "utf8_general_ci"
    t.string "encrypted_password", default: "", null: false, collation: "utf8_general_ci"
    t.integer "group_id"
    t.string "reset_password_token", collation: "utf8_general_ci"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip", collation: "utf8_general_ci"
    t.string "last_sign_in_ip", collation: "utf8_general_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "blocked_ips", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "address", collation: "utf8_general_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_blocked_ips_on_address", unique: true
  end

  create_table "channels", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", collation: "utf8_general_ci"
    t.string "icon", collation: "utf8_general_ci"
    t.string "logo", collation: "utf8_general_ci"
    t.string "domain", collation: "utf8_general_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stream_path", collation: "utf8_general_ci"
    t.integer "trailer_before_id"
    t.integer "trailer_after_id"
    t.boolean "multi"
  end

  create_table "channels_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "channel_id"
    t.integer "group_id"
  end

  create_table "groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", collation: "utf8_general_ci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "playlists", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "channel_id"
    t.string "title", null: false, collation: "utf8_general_ci"
    t.datetime "start_time", null: false
    t.integer "duration", default: 0
    t.boolean "finalized", default: false
    t.boolean "published", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "intro_id"
    t.index ["start_time"], name: "index_playlists_on_start_time", unique: true
  end

  create_table "recordings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "path"
    t.integer "video_id", null: false
    t.datetime "valid_from", null: false
    t.datetime "expires_at"
    t.integer "channel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["path"], name: "index_recordings_on_path", unique: true
    t.index ["valid_from"], name: "index_recordings_on_valid_from"
  end

  create_table "tracks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "playlist_id", null: false
    t.integer "video_id", null: false
    t.string "title", null: false, collation: "utf8_general_ci"
    t.integer "position", null: false
    t.boolean "playing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "videos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "path", collation: "utf8_general_ci"
    t.text "metadata", collation: "utf8_general_ci"
    t.integer "video_type", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pegi_rating"
    t.boolean "recordable"
    t.string "screenshot_path"
    t.string "series"
    t.boolean "logo", default: true
    t.index ["path"], name: "index_videos_on_path", unique: true
    t.index ["series"], name: "index_videos_on_series"
  end

end
