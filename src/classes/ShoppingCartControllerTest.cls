@isTest
public class ShoppingCartControllerTest {
    @isTest static void TestGetMyProductById()
    {
        ID standardPBID = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            ProductCode='ABC123TEST',
            Name='Test product ShippingCartHandler',
            Description='This is a test product for ShippingCartHandler Testing',
            IsActive=true
        );
        insert prod;
        
        Pricebook2 price = new Pricebook2(
            Name='ABC123TEST',
            Description='This is a test product for ShippingCartHandler Testing',
            IsActive=true
        );
        insert price;

        PricebookEntry pbentrystd = new PricebookEntry(
            UnitPrice=99.99,
            Product2Id=prod.Id,
            Pricebook2Id=standardPBID,
            IsActive=true,
            UseStandardPrice=false
        );
        insert pbentrystd;
        
        // Test
        ID pbID = prod.Id;
        PricebookEntry oneproduct = ShoppingCartController.getMyProductById(pbID);
        System.assertEquals(pbentrystd.Id,oneproduct.Id);
        System.assertEquals(99.99,oneproduct.UnitPrice);
        System.assertEquals(prod.Id,oneproduct.Product2.Id);
        System.assertEquals('ABC123TEST',oneproduct.Product2.ProductCode);
        System.assertEquals('Test product ShippingCartHandler',oneproduct.Product2.Name);
        System.assertEquals('This is a test product for ShippingCartHandler Testing',oneproduct.Product2.Description);

        
    }
    
    @isTest static void TestGetMyProductImageById()
    {
        Product2 prod = new Product2(
            ProductCode='ABC123TEST',
            Name='Test product ShippingCartHandler',
            Description='This is a test product for ShippingCartHandler Testing',
            IsActive=true
        );
        insert prod;
        
        Product_Image__c prodimage = new Product_Image__c(
            Product_Lookup__c=prod.Id,
            Image_URL__c='https://test.google.com'
        );
        insert prodimage;
        
        // Test
        ID pbID = prod.Id;
        String oneproduct = ShoppingCartController.getMyProductImageById(pbID);
        System.assertEquals('https://test.google.com',oneproduct);

    }
    
   @isTest static void TestGetMyVariantImageById()
    {

        Product_Variant__c var = new Product_Variant__c(
            Requires_Shipping__c = true,
            Taxable__c = true
        );
        insert var;
        Product_Image__c prodimage = new Product_Image__c(
            Product_Variant_Lookup__c=var.Id,
            Image_URL__c='https://test.google.com'
        );
        insert prodimage;
        // Test
        ID pbID = var.Id;
        String oneproduct = ShoppingCartController.getMyVariantImageById(pbID);
        System.assertEquals('https://test.google.com',oneproduct);

    }


    @isTest static void TestGetProductsListbyCategory()
    {
        ID standardPBID = Test.getStandardPricebookId();
        
        Category__c category = new Category__c(
            Brand__c='Test',
            Category_Name__c='Test Category Name'
        );
        insert category;
        Category__c catname = [SELECT Name from Category__c WHERE Id = :category.Id LIMIT 1];
        
        Product2 prod1 = new Product2(
            ProductCode='ABC123TEST1',
            Name='Test product ShoppingCartHandler',
            Description='This is a test product for ShoppingCartHandler Testing',
            Category__c=category.Id,
            IsActive=true
        );
        insert prod1;
        Product2 prod2 = new Product2(
            ProductCode='ABC123TEST2',
            Name='Test product ShoppingCartHandler',
            Description='This is a test product for ShoppingCartHandler Testing',
            Category__c=category.Id,
            IsActive=true
        );
        insert prod2;
        Product2 prod3 = new Product2(
            ProductCode='ABC123TEST3',
            Name='Test product ShoppingCartHandler',
            Description='This is a test product for ShoppingCartHandler Testing',
            Category__c=category.Id,
            IsActive=true
        );
        insert prod3;
        
        Pricebook2 price = new Pricebook2(
            Name='ABC123TEST',
            Description='This is a test product for ShippingCartHandler Testing',
            IsActive=true
        );
        insert price;

        PricebookEntry pbentrystd1 = new PricebookEntry(
            UnitPrice=99.99,
            Product2Id=prod1.Id,
            Pricebook2Id=standardPBID,
            IsActive=true,
            UseStandardPrice=false
        );
        insert pbentrystd1;
        PricebookEntry pbentrystd2 = new PricebookEntry(
            UnitPrice=99.99,
            Product2Id=prod2.Id,
            Pricebook2Id=standardPBID,
            IsActive=true,
            UseStandardPrice=false
        );
        insert pbentrystd2;
        PricebookEntry pbentrystd3 = new PricebookEntry(
            UnitPrice=99.99,
            Product2Id=prod3.Id,
            Pricebook2Id=standardPBID,
            IsActive=true,
            UseStandardPrice=false
        );
        insert pbentrystd3;
        
        // Test
        String pbID = catname.Name;
        List<PricebookEntry> oneproduct = ShoppingCartController.getProductsListbyCategory(pbID);
        System.assertEquals( 3, oneproduct.size());
        System.assertEquals(pbentrystd1.Id,oneproduct[0].Id);
        System.assertEquals(pbentrystd2.Id,oneproduct[1].Id);
        System.assertEquals(pbentrystd3.Id,oneproduct[2].Id);
        System.assertEquals(99.99,oneproduct[0].UnitPrice);
        System.assertEquals(prod1.Id,oneproduct[0].Product2.Id);
        System.assertEquals('ABC123TEST1',oneproduct[0].Product2.ProductCode);
        System.assertEquals('Test product ShoppingCartHandler',oneproduct[0].Product2.Name);
        
    }

    @isTest static void TestGetTopCategoryList()
    {
        
        Category__c categorytop = new Category__c(
            Brand__c='TestClass',
            Category_Name__c='Master Category Name',
            Category_Description__c='Master Category Description'
        );
        insert categorytop;
        
        Category__c category2nd = new Category__c(
            Brand__c='TestClass',
            ParentCategory__c=categorytop.Id,
            Category_Name__c='Master Category Name',
            Category_Description__c='Master Category Description'
        );
        insert category2nd;
        
         // Test
        String pbID = 'TestClass';
        List<Category__c> oneproduct = ShoppingCartController.getTopCategoryList(pbID);
        System.assertEquals( 1, oneproduct.size());
        
        
    }

    @isTest static void TestCategoryIdbyCategoryName()
    {
        ID standardPBID = Test.getStandardPricebookId();
        
        Category__c category = new Category__c(
            Brand__c='Test',
            Category_Name__c='Test Category Name'
        );
        insert category;
        Category__c catname = [SELECT Name from Category__c WHERE Id = :category.Id LIMIT 1];
        
        // Test
        String pbID = category.Category_Name__c;
        String result = ShoppingCartController.getCategoryIdbyCategoryName(pbID);
        System.assertEquals( catname.Name, result);
    }    

        @isTest static void TestGetMyProductVariantsById()
    {
        Product2 prod1 = new Product2(ProductCode='ABC123TEST', Name='Test1 product ShippingCartHandler', Description='This is a test product for ShippingCartHandler Testing', IsActive=true);
        Product2 prod2 = new Product2(ProductCode='ABC321TEST', Name='Test2 product ShippingCartHandler', Description='This is a test product for ShippingCartHandler Testing', IsActive=true);
        insert new List<Product2> {prod1, prod2};
        
        Product_Variant__c var1 = new Product_Variant__c(Variant_Type__c = 'Test Variant_Type1', Product_Title__c = 'Test Product_Title1', Price__c = 10, Requires_Shipping__c = true, Taxable__c = true, Product__c = prod1.Id);
        Product_Variant__c var2 = new Product_Variant__c(Variant_Type__c = 'Test Variant_Type2', Product_Title__c = 'Test Product_Title2', Price__c = 20, Requires_Shipping__c = true, Taxable__c = true, Product__c = prod1.Id);
        Product_Variant__c var3 = new Product_Variant__c(Variant_Type__c = 'Test Variant_Type3', Product_Title__c = 'Test Product_Title3', Price__c = 30, Requires_Shipping__c = true, Taxable__c = true, Product__c = prod2.Id);
        insert new List<Product_Variant__c> {var1, var2, var3};

        // Test
        List<Product_Variant__c> result = ShoppingCartController.getMyProductVariantsById(prod1.Id);
        Boolean variantType1 = false;
        Boolean variantType2 = false;
        Boolean productTitle1 = false;
        Boolean productTitle2 = false;
        Boolean price1 = false;
        Boolean price2 = false;

        for (Product_Variant__c item : result) {
            if (item.Variant_Type__c == var1.Variant_Type__c) {
                variantType1 = true;
            }
            if (item.Variant_Type__c == var2.Variant_Type__c) {
                variantType2 = true;
            }
            if (item.Product_Title__c == var1.Product_Title__c) {
                productTitle1 = true;
            }
            if (item.Product_Title__c == var2.Product_Title__c) {
                productTitle2 = true;
            }
            if (item.Price__c == var1.Price__c) {
                price1 = true;
            }
            if (item.Price__c == var2.Price__c) {
                price2 = true;
            }
        }
        System.assertEquals( 2, result.size());
        System.assertEquals(true, variantType1);
        System.assertEquals(true, variantType2);
        System.assertEquals(true, productTitle1);
        System.assertEquals(true, productTitle2);
        System.assertEquals(true, price1);
        System.assertEquals(true, price2);

        result = ShoppingCartController.getMyProductVariantsById(prod2.Id);
        System.assertEquals( 1, result.size());
        System.assertEquals( var3.Variant_Type__c, result[0].Variant_Type__c);
        System.assertEquals( var3.Product_Title__c, result[0].Product_Title__c);
        System.assertEquals( var3.Price__c, result[0].Price__c);
    }



    @isTest static void TestGetMyProductVariantsByIdCatch() {

        Profile pr = [SELECT Id FROM Profile WHERE Name='Chatter Free User' LIMIT 1]; 
        User testUsr = new User(Alias = 'sysadm', Email='sysadmin@test.com', 
        EmailEncodingKey='UTF-8', LastName='TestSys', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = pr.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='123touchcrsysadmintest@123test.com');
        insert testUsr;

        Product2 prod = new Product2(
            ProductCode='ABC123TEST',
            Name='Test product ShippingCartHandler',
            Description='This is a test product for ShippingCartHandler Testing',
            IsActive=true
        );
        insert prod;
        
        Product_Variant__c var = new Product_Variant__c(
            Variant_Type__c = 'Test Variant_Type1',
            Product_Title__c = 'Test Product_Title1',
            Price__c = 10,
            Requires_Shipping__c = true,
            Taxable__c = true,
            Product__c = prod.Id
        );
        insert var;

        Product_Variant__c var1 = new Product_Variant__c(
            Variant_Type__c = 'Test Variant_Type2',
            Product_Title__c = 'Test Product_Title2',
            Price__c = 10,
            Requires_Shipping__c = true,
            Taxable__c = true,
            Product__c = prod.Id
        );
        insert var1;

        // Test
        ID pbID = prod.Id;
        
        System.runAs(testUsr) {  
            try {       
                List<Product_Variant__c> result = ShoppingCartController.getMyProductVariantsById(pbID);
            } catch (Exception e) { 
                   System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }


    @isTest static void TestCategoryIdbyCategoryNameCatch()
    {

        Profile pr = [SELECT Id FROM Profile WHERE Name='Chatter Free User' LIMIT 1]; 
        User testUsr = new User(Alias = 'sysadm', Email='sysadmin@test.com', 
        EmailEncodingKey='UTF-8', LastName='TestSys', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = pr.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='123touchcrsysadmintest@123test.com');
        insert testUsr;

        ID standardPBID = Test.getStandardPricebookId();
        Category__c category = new Category__c(
            Brand__c='Test',
            Category_Name__c='Test Category Name'
        );
        insert category;
        Category__c catname = [SELECT Name from Category__c WHERE Id = :category.Id LIMIT 1];
        
        // Test
        String pbID = category.Category_Name__c;
        
        System.runAs(testUsr) {  
            try {               
                String result = ShoppingCartController.getCategoryIdbyCategoryName(pbID);
            } catch (Exception e) { 
                   System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }       


    @isTest static void TestGetTopCategoryListCatch()
    {

        Profile pr = [SELECT Id FROM Profile WHERE Name='Chatter Free User' LIMIT 1]; 
        User testUsr = new User(Alias = 'sysadm', Email='sysadmin@test.com', 
        EmailEncodingKey='UTF-8', LastName='TestSys', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = pr.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='123touchcrsysadmintest@123test.com');
        insert testUsr;

        Category__c categorytop = new Category__c(
            Brand__c='TestClass',
            Category_Name__c='Master Category Name',
            Category_Description__c='Master Category Description'
        );
        insert categorytop;
        
        Category__c category2nd = new Category__c(
            Brand__c='TestClass',
            ParentCategory__c=categorytop.Id,
            Category_Name__c='Master Category Name',
            Category_Description__c='Master Category Description'
        );
        insert category2nd;
        
         // Test
        String pbID = 'TestClass';


        System.runAs(testUsr) {  
            try {       
                List<Category__c> oneproduct = ShoppingCartController.getTopCategoryList(pbID);
            } catch (Exception e) { 
                   System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }
    
    @isTest static void TestGetProductsListbyCategoryCatch()
    {
        ID standardPBID = Test.getStandardPricebookId();

        Profile pr = [SELECT Id FROM Profile WHERE Name='Chatter Free User' LIMIT 1]; 
        User testUsr = new User(Alias = 'sysadm', Email='sysadmin@test.com', 
        EmailEncodingKey='UTF-8', LastName='TestSys', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = pr.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='123touchcrsysadmintest@123test.com');
        insert testUsr;
        
        Category__c category = new Category__c(
            Brand__c='Test',
            Category_Name__c='Test Category Name'
        );
        insert category;
        Category__c catname = [SELECT Name from Category__c WHERE Id = :category.Id LIMIT 1];
        
        Product2 prod1 = new Product2(
            ProductCode='ABC123TEST1',
            Name='Test product ShoppingCartHandler',
            Description='This is a test product for ShoppingCartHandler Testing',
            Category__c=category.Id,
            IsActive=true
        );
        insert prod1;
        Product2 prod2 = new Product2(
            ProductCode='ABC123TEST2',
            Name='Test product ShoppingCartHandler',
            Description='This is a test product for ShoppingCartHandler Testing',
            Category__c=category.Id,
            IsActive=true
        );
        insert prod2;
        Product2 prod3 = new Product2(
            ProductCode='ABC123TEST3',
            Name='Test product ShoppingCartHandler',
            Description='This is a test product for ShoppingCartHandler Testing',
            Category__c=category.Id,
            IsActive=true
        );
        insert prod3;
        
        Pricebook2 price = new Pricebook2(
            Name='ABC123TEST',
            Description='This is a test product for ShippingCartHandler Testing',
            IsActive=true
        );
        insert price;

        PricebookEntry pbentrystd1 = new PricebookEntry(
            UnitPrice=99.99,
            Product2Id=prod1.Id,
            Pricebook2Id=standardPBID,
            IsActive=true,
            UseStandardPrice=false
        );
        insert pbentrystd1;
        PricebookEntry pbentrystd2 = new PricebookEntry(
            UnitPrice=99.99,
            Product2Id=prod2.Id,
            Pricebook2Id=standardPBID,
            IsActive=true,
            UseStandardPrice=false
        );
        insert pbentrystd2;
        PricebookEntry pbentrystd3 = new PricebookEntry(
            UnitPrice=99.99,
            Product2Id=prod3.Id,
            Pricebook2Id=standardPBID,
            IsActive=true,
            UseStandardPrice=false
        );
        insert pbentrystd3;
        
        // Test
        String pbID = catname.Name;
        System.runAs(testUsr) {  
            try {           
                List<PricebookEntry> oneproduct = ShoppingCartController.getProductsListbyCategory(pbID);
            } catch (Exception e) { 
                   System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }    


   @isTest static void TestGetMyVariantImageByIdCatch()
    {

        Profile pr = [SELECT Id FROM Profile WHERE Name='Chatter Free User' LIMIT 1]; 
        User testUsr = new User(Alias = 'sysadm', Email='sysadmin@test.com', 
        EmailEncodingKey='UTF-8', LastName='TestSys', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = pr.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='123touchcrsysadmintest@123test.com');
        insert testUsr;
        

        Product_Variant__c var = new Product_Variant__c(
            Requires_Shipping__c = true,
            Taxable__c = true
        );
        insert var;
        Product_Image__c prodimage = new Product_Image__c(
            Product_Variant_Lookup__c=var.Id,
            Image_URL__c='https://test.google.com'
        );
        insert prodimage;
        // Test
        ID pbID = var.Id;
        System.runAs(testUsr) {  
            try {           
                String oneproduct = ShoppingCartController.getMyVariantImageById(pbID);
            } catch (Exception e) { 
                   System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }
    
    @isTest static void TestGetMyProductImageByIdCatch()
    {

        Profile pr = [SELECT Id FROM Profile WHERE Name='Chatter Free User' LIMIT 1]; 
        User testUsr = new User(Alias = 'sysadm', Email='sysadmin@test.com', 
        EmailEncodingKey='UTF-8', LastName='TestSys', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = pr.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='123touchcrsysadmintest@123test.com');
        insert testUsr;
        
        Product2 prod = new Product2(
            ProductCode='ABC123TEST',
            Name='Test product ShippingCartHandler',
            Description='This is a test product for ShippingCartHandler Testing',
            IsActive=true
        );
        insert prod;
        
        Product_Image__c prodimage = new Product_Image__c(
            Product_Lookup__c=prod.Id,
            Image_URL__c='https://test.google.com'
        );
        insert prodimage;
        
        // Test
        ID pbID = prod.Id;

        System.runAs(testUsr) {  
            try {           
                String oneproduct = ShoppingCartController.getMyProductImageById(pbID);
            } catch (Exception e) { 
                   System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }    

    @isTest static void TestGetMyProductByIdCatch()
    {

        Profile pr = [SELECT Id FROM Profile WHERE Name='Chatter Free User' LIMIT 1]; 
        User testUsr = new User(Alias = 'sysadm', Email='sysadmin@test.com', 
        EmailEncodingKey='UTF-8', LastName='TestSys', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = pr.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='123touchcrsysadmintest@123test.com');
        insert testUsr;
        
        ID standardPBID = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            ProductCode='ABC123TEST',
            Name='Test product ShippingCartHandler',
            Description='This is a test product for ShippingCartHandler Testing',
            IsActive=true
        );
        insert prod;
        
        Pricebook2 price = new Pricebook2(
            Name='ABC123TEST',
            Description='This is a test product for ShippingCartHandler Testing',
            IsActive=true
        );
        insert price;

        PricebookEntry pbentrystd = new PricebookEntry(
            UnitPrice=99.99,
            Product2Id=prod.Id,
            Pricebook2Id=standardPBID,
            IsActive=true,
            UseStandardPrice=false
        );
        insert pbentrystd;
        
        // Test
        ID pbID = prod.Id;
        System.runAs(testUsr) {  
            try {           
                PricebookEntry oneproduct = ShoppingCartController.getMyProductById(pbID);
            } catch (Exception e) { 
                   System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }
    
}