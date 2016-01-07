json.array!(@orders) do |order|
  json.extract! order, :id, :subtotal, :sales_tax, :grand_total, :user_id, :order_items
  json.url order_url(order, format: :json)
end
