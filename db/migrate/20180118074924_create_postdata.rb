class CreatePostdata < ActiveRecord::Migration[5.1]
  def change
    create_table :postdata do |t|
      t.string :hookId
      t.string :run_id
      t.string :payload

      t.timestamps
    end
  end
end
