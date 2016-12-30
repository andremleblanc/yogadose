class CreatePaymentMethod < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_methods do |t|
      t.belongs_to :user
      t.string :stripe_token
      t.timestamps
    end
  end
end
