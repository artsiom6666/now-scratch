public class NOWNode {
	@AuraEnabled
	public Boolean isCategory {
		get {
			return (isCategory == null) ? false : isCategory;
		}
		set; }
	@AuraEnabled
	public Boolean isProduct {
		get {
			return (isProduct == null) ? false : isProduct;
		}
		set; }
	@AuraEnabled
	public Boolean isCoolCube {
		get {
			return (isCoolCube == null) ? false : isCoolCube;
		}
		set; }
	@AuraEnabled
	public String toplevel { get; set; }
	@AuraEnabled
	public String name { get; set; }
	@AuraEnabled
	public String id { get; set; }
	@AuraEnabled
	public String productid { get; set; }
	@AuraEnabled
	public String parentid { get; set; }
	@AuraEnabled
	public Integer level { get; set; }
	@AuraEnabled
	public Decimal price { get; set; }
	@AuraEnabled
	public Decimal productPrice { get; set; }
	@AuraEnabled
	public Decimal gst { get; set; }
	@AuraEnabled
	public Integer units { get; set; }
	@AuraEnabled
	public Integer volume { get; set; }
	@AuraEnabled
	public Integer count {
		get {
			return (count != null) ? count : 0;
		}
		set; }

	public NOWNode() {}
}