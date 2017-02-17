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

ActiveRecord::Schema.define(version: 20160822170256) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "coords", force: :cascade do |t|
    t.string "nome"
    t.string "email"
  end

  create_table "eventos", force: :cascade do |t|
    t.string   "nome"
    t.text     "descricao"
    t.datetime "data_ini"
    t.datetime "data_fim"
    t.integer  "usuario_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "eventos", ["usuario_id"], name: "index_eventos_on_usuario_id", using: :btree

  create_table "eventos_lugars", id: false, force: :cascade do |t|
    t.integer "lugar_id"
    t.integer "evento_id"
  end

  add_index "eventos_lugars", ["evento_id"], name: "index_eventos_lugars_on_evento_id", using: :btree
  add_index "eventos_lugars", ["lugar_id"], name: "index_eventos_lugars_on_lugar_id", using: :btree

  create_table "eventos_servicos", id: false, force: :cascade do |t|
    t.integer "servico_id"
    t.integer "evento_id"
  end

  add_index "eventos_servicos", ["evento_id"], name: "index_eventos_servicos_on_evento_id", using: :btree
  add_index "eventos_servicos", ["servico_id"], name: "index_eventos_servicos_on_servico_id", using: :btree

  create_table "lugars", force: :cascade do |t|
    t.string  "nome"
    t.integer "quantidade"
  end

  create_table "servicos", force: :cascade do |t|
    t.integer "tempo"
    t.string  "nome"
    t.integer "coord_id"
  end

  add_index "servicos", ["coord_id"], name: "index_servicos_on_coord_id", using: :btree

  create_table "usuarios", force: :cascade do |t|
    t.string   "nome"
    t.string   "email"
    t.string   "matricula"
    t.boolean  "admin",      default: false
    t.boolean  "tcoord",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
