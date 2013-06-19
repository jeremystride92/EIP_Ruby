class CreateBenefits < ActiveRecord::Migration
  def change
    create_table :benefits do |t|
      t.string :description
      t.datetime :start_date
      t.datetime :end_date
      t.references :beneficiary, polymorphic: true

      t.timestamps
    end
  end
end
