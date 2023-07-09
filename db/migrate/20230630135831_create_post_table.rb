class CreatePostTable < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :name
      t.string :content
    end
  end
end
