@isTest
public class ProductModelTest {

    static testmethod void testOne() {

        // Access ProductModel outer class
        ProductModel productModel = new ProductModel();

        // Access data members and update their values
        List<ProductModel.Image> images=new List<ProductModel.Image>();
        List<ProductModel.Variations> variations = new List<ProductModel.Variations>();
        productModel.title = 'sampleId';
        productModel.id = 'xyz';
        productModel.created_at = 'abc@gmail.com';
        productModel.updated_at = 'xyz';
        productModel.type = 'abc';
        productModel.status = 'xyz';
        productModel.downloadable = 'abc';
        productModel.virtualType = 'abc';
        productModel.permalink = 'xyz';
        productModel.sku = 'abc';
        productModel.price = 10;
        productModel.regular_price = 10;
        productModel.sale_price = 'abc';
        productModel.price_html = 'xyz';
        productModel.taxable = 'abc';
        productModel.tax_status = 'xyz';
        productModel.tax_class = 'abc';
        productModel.managing_stock = 'abc';
        productModel.sold_individually = 'xyz';
        productModel.in_stock = 'abc';
        productModel.backordered = 'abc';
        productModel.backorders_allowed = 'xyz';
        productModel.purchaseable = 'abc';
        productModel.featured = 'xyz';
        productModel.visible = 'abc';
        productModel.catalog_visibility = 'abc';
        productModel.on_sale = 'abc';
        productModel.product_url = 'xyz';
        productModel.button_text = 'abc';
        productModel.weight = 'abc';
        productModel.shipping_required = 'xyz';
        productModel.shipping_class = 'abc';
        productModel.shipping_class_id = 'xyz';
        productModel.reviews_allowed = 'abc';
        productModel.description = 'abc';
        productModel.short_description = 'xyz';
        productModel.average_rating = 'abc';
        productModel.rating_count = 'abc';
        productModel.parent_id = 'xyz';
        productModel.total_sales = 'abc';
        productModel.featured_src = 'xyz';
        productModel.download_limit = 'abc';
        productModel.download_expiry = 'abc';
        productModel.download_type = 'xyz';
        productModel.purchase_note = 'abc';

        List<String> categories = new List<String>{'nop','abc'};
        productModel.categories = categories;

        // Access Dimension inner class
        ProductModel.Dimension dimensionsOne = new ProductModel.Dimension();

        dimensionsOne.length = '10';
        dimensionsOne.width = '20';
        dimensionsOne.height = '10';
        dimensionsOne.unit = '20';

        // Access dimensions data members and add their values
        productModel.dimensions = dimensionsOne;

        // Access Image inner class
        ProductModel.Image imagesOne = new ProductModel.Image();

        imagesOne.id = 'sampleId';
        imagesOne.created_at = 'sampleCreatedAt';
        imagesOne.updated_at = 'sampleUpdatedAt';
        imagesOne.src = 'sampleSrc';
        imagesOne.title = 'sampleTitle';
        imagesOne.alt = 'sampleAlt';
        imagesOne.position = 'samplePosition';

        images.add(imagesOne);
        
        // Access images data members and add their values
        productModel.images=images;
        
        // Access Image inner class
        ProductModel.Variations variationsone = new ProductModel.Variations();
        variationsone.id = 'sampleId';
        variationsone.created_at = DateTime.now();
        variationsone.updated_at = DateTime.now();
        variationsone.downloadable = true;
        variationsone.virtualType = true;
        variationsone.permalink = 'sampleSrc';
        variationsone.sku = 'sampleSku';
        variationsone.price = 10;
        variationsone.regular_price = 10;
        variationsone.sale_price = 10;
        variationsone.taxable = true;
        variationsone.tax_status = 'sampleTaxStatus';
        variationsone.tax_class = 'sampleTaxClass';
        variationsone.managing_stock = true;
        variationsone.stock_quantity = 10;
        variationsone.in_stock = true;
        variationsone.backordered = true;
        variationsone.purchaseable = true;
        variationsone.visible = true;
        variationsone.on_sale = true;
        variationsone.weight = '10';
        variationsone.shipping_class = 'sample Ship class';
        variationsone.shipping_class_id = 'sampleShipclassId';
        variations.add(variationsone);
        productModel.variations=variations;
        variationsone.dimensions = dimensionsOne;
        variationsone.image = images;
        System.assert(true);
    }
}