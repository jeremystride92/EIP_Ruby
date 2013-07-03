class AddOnboardingTokenToCardholder < ActiveRecord::Migration
  def change
    add_column :cardholders, :onboarding_token, :string
  end
end
