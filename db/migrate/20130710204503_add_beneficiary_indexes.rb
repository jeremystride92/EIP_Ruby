class AddBeneficiaryIndexes < ActiveRecord::Migration
  def change
    add_index :benefits, [:beneficiary_type, :beneficiary_id]
    add_index :benefits, :beneficiary_type
  end
end
