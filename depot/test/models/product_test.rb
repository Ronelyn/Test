require 'test_helper'

class ProductTest < ActiveSupport::TestCase

  fixtures :products
  
    # Wrong place for these. How SHOULD I have done this?
    # @valid_minimum_price        = 0.01
    # @blank                      = ''
    # @invalid_image_url          = 'invalid.wmf'
    # @invalid_price_text         = 'invalid price'
    
  test 'product attributes must not be empty' do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end
  
  test 'image url must be correct file type' do
    valid_image_file_urls = %w{ valid.gif valid.jpg valid.jpeg valid.png VALID.GIF VALID.gif http://a.b.c/x/y/z/valid.gif }
    product = create_valid_test_product
    product.image_url = 'invalid.wmf'
    assert product.invalid?
    assert_equal ['must be a URL for a GIF, Jpeg, or PNG image.'],
      product.errors[:image_url]
    valid_image_file_urls.each do |url|
      product = create_valid_test_product
      product.image_url = url
      product.valid? '#{url} should be valid and is not'
    end
  end
  
  test 'product price must be a number' do
    product = create_valid_test_product
    product.price = 'invalid price'
    assert product.invalid?
    assert_equal ['is not a number'],
      product.errors[:price]
  end
  
  test 'product price must be positive' do
    product = create_valid_test_product
    product.price = -5
    assert product.invalid?
    assert_equal ['must be greater than or equal to 0.01'],
      product.errors[:price]
    product.price = 0
    assert product.invalid?
    assert_equal ['must be greater than or equal to 0.01'],
      product.errors[:price]
  end
  
  test 'product price must meet minimum' do
    product = create_valid_test_product
    product.price = (0.01 / 2)
    assert product.invalid?
    assert_equal ['must be greater than or equal to 0.01'],
      product.errors[:price]
    product.price = 0.01
    assert product.valid?
  end

  test 'product titles must be unique' do
    product = create_valid_test_product
    product.title = products(:ruby).title
    assert product.invalid?
    assert_equal ['has already been taken'], product.errors[:title]
  end
  
  test 'product title minimum length 5 characters' do
    product = create_valid_test_product
    product.title = 'Four'
    assert product.invalid?
    assert_equal ["is too short (minimum is 5 characters)"], product.errors[:title]
  end
end
