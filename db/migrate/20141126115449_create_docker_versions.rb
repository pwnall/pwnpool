class CreateDockerVersions < ActiveRecord::Migration
  def change
    create_table :docker_versions do |t|
      t.references :host, null: false, index: { unique: true }
      t.string :os, null: false, limit: 32
      t.string :arch, null: false, limit: 32
      t.string :docker, null: false, limit: 32
      t.string :api, null: false, limit: 32
      t.string :kernel, null: false, limit: 256
      t.string :os_label, null: false, limit: 256
      t.boolean :can_limit_memory, null: false
      t.boolean :can_limit_swap, null: false
      t.boolean :can_forward_ipv4, null: false
      t.boolean :debug_mode, null: false

      t.datetime :read_at, null: false
    end
  end
end
