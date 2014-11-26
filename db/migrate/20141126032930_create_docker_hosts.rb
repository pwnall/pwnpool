class CreateDockerHosts < ActiveRecord::Migration
  def change
    create_table :docker_hosts do |t|
      t.references :user, null: false
      t.string :name, limit: 128, null: false
      t.text :url, limit: 1.kilobyte, null: false
      t.text :ca_cert_pem, limit: 8.kilobytes, null: true
      t.text :client_cert_pem, limit: 8.kilobytes, null: true
      t.text :client_key_pem, limit: 8.kilobytes, null: true

      t.timestamps null: false

      t.index [:user_id, :name], unique: true
    end
  end
end
