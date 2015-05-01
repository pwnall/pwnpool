class CreateDockerImages < ActiveRecord::Migration
  def change
    create_table :docker_images do |t|
      t.references :host, null: false
      t.string :docker_uid, null: false, limit: 64
      t.string :docker_parent_uid, null: true, limit: 64
      t.integer :size, limit: 8, null: false
      t.integer :virtual_size, limit: 8, null: false
      t.datetime :created_at, null: false
      t.datetime :read_at, null: false

      t.index [:host_id, :docker_uid], unique: true
    end
  end
end
