# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141127001938) do

  create_table "credentials", force: true do |t|
    t.integer  "user_id",    limit: 4,    null: false
    t.string   "type",       limit: 32,   null: false
    t.string   "name",       limit: 128
    t.datetime "updated_at",              null: false
    t.binary   "key",        limit: 2048
  end

  add_index "credentials", ["type", "name"], name: "index_credentials_on_type_and_name", unique: true, using: :btree
  add_index "credentials", ["type", "updated_at"], name: "index_credentials_on_type_and_updated_at", using: :btree
  add_index "credentials", ["user_id", "type"], name: "index_credentials_on_user_id_and_type", using: :btree

  create_table "docker_hosts", force: true do |t|
    t.integer  "user_id",         limit: 4,     null: false
    t.string   "name",            limit: 128,   null: false
    t.text     "url",             limit: 65535, null: false
    t.text     "ca_cert_pem",     limit: 65535
    t.text     "client_cert_pem", limit: 65535
    t.text     "client_key_pem",  limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "docker_hosts", ["user_id", "name"], name: "index_docker_hosts_on_user_id_and_name", unique: true, using: :btree

  create_table "docker_images", force: true do |t|
    t.integer  "host_id",           limit: 4,  null: false
    t.string   "docker_uid",        limit: 64, null: false
    t.string   "docker_parent_uid", limit: 64
    t.integer  "size",              limit: 8,  null: false
    t.integer  "virtual_size",      limit: 8,  null: false
    t.datetime "created_at",                   null: false
    t.datetime "read_at",                      null: false
  end

  add_index "docker_images", ["host_id", "docker_uid"], name: "index_docker_images_on_host_id_and_docker_uid", unique: true, using: :btree

  create_table "docker_versions", force: true do |t|
    t.integer  "host_id",          limit: 4,   null: false
    t.string   "os",               limit: 32,  null: false
    t.string   "arch",             limit: 32,  null: false
    t.string   "docker",           limit: 32,  null: false
    t.string   "api",              limit: 32,  null: false
    t.string   "kernel",           limit: 256, null: false
    t.string   "os_label",         limit: 256, null: false
    t.boolean  "can_limit_memory", limit: 1,   null: false
    t.boolean  "can_limit_swap",   limit: 1,   null: false
    t.boolean  "can_forward_ipv4", limit: 1,   null: false
    t.boolean  "debug_mode",       limit: 1,   null: false
    t.datetime "read_at",                      null: false
  end

  add_index "docker_versions", ["host_id"], name: "index_docker_versions_on_host_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "exuid",      limit: 32, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.boolean  "admin",      limit: 1,  null: false
  end

  add_index "users", ["exuid"], name: "index_users_on_exuid", unique: true, using: :btree

end
