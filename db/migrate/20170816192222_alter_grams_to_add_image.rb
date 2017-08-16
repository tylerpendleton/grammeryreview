class AlterGramsToAddImage < ActiveRecord::Migration[5.0]
  def change
    add_column :grams, :image, :string
  end
end
