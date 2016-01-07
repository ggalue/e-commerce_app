class AddThingToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :customer_key, :string
  end
end
