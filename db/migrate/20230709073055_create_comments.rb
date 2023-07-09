class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.text :body
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :commentable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
