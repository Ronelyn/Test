require 'test_helper'

class CartsControllerTest < ActionController::TestCase
  setup do
    @cart = carts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:carts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cart" do
    assert_difference('Cart.count') do
      post :create, cart: {  }
    end

    assert_redirected_to cart_path(assigns(:cart))
  end

  test "should show cart" do
    get :show, id: @cart
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cart
    assert_response :success
  end

  test "should update cart" do
    patch :update, id: @cart, cart: {  }
    assert_redirected_to cart_path(assigns(:cart))
  end

  test "should destroy cart" do
    assert_difference('Cart.count', -1) do
      session[:cart_id] = @cart.id
      delete :destroy, id: @cart
    end

    assert_redirected_to store_path
  end
  
  test "should have add_product method" do
    assert_respond_to @cart, :add_product
  end
  
  test "cart returns correct added product" do
    product_id = 1
    assert_equal product_id, @cart.add_product(product_id).quantity, 'Cart returned wrong product ID'
  end
  
  test "adding duplicate product increments quantity" do
    product_id = products(:ruby).id
     2.times do 
       puts "Added product #{products(:ruby)}"
       @cart.add_product(product_id)
     end
     puts "#{@cart.line_items.length} line items in cart"
     @cart.line_items.each do |item|
       puts "#{item} has #{item.quantity} of #{products(:ruby).title}"
     end
  end
  
end
