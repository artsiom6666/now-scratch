global interface ShoppingCart {

	void connectToCart();

	Integer checkForOrders();

	List<CustomerModel> getCustomers();

	List<CustomerModel> getCustomerbyId(String customerId);

	List<CustomerModel> getCustomerByEmail(String email);

	void addCustomer();

	List<OrderModel> getOrders();

	List<OrderModel> getOrder(String orderId);

	Boolean updateOrder(String orderId, Map<String, String> orderData);

	Boolean placeOrder(Map<String, String> orderData);

	List<OrderModel> getCustomerOrders(String customerId);

	List<ProductModel> getProducts();

	List<ProductModel> getProduct(String productId);

	Boolean addProduct(Map<String, String> productData);

	List<String> getCategories();

	String getCategory(String categoryId);

	Boolean addCategory(Map<String, String> categoryData);

	List<ProductModel> getProductVariant(String productId);

	List<ProductModel> getProductVariants(String productId);

	Boolean addProductVariant(Map<String, String> variantData);

	void getProductVariantImage(String productId, String variantId);

	void getProductVariantsImage(String productId, String variantId);

	Boolean addProductVariantImage(Map<String, String> variantData);

	List<ProductModel> getProductImage(String productId);

	Boolean addProductImage(Map<String, String> productData);

	Boolean updateShippingDetails(Map<String, String> shippingData);

	String receiveOrderNotification();
}