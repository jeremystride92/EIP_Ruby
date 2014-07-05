class CreateTextusCredentials < ActiveRecord::Migration
  def up
    create_table :textus_credentials do |t|
      t.references :venue
      t.string :username
      t.string :api_key

      t.timestamps
    end
  end

  def down
    drop_table :textus_credentials
  end
end
