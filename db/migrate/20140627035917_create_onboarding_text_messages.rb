class CreateOnboardingTextMessages < ActiveRecord::Migration
  def up
    create_table :onboarding_text_messages do |t|
      t.references :venue
      t.text :custom_text

      t.timestamps
    end
  end

  def down
    drop_table :onboarding_text_messages
  end
end
