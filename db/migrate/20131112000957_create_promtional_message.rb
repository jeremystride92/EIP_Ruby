class CreatePromtionalMessage < ActiveRecord::Migration
  def change
    create_table :promotional_messages do |t|
      t.text :messages
      t.datetime :send_date_time

      t.timestamps
    end
  end
end
