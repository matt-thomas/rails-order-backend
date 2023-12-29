# README

This is a basic order/product/shipment Rails application.

## Notes/Assumptions

- No frontend is provided.
- There is no relationship between a customer and their address. Rather, the address relates to the shipment entity.
- Multiple customers can have the same email, but not external ID.
- Robust tracking of prices changes is not provided. Price is captured on line items so that if price changes, order line items still reflect the original price.

## Running Locally

### Bundle Install

`bundle install`

### Drop and Recreate DB

`bin/rails db:drop; bin/rails db:create; bin/rails db:migrate; bin/rails db:seed`

### Run Server

`bin/rails server`

### Run Tests

`bin/rails test`

## API Endpoint Usage

### Create

```curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
        "customer_id": "12345",
        "order_id": "67890",
        "items": [
          {
            "product_sku": "SKU-123",
            "quantity": 2
          },
          {
            "product_sku": "SKU-456",
            "quantity": 1
          }
        ],
        "shipping": {
          "ship_method": "fast",
          "address": {
            "name": "John Doe",
            "address1": "123 Main St",
            "address2": "",
            "city": "Anytown",
            "state": "NY",
            "postal_code": "12345",
            "country_code": "US",
            "phone_number": "123-456-7890",
            "email": "john@example.com"
          }
        }
      }' \
  http://localhost:3000/orders/create
  ```

### Order Update

```
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
        "order_id": "67890",
        "items": [
          {
            "product_sku": "mini_widget",
            "quantity": 3
          }
        ],
        "shipping": {
          "ship_method": "express",
          "address": {
            "name": "Jane Smith",
            "address1": "456 Oak St",
            "address2": "Apt 2B",
            "city": "Sometown",
            "state": "CA",
            "postal_code": "54321",
            "country_code": "US",
            "phone_number": "987-654-3210",
            "email": "jane@example.com"
          }
        }
      }' \
      http://localhost:3000/orders/update
```

## Basic Report

A basic JSON report exists at http://localhost:3000/reports/monthly_report

- Sum of total revenue from all products ordered in the month
- Quantity of each product type ordered
- Quantity of each product sku ordered
- Top spending customer of the month
- Top spending customer of the year
- Email addresses of all customers who purchased that month’s feature product

## Basic Entities

### Customer

Exists as a reference to a customer, but no data beyond the external id (which must be unique) are stored. Customers belong to orders.

### Order

Represents an order from the external system. The external id must be unique. This record references customer records and is referenced by shipping and line item records.

### Line Item

References an order and product. Stores the quantity of the product ordered and the price of the product at the time of order. Price is captured on line items so that if price changes, order line items still reflect the original price.

### Shipment

References order and address, stores shipment method. 

### Address

Represents an address, is referenced by shipment.

### Product

Represents a product, is referenced by line item and featured product. Products have a price, sku, name, and type. 

### Featured Product

Represents a monthly featured product. References product and stores month.

## Tests

Basic test coverage exists for order creation and update.

## Major next steps.

- Change featured product to store year.
- More robust unit tests, including reporting.
- More validation of phone, email, address, etc.
- Multiple shipments per order.
- More tracking of order edits: currently if line items are changed those references don't persist, so price history doesn't exist in case of multiple order edits.
- Better reporting.
- Dockerize w/hosted DB.
- Inventory management.
- Cleanup dangling addresses, we only want to delete when nothing references them.