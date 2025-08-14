class AddTaggingsCountToTags < ActiveRecord::Migration[7.1]
  def change
    add_column :tags, :taggings_count, :integer, default: 0, null: false
  end
end