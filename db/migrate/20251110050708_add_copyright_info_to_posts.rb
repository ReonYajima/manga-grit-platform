class AddCopyrightInfoToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :manga_author, :string
    add_column :posts, :manga_publisher, :string
    add_column :posts, :manga_volume, :integer
    add_column :posts, :manga_page, :integer
  end
end
