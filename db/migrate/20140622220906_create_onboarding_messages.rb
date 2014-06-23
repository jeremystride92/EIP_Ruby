class CreateOnboardingMessages < ActiveRecord::Migration
  def up
    create_table :onboarding_messages do |t|
      t.references :venue
      t.text :custom_text

      t.timestamps
    end
  end

  def down
    drop_table :onboarding_messages
  end
end
