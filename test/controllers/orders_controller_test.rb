require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  def setup
    @test_payload = {
      "customer_id": "flimflamjamman",
      "order_id": "abc5349bbrr",
      "items": [
        {
          "product_sku": "premium_widget",
          "quantity": "2"
        },
        {
          "product_sku": "mini_widget",
          "quantity": "3"
        }
      ],
      "shipping": {
        "ship_method": "usps",
        "address": {
          "name": "The Jam Man",
          "address1": "1500 Pennsylvania Avenue",
          "address2": "",
          "city": "Washington",
          "state": "DC",
          "postal_code": "20500",
          "country_code": "+1",
          "phone_number": "202-456-1414",
          "email": "thejamman@protonmail.com"
        }
      }
    }
    @update_payload = {
      "order_id": "abc5349bbrr",
      "items": [
        {
          "product_sku": "mini_widget",
          "quantity": "1"
        }
      ],
      "shipping": {
        "ship_method": "fedex",
        "address": {
          "name": "The FlimFlamJamMan",
          "address1": "101 W Main St",
          "address2": "",
          "city": "White Sulphur Springs",
          "state": "WV",
          "postal_code": "24986",
          "country_code": "+1",
          "phone_number": "855-453-4858",
          "email": "newemailgb1@protonmail.com"
        }
      }
    }
  end

  test 'POST #create should create a new order' do
    post :create, params: @test_payload, as: :json

    assert_response :created
    assert_equal 'Order created successfully', JSON.parse(response.body)['message']
    assert_not_nil JSON.parse(response.body)['order']

    # Only one order.
    assert_equal 1, Order.count()

    # Order values match.
    created_order = Order.last
    created_customer = created_order.customer
    created_shipment = created_order.shipments.last()
    created_address = created_shipment.address

    assert_equal 'flimflamjamman', created_customer.customer_external_id

    assert_equal 'abc5349bbrr', created_order.order_external_id
    assert_equal 2, created_order.line_items.count
    assert_equal 44.95, created_order.order_total

    assert_equal 'usps', created_shipment.ship_method

    assert_equal 'The Jam Man', created_address.name
    assert_equal '1500 Pennsylvania Avenue', created_address.address1
    assert_equal 'Washington', created_address.city
    assert_equal 'DC', created_address.state
    assert_equal '20500', created_address.postal_code
    assert_equal '+1', created_address.country_code
    assert_equal '202-456-1414', created_address.phone_number
    assert_equal 'thejamman@protonmail.com', created_address.email

    # Post again.
    post :create, params: @test_payload, as: :json
    assert_response :unprocessable_entity
    assert_equal '{"errors":["Order external has already been taken"]}', response.body

    # Post update.
    post :update, params: @update_payload, as: :json

    assert_response :accepted
    assert_equal 'Order updated successfully', JSON.parse(response.body)['message']
    assert_not_nil JSON.parse(response.body)['order']

    # Only one order.
    assert_equal 1, Order.count()
    assert_equal 1, LineItem.count()
    assert_equal 1, Shipment.count()

    # Order values match.
    updated_order = Order.last
    created_shipment = updated_order.shipments.last()
    created_address = created_shipment.address

    assert_equal 'flimflamjamman', created_customer.customer_external_id

    assert_equal 'abc5349bbrr', updated_order.order_external_id
    assert_equal 1, updated_order.line_items.count
    assert_equal 4.99, updated_order.order_total

    assert_equal 'fedex', created_shipment.ship_method

    assert_equal 'The FlimFlamJamMan', created_address.name
    assert_equal '101 W Main St', created_address.address1
    assert_equal 'White Sulphur Springs', created_address.city
    assert_equal 'WV', created_address.state
    assert_equal '24986', created_address.postal_code
    assert_equal '+1', created_address.country_code
    assert_equal '855-453-4858', created_address.phone_number
    assert_equal 'newemailgb1@protonmail.com', created_address.email

  end

  test 'POST #create without any items' do
    payload_without_items = @test_payload.except(:items)
    post :create, params: payload_without_items, as: :json

    assert_response :unprocessable_entity
    assert_equal 0, Order.count()
  end

  test "should only delete appropriate line items and shipments when order is deleted" do
    one = Product.first
    two = Product.last

    customer1 = Customer.create(customer_external_id: "abc123")
    order1 = Order.create(order_external_id: "123456", customer: customer1)
    line_item1 = LineItem.create(order: order1, quantity: 2, price: one.price, product: one)
    line_item2 = LineItem.create(order: order1, quantity: 1, price: two.price, product: two)

    # Ensure line item count matches.
    assert_equal 2, order1.line_items.count

    # Create associated shipment/address.
    address = Address.find_or_create_by(
      name: "The Jam Man",
      address1: "1500 Pennsylvania Avenue",
      address2: "",
      city: "Washington",
      state: "DC",
      postal_code: "20500",
      country_code: "+1",
      phone_number: "202-456-1414",
      email: "thejamman@protonmail.com"
    )

    Shipment.create(address: address, order: order1, ship_method: "fedex")

    # Ensure line items and shipment are associated with the order
    assert_equal 1, order1.shipments.count

    # Create 2 more orders.
    customer2 = Customer.create(customer_external_id: "abc431")
    order2 = Order.create(order_external_id: "1137", customer: customer2)
    LineItem.create(order: order2, quantity: 1, price: one.price, product: one)

    # Ensure line item count matches.
    assert_equal 1, order2.line_items.count

    # Create associated shipment/address.
    address = Address.find_or_create_by(
      name: "Clarissa Mao",
      address1: "New Mexico State House",
      address2: "",
      city: "Santa Fe", # Assuming the New Mexico State House is in Santa Fe
      state: "NM",      # State code for New Mexico
      postal_code: "87501", # Replace with the correct postal code for the State House
      country_code: "+1",
      phone_number: "704-867-5309", # Replace with the phone number
      email: "clarissa.mao@example.com"     # Replace with the email address
    )

    Shipment.create(address: address, order: order2, ship_method: "usps")

    # Ensure line items and shipment are associated with the order
    assert_equal 1, order2.shipments.count
    assert_equal "usps", order2.shipments.last.ship_method

    customer3 = Customer.create(customer_external_id: "bb44323")
    order3 = Order.create(order_external_id: "11430bb", customer: customer3)
    LineItem.create(order: order3, quantity: 1, price: one.price, product: one)

    # Ensure line item count matches.
    assert_equal 1, order3.line_items.count

    # Create associated shipment/address for the second order with William Shakespeare's details
    address = Address.find_or_create_by(
      name: "William Shakespeare",
      address1: "Tucumcari City Hall",
      address2: "123 Main St",
      city: "Tucumcari",
      state: "NM",
      postal_code: "88401", 
      country_code: "+1",
      phone_number: "555-123-4567", 
      email: "shakespeare@example.com" 
    )

    Shipment.create(address: address, order: order3, ship_method: "usps")

    # Ensure line items and shipment are associated with the second order
    assert_equal 1, order3.shipments.count
    assert_equal "usps", order3.shipments.last.ship_method

    assert_equal 4, LineItem.count
    assert_equal 3, Shipment.count

    # Destroy the order
    order1.destroy

    # Ensure the order is deleted
    assert_nil Order.find_by(order_external_id: "123456")
    assert true, Order.find_by(order_external_id: "1137")
    assert true, Order.find_by(order_external_id: "11430bb")

    # Ensure associated line items and shipment are also deleted
    assert_nil LineItem.find_by(product: two)
    assert_nil Shipment.find_by(ship_method: "fedex")
    assert_equal 2, Shipment.where(ship_method: "usps").count

    # One more check.
    assert_equal 2, LineItem.count
    assert_equal 2, Shipment.count
    assert_equal 2, Order.count
  end

  test "should delete associated line items and shipments when order is deleted" do
    customer = Customer.create(customer_external_id: "abc123")
    order = Order.create(order_external_id: "123456", customer: customer)

    # Create associated line items
    one = Product.first
    two = Product.last
    line_item1 = LineItem.create(order: order, quantity: 2, price: one.price, product: one)
    line_item2 = LineItem.create(order: order, quantity: 1, price: two.price, product: two)

    # Ensure line item count matches.
    assert_equal 2, order.line_items.count

    # Create associated shipment/address.
    address = Address.find_or_create_by(
      name: "The Jam Man",
      address1: "1500 Pennsylvania Avenue",
      address2: "",
      city: "Washington",
      state: "DC",
      postal_code: "20500",
      country_code: "+1",
      phone_number: "202-456-1414",
      email: "thejamman@protonmail.com"
    )

    shipment = Shipment.create(address: address, order: order, ship_method: "fedex")

    # Ensure line items and shipment are associated with the order
    assert_equal 1, order.shipments.count

    # Destroy the order
    order.destroy

    # Ensure the order is deleted
    assert_nil Order.find_by(order_external_id: "123")

    # Ensure associated line items and shipment are also deleted
    assert_nil LineItem.find_by(product: one)
    assert_nil Shipment.find_by(ship_method: "fedex")

    # One more check.
    assert_equal 0, LineItem.count
    assert_equal 0, Shipment.count
  end

  test 'Test update without order' do
    # Post update.
    post :update, params: @update_payload, as: :json

    assert_response :not_found
    assert_equal '{"error":"Order not found"}', response.body

  end

end
