global with sharing class CustomerReceiptController {

    // inputs from a component
    global String transId { get; set; }
    global String defaultImgUrl { get; set; }

    // outputs
    global List<OrderItemWr> paidOrderItemsWr { get; set; }

    global String getPrepareData() {
        try {
            Id.valueOf(transId);
        }
        catch (Exception e) {
            return '';
        }

        // get all OI for Order related to this transaction
        List<OrderItem__c> oitems = [
            SELECT Id, Quantity__c, Product_Price__c,
                Total_Price__c, Product_Variant__c,
                Product_Variant__r.Name, Product__c,
                Product__r.Name, Product__r.DisplayUrl, Product__r.Description
            FROM OrderItem__c
            WHERE Order__c IN
                (SELECT Order__c
                FROM Order_Transaction__c
                WHERE Id =: transId)
            ORDER BY Product__r.Name ASC
        ];
        // TODO
        // currency

        // hold ids for Product OR Product Variant to get related Images
        Set<String> pvOrPrIdSet = new Set<String>();

        // OI loop to collect PV or PR or Both ids
        for (OrderItem__c oitem : oitems) {
            if (oitem.Product_Variant__c != null) {
                pvOrPrIdSet.add(oitem.Product_Variant__c);
            }
            if (oitem.Product__c != null) {
                pvOrPrIdSet.add(oitem.Product__c);
            }
        }
        // get related images to PR or PV from OI
        List<Product_Image__c> pImages = [
            SELECT Image_URL__c, Product_Alt_Tag__c, Product_Image_Description__c,
                Product_Variant_Lookup__c, Product_Lookup__c
            FROM Product_Image__c
            WHERE Image_URL__c != NULL
            AND
                (Product_Variant_Lookup__c IN :pvOrPrIdSet
                OR
                Product_Lookup__c IN :pvOrPrIdSet)
            ORDER BY Id ASC

        ];
        // PR id or PV id to image map, used only 1st image if multiple images present
        Map<String, Product_Image__c> pvOrPrIdToImageMap = new Map<String, Product_Image__c>();
        for (Product_Image__c pImage : pImages) {
            // image related to PV
            if (pImage.Product_Variant_Lookup__c != null) {
                // filter images and get only 1st
                if (!pvOrPrIdToImageMap.containsKey(pImage.Product_Variant_Lookup__c)) {
                    pvOrPrIdToImageMap.put(pImage.Product_Variant_Lookup__c, pImage);
                }
            }
            if (pImage.Product_Lookup__c != null) {
                // filter images and get only 1st
                if (!pvOrPrIdToImageMap.containsKey(pImage.Product_Lookup__c)) {
                    pvOrPrIdToImageMap.put(pImage.Product_Lookup__c, pImage);
                }
            }
        }
        // Main output list wrapper
        paidOrderItemsWr = new List<OrderItemWr>();
        // OI loop main
        for (OrderItem__c oitem : oitems) {
            OrderItemWr oiwr = new OrderItemWr();
            oiwr.item = oitem;
            // first try to use image from product itself
            if (oitem.Product__r.DisplayUrl != null) {
                oiwr.imgUrl = oitem.Product__r.DisplayUrl;
                oiwr.imgAlt = oitem.Product__r.Description;
                paidOrderItemsWr.add(oiwr);
                continue;
            }
            // try to use image from PV
            if (oitem.Product_Variant__c != null) {
                // PV has an image?
                if (pvOrPrIdToImageMap.containsKey(oitem.Product_Variant__c)) {
                    oiwr.imgUrl = pvOrPrIdToImageMap.get(oitem.Product_Variant__c).Image_URL__c;
                    oiwr.imgAlt = pvOrPrIdToImageMap.get(oitem.Product_Variant__c).Product_Alt_Tag__c;
                    paidOrderItemsWr.add(oiwr);
                    // has an image skip the rest
                    continue;
                }
            }
            //try to use image from PR
            if (oitem.Product__c != null) {
                // PR has an image?
                if (pvOrPrIdToImageMap.containsKey(oitem.Product__c)) {
                    oiwr.imgUrl = pvOrPrIdToImageMap.get(oitem.Product__c).Image_URL__c;
                    oiwr.imgAlt = pvOrPrIdToImageMap.get(oitem.Product__c).Product_Alt_Tag__c;
                    paidOrderItemsWr.add(oiwr);
                    // has an image skip the rest
                    continue;
                }
            }
            // getting here means no image was found, default should be used
            oiwr.imgUrl = defaultImgUrl;
            paidOrderItemsWr.add(oiwr);
        }

        return '';
    }

    global class OrderItemWr {
        global OrderItem__c item { get; set; }
        global String imgUrl { get; set; }
        global String imgAlt { get; set; }
        global OrderItemWr() {}
    }
}