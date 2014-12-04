class AddVisibleToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :visible, :boolean, default: false
  end
end
