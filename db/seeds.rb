# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

p1 = Product.create({
    product_name: "Premium Widget",
    sku: "premium_widget",
    price: 14.99,
    product_type: 'big_ticket'
})

p2 = Product.create({
    product_name: "Mini Widget",
    sku: "mini_widget",
    price: 4.99,
    product_type: 'big_ticket'
})

p3 = Product.create({
    product_name: "Product One",
    sku: "SKU-123",
    price: 0.99,
    product_type: 'small_ticket'
})

p3 = Product.create({
    product_name: "Product Two",
    sku: "SKU-456",
    price: 11.99,
    product_type: 'small_ticket'
})

FeaturedProduct.create({
    product: p1,
    month: 12,
})
