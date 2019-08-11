public with sharing class GenerateQuoteOrderForm_Controller {
    
    public zqu__Quote__c quote {get; set;}
    public List<ProductWrapper> products {get; set;}
    public Decimal totalFee {get; set;}
    
    public GenerateQuoteOrderForm_Controller(ApexPages.StandardController stdController) {
        quote = (zqu__Quote__c) stdController.getRecord();

        fetchProducts();
    }
    
    public void fetchProducts() {
        products = new List<ProductWrapper>();
        totalFee = 0;

        ProductWrapper tmp;
        for (zqu__QuoteRatePlanCharge__c ratePlanCharge: [
            SELECT
                Id, SKU__c, Product_Name__c, zqu__UOM__c, Start_Date__c, End_Date__c, zqu__Quantity__c,
                zqu__ListPrice__c
            FROM
                zqu__QuoteRatePlanCharge__c
            WHERE
                zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c = :quote.Id
        ]) {
            tmp = new ProductWrapper(ratePlanCharge);
            
            products.add(tmp);
            totalFee += tmp.fee;
        }
    }
    
    public String getPrintView() {
        return '<!--[if gte mso 9]>' +
            '<xml>' +
            '<w:WordDocument>' +
            '<w:View>Print</w:View>' +
            '<w:Zoom>100</w:Zoom>' +
            '<w:DoNotOptimizeForBrowser/>' +
            '</w:WordDocument>' +
            '</xml>' +
            '<![endif]>';
    }
    
    class ProductWrapper {
        public String sku {get; set;}
        public String name {get; set;}
        public String uom {get; set;}
        public String period {get; set;}
        public Decimal quantity {get; set;}
        public Decimal price {get; set;}
        public Decimal fee {get; set;}
        
        public ProductWrapper(zqu__QuoteRatePlanCharge__c ratePlanCharge) {
            sku = ratePlanCharge.SKU__c;
            name = ratePlanCharge.Product_Name__c;
            uom = ratePlanCharge.zqu__UOM__c;
            period = ratePlanCharge.Start_Date__c + ' - <br/>' + ratePlanCharge.End_Date__c;
            quantity = ratePlanCharge.zqu__Quantity__c;
            price = ratePlanCharge.zqu__ListPrice__c;
            fee = quantity * price;
        }
    }
}