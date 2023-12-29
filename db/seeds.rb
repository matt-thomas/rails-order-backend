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
    year: 2023,
})
