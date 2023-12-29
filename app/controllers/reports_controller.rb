# app/controllers/reports_controller.rb

class ReportsController < ApplicationController
  def monthly_report
    # Calculate sum of total revenue from all products ordered in the month
    month = Date.today.month
    total_revenue_month = LineItem.joins(:order, :product)
                                  .where("strftime('%m', orders.created_at) = ?", '%02d' % month)
                                  .sum("line_items.quantity * products.price")

    # Calculate quantity of each product type ordered
    product_quantities = LineItem.joins(:product)
                                 .group("products.product_type")
                                 .sum("line_items.quantity")

    # Find top spending customer of the month
    top_spending_customer_month = Order.joins(:customer)
                                       .where("strftime('%m', orders.created_at) = ?", '%02d' % month)
                                       .group("orders.customer_id")
                                       .order("SUM(orders.order_total) DESC")
                                       .limit(1)
                                       .pluck("customers.customer_external_id")
                                       .first

    # Find top spending customer of the year
    top_spending_customer_year = Order.joins(:customer)
                                      .where("strftime('%Y', orders.created_at) = ?", Date.today.year.to_s)
                                      .group("orders.customer_id")
                                      .order("SUM(orders.order_total) DESC")
                                      .limit(1)
                                      .pluck("customers.customer_external_id")
                                      .first

    # Find email addresses of customers who purchased this month's featured product
    featured_product_this_month = FeaturedProduct.find_by(month: month)
    if featured_product_this_month
      customers_purchased_featured_product = Order.joins(:customer)
                                                  .joins(:line_items)
                                                  .joins("INNER JOIN shipments ON shipments.order_id = orders.id")
                                                  .joins("INNER JOIN addresses ON addresses.id = shipments.address_id")
                                                  .where("line_items.product_id = ?", featured_product_this_month.product_id)
                                                  .pluck("addresses.email")
                                                  .uniq
    else
      customers_purchased_featured_product = []
    end

    report = {
      total_revenue_month: total_revenue_month,
      product_quantities: product_quantities,
      top_spending_customer_month: top_spending_customer_month,
      top_spending_customer_year: top_spending_customer_year,
      customers_purchased_featured_product: customers_purchased_featured_product
    }

    render json: report
  end
end
