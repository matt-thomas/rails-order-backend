class OrdersController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid, NoMethodError, with: :render_unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

  def create
    order, customer, line_items, shipment, address = create_order
    return unless order

    render json: { message: 'Order created successfully', order: order, customer: order.customer, line_items: order.line_items.all, shipment: order.shipments.all, address: order.shipments.last.address }, status: :created
  end

  def update
    order = Order.find_by(order_external_id: order_params[:order_id])
    return render_not_found_response('Order not found') unless order

    update_order(order)
  end

  private

  def create_order
    customer = Customer.find_or_create_by(customer_external_id: order_params[:customer_id])
    order = Order.new(order_external_id: order_params[:order_id], customer:customer)
    order.transaction do
      order.save!
      create_line_items(order, order_params[:items])
      create_shipment(order, order_params[:shipping])
      calculate_order_total(order)
    end
    order
  rescue ActiveRecord::RecordInvalid => e
    order.destroy if order&.persisted?
    render_unprocessable_entity_response(e.record.errors.full_messages)
    nil
  end

  def update_order(order)
    order.transaction do
      order.line_items.delete_all
      order.shipments.delete_all
      create_line_items(order, order_params[:items])
      create_shipment(order, order_params[:shipping])
      calculate_order_total(order)
      order.save!
    end
    # Remove all dangling line items/shipments if the above transaction succeeded. 
    LineItem.where(order: nil).destroy_all # Hack
    Shipment.where(order: nil).destroy_all # Hack
    render json: { message: 'Order updated successfully', order: order, customer: order.customer, line_items: order.line_items.all, shipment: order.shipments.all, address: order.shipments.last.address }, status: :accepted
  rescue ActiveRecord::RecordInvalid => e
    render_unprocessable_entity_response(e.record.errors.full_messages)
  end

  def create_line_items(order, items)
    items.each do |item|
      product = Product.find_by(sku: item[:product_sku])
      order.line_items.create!(quantity: item[:quantity], price: product.price, product: product)
    end
  end

  def create_shipment(order, shipping)
    address = Address.find_or_create_by(shipping[:address])
    order.shipments.create!(address: address, ship_method: shipping[:ship_method])
  end

  def order_params
    params.permit(
      :customer_id,
      :order_id,
      items: [:product_sku, :quantity],
      shipping: [
        :ship_method,
        address: [
          :name,
          :address1,
          :address2,
          :city,
          :state,
          :postal_code,
          :country_code,
          :phone_number,
          :email
        ]
      ]
    )

  end

  def render_unprocessable_entity_response(errors)
    render json: { errors: errors }, status: :unprocessable_entity
  end

  def render_not_found_response(message)
    render json: { error: message }, status: :not_found
  end

  def calculate_order_total(order)
    total = order.line_items.sum { |item| item.quantity * item.price }
    order.order_total = total
    order.save!
  end
end
