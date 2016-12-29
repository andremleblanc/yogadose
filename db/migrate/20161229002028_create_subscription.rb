class CreateSubscription< ActiveRecord::Migration[5.0]
  def change
    create_table :subscriptions do |t|
      t.belongs_to :user, index: true
      t.string :token

      t.timestamps
    end
  end
end
