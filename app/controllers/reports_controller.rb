# app/controllers/reports_controller.rb

class ReportsController < ApplicationController
  def monthly_report
    # month = params[:month].to_i || Date.today.month
    # year = params[:year].to_i || Date.today.year

    month = Date.today.month
    year = Date.today.year

    p month
    p year

    total_revenue_month = LineItem.joins(:order, :product)
                                  .where("strftime('%Y', orders.created_at) = ? AND strftime('%m', orders.created_at) = ?", year.to_s, '%02d' % month)
                                  .sum("line_items.quantity * line_items.price")

    product_quantities = LineItem.joins(:product)
                                 .where("strftime('%Y', line_items.created_at) = ? AND strftime('%m', line_items.created_at) = ?", year.to_s, '%02d' % month)
                                 .group("products.product_type")
                                 .sum("line_items.quantity")

    product_quantities_by_sku = LineItem.joins(:product)
                                 .where("strftime('%Y', line_items.created_at) = ? AND strftime('%m', line_items.created_at) = ?", year.to_s, '%02d' % month)
                                 .group("products.sku")
                                 .sum("line_items.quantity")

    top_spending_customer_month = Order.joins(:customer)
                                       .where("strftime('%Y', orders.created_at) = ? AND strftime('%m', orders.created_at) = ?", year.to_s, '%02d' % month)
                                       .group("orders.customer_id")
                                       .order("SUM(orders.order_total) DESC")
                                       .limit(1)
                                       .pluck("customers.customer_external_id")
                                       .first

    top_spending_customer_year = Order.joins(:customer)
                                      .where("strftime('%Y', orders.created_at) = ?", year.to_s)
                                      .group("orders.customer_id")
                                      .order("SUM(orders.order_total) DESC")
                                      .limit(1)
                                      .pluck("customers.customer_external_id")
                                      .first

    featured_product_this_month = FeaturedProduct.find_by(month: month, year: year)
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
      total_revenue_month: total_revenue_month.round(2),
      product_quantities: product_quantities,
      product_quantities_by_sku: product_quantities_by_sku,
      top_spending_customer_month: top_spending_customer_month,
      top_spending_customer_year: top_spending_customer_year,
      customers_purchased_featured_product: customers_purchased_featured_product
    }

    render json: report
  end
end
