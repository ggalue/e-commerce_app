class CartController < ApplicationController

before_filter :authenticate_user!, except: [:add_to_cart, :view_order]

  def add_to_cart
  	product = Product.find(params[:product_id])
  	if product.quantity < params[:qty].to_i
  		redirect_to product, notice: "Not enough quantity in stock."
  	else
  		line_item = LineItem.new
  		line_item.product_id = params[:product_id].to_i
  		line_item.quantity = params[:qty]

    if user_signed_in? 
      line_item.customer_key = current_user.id
    else
      line_item.customer_key = remote_ip
    end
  		line_item.save

  	 line_item.line_item_total = line_item.quantity * line_item.product.price 
  	 line_item.save

  	redirect_to view_order_path
  end
end 

  def view_order
    if user_signed_in?
  	@line_items = LineItem.where(customer_key: current_user.id.to_s)
  else
    @line_items = LineItem.where(customer_key: remote_ip)
  end 
   
  end

  def checkout
  	@line_items = LineItem.all
  	@order = Order.new
  	@order.user_id = current_user.id

  	sum = 0

  	@line_items.each do |line_item|
  		@order.order_items[line_item.product_id] = line_item.quantity
  		sum += line_item.line_item_total
  	end

  	@order.subtotal = sum
  	@order.sales_tax = sum * 0.07
  	@order.grand_total = @order.subtotal + @order.sales_tax
  	@order.save

  	@line_items.each do |line_item|
  		line_item.product.quantity -= line_item.quantity
  		line_item.product.save
  	end 

  	@line_items.destroy_all

  end

  def remove_from_cart
  	LineItem.find(params[:id]).destroy

  	redirect_to view_order_path
  end

  def edit_line_item
    line_item = LineItem.find(params[:id])

    if Product.find(line_item.product_id).quantity < params[:qty].to_i
      redirect_to view_order_path, notice: "Not enough quantity in stock to cover larger order."
    else
      line_item.quantity = params[:qty].to_i
      line_item.save
      redirect_to view_order_path
    end 
  end 

  def order_complete
    @order = Order.find(params[:order_id])
    @amount = (@order.grand_total.to_f.round(2) * 100).to_i

    customer = Stripe::Customer.create(
      :email => current_user.email,
      :card => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer => customer.id,
      :amount => @amount,
      :description => 'Rails Stripe customer',
      :currency => 'usd'
    )

    rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to charges_path


  end 
end
