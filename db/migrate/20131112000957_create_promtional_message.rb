class CreatePromtionalMessage < ActiveRecord::Migration
  def change
    create_table :promotional_messages do |t|
      t.text :promotional_messages
      t.time :send_date_time

      t.timestamps
    end
  end
end
