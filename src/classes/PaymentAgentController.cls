public with sharing class PaymentAgentController {

	public String namePaymentAgent { get; set; }
	public Boolean newAndEditPanel { get; set; }
	public List<SelectOption> allEntrypoints { get; set; }

	public Payment_Agents__c newAgent { get; set; }
	public List<Payment_Agents__c> activePayment { get; set; }
	public Map<String, Payment_Agents__c> allSettings { get; set; }

	public PaymentAgentController() {
		init();
		this.allEntrypoints = getEntrypoint();
	}

	//method returns available Payment Agents
	public static List<SelectOption> getEntrypoint() {

		Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();

		String endpoint = 'callout:PaymentEndpoint/supportedGateways?v=2';
		if (settingsMap.containsKey('Endpoint.ClientId') && settingsMap.containsKey('Endpoint.ClientSecret')) {
			endpoint += '&spApiKeyId=' + settingsMap.get('Endpoint.ClientId').Value__c;
			endpoint += '&spApiKeySecret=' + settingsMap.get('Endpoint.ClientSecret').Value__c;
		}

		HttpRequest req = new HttpRequest();

		req.setEndpoint(endpoint);
		req.setMethod('GET');
		Http http = new Http();

		List<SelectOption> result = new List<SelectOption>();

		try {
			HTTPResponse res = http.send(req);
			Map<String, String> availableGateways = (Map<String, String>) JSON.deserialize(res.getBody(), Map<String, String>.class);

			for (String gwName : availableGateways.keySet()) {
				result.add(new SelectOption(gwName, availableGateways.get(gwName)));
			}
		}
		catch(Exception ex) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Cannot get available Gateway Types.'));
		}
		return result;
	}

	public void init() {
		this.newAndEditPanel = false;
		this.allSettings = Payment_Agents__c.getAll();
		this.activePayment = new List<Payment_Agents__c>();
		for (Payment_Agents__c itemPaymentAgent : allSettings.values()) {
			this.activePayment.add(itemPaymentAgent);
		}
	}

	public void newPaymentAgent() {
		this.newAndEditPanel = true;
		this.newAgent = new Payment_Agents__c();
	}

	public void editPaymentAgent() {
		this.newAndEditPanel = true;
		this.newAgent = this.allSettings.get(namePaymentAgent);
	}

	public void savePaymentAgent() {
		try {
			if (getPaymentAgent(this.newAgent.Name) != null && getPaymentAgent(this.newAgent.Name).Id != this.newAgent.Id) {
				ApexPages.addmessage(
					new ApexPages.Message(ApexPages.Severity.WARNING, 'Payment Agent with same name already exist.')
				);
			} else {
				SFDCAccessController.UpsertWithoutSharing (
					this.newAgent,
					'PaymentAgentController.cls [savePaymentAgent]',
					new List<Schema.DescribeFieldResult> {
						Payment_Agents__c.Name.getDescribe(), Payment_Agents__c.Type__c.getDescribe(),
						Payment_Agents__c.Security_Key__c.getDescribe(), Payment_Agents__c.Merchant_ID__c.getDescribe(),
						Payment_Agents__c.Active__c.getDescribe()
					}
				);
				this.newAndEditPanel = false;
				init();
			}
		}
		catch (Exception e) { throw new SFDCAccessControlException(); }
	}

	public void deletedPaymentAgent() {
		this.newAgent = this.allSettings.get(namePaymentAgent);
		try {
			SFDCAccessController.DeleteWithoutSharing (
				this.newAgent,
				'PaymentAgentController.cls [deletedPaymentAgent]'
			);
		}
		catch (Exception e) { throw new SFDCAccessControlException(); }
		init();
	}

	//method returns name of the Payment Agent
	public static String idToNameParamAgents(String idPaymentAgent) {
		Map<String, Payment_Agents__c> allSettings = Payment_Agents__c.getAll();
		for (Payment_Agents__c sObj : allSettings.values()) {
			if (sObj.Active__c == true && sObj.Id == Id.valueOf(idPaymentAgent)) {
				return sObj.Name;
			}
		}
		return null;
	}

	//method returns Payment Agent
	public static Payment_Agents__c getPaymentAgent(String namePaymentAgent) {
		Map<String, Payment_Agents__c> allSettings = Payment_Agents__c.getAll();
		for (Payment_Agents__c sObj : allSettings.values()) {
			if (sObj.Name == namePaymentAgent) {
				return sObj;
			}
		}
		return null;
	}

}