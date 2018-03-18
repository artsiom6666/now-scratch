public with sharing class PaymentGateway {
/*
	Input keys:
	PaymentAgentType => (String) Type of Payment Agent
	Method => (String) 'Authorize', 'Charge', 'Refund', 'Void'

	CreditCard => Map<String,Object>
		CardNumber => (String)
		CardCCV => (String)
		CardExpirationMonth => (String)
		CardExpirationYear => (String)
		Profile => (String)
		CardId => (String)

	Return keys:
		'transactionId' (string): A unique identifier of the transaction.
		'_original': The original response from the gateway.
		'customer' : The Account Id created in Stripe.
		'brand' : Card Type.
		'cardId' : The Card Id created in Stripe.
		'last4' : Last 4 digits of credit card.
		'Status': Unified status of the transaction across all agents.
		'Message': Unified message of the transaction across all agents.
*/
	public static Map<String, Object> doPayment (Map<String,Object> params) {

		if (params.containsKey('Method')) {
			Map<String, TouchCR_Settings__c> settingsMap = TouchCR_Settings__c.getAll();
			//getting PaymentAgent parameters
			Map<String, String> setParameters = params.containsKey('AgentParameters') ? (Map<String, String>)params.get('AgentParameters') : new Map<String, String>();
			Map<String, String> setAddress = params.containsKey('Address') ? (Map<String, String>)params.get('Address') : new Map<String, String>();
			PaymentWrapper wrapperObj;
			PageReference pr = new PageReference((String)PAYMENT_AGENTS.get((String)params.get('Method')));

			HttpRequest req = new HttpRequest();
			req.setMethod('GET');
			req.setTimeout(120000);
			Http binding = new Http();
			HttpResponse res;

			//Use credentials Stormpath
			if (settingsMap.containsKey('Endpoint.TokenType') && settingsMap.containsKey('Endpoint.TokenPart1') && settingsMap.containsKey('Endpoint.TokenPart2')) {
				String token = settingsMap.get('Endpoint.TokenPart1').Value__c + settingsMap.get('Endpoint.TokenPart2').Value__c;
				req.setHeader('Authorization', settingsMap.get('Endpoint.TokenType').Value__c.capitalize() + ' ' + token);
			}

			if (settingsMap.containsKey('Endpoint.ClientId') && settingsMap.containsKey('Endpoint.ClientSecret')) {
				setParameters.put('spApiKeyId', settingsMap.get('Endpoint.ClientId').Value__c);
				setParameters.put('spApiKeySecret', settingsMap.get('Endpoint.ClientSecret').Value__c);
			}

			setParameters.put('v', '2');
			setParameters.put('amount', String.valueOf(params.get('Amount')));
			setParameters.put('currency', String.valueOf(params.get('CurrencyIso')));

			String customerIp = params.containsKey('customerIp') ? String.valueOf(params.get('customerIp')) : null;
			if (String.isNotBlank(customerIp)) {
				pr.getParameters().put('customerIp', customerIp);
			}

			if (params.get('Method') == 'Refund') {
				pr.getParameters().put('refundApplicationFee', String.valueOf(params.get('refundApplicationFee')));
				pr.getParameters().put('reverseTransfer', String.valueOf(params.get('reverseTransfer')));
			}

			if (params.get('Method') == 'Authorization') {
				pr.getParameters().put('isAuthorize', 'true');
			}

			if (params.containsKey('CreditCard')) {
				//Map contains the credit data
				Map<String,Object> creditCard = (Map<String,Object>)params.get('CreditCard');
				for (String sObj : CREDIT_CARD.keySet()) {
					if (String.isNotBlank((String)creditCard.get(sObj))) {
						setParameters.put((String)CREDIT_CARD.get(sObj), (String)creditCard.get(sObj));
					}
				}
			}

			for (String param : setAddress.keySet()){
				if (String.isNotBlank((String)setAddress.get(param))) {
					pr.getParameters().put(param, setAddress.get(param));
				}
			}

			//Id Transaction on Gateway side
			if (params.containsKey('PaymentTransaction')) {
				setParameters.put('transactionId', (String)params.get('PaymentTransaction'));
			}

			if (params.containsKey('applicationFee') && params.containsKey('destination')) {
				setParameters.put('applicationFee', (String)params.get('applicationFee'));
				setParameters.put('destination', (String)params.get('destination'));
			}

			//Temporarily for Moneris
			if ((String)setParameters.get('gateway') == 'Moneris') {
				setParameters.put('country', 'CA');
			}

			for (String param : setParameters.keySet()){
				pr.getParameters().put(param, setParameters.get(param));
			}

			req.setEndpoint('callout:PaymentEndpoint' + pr.getUrl());
			res = binding.send(req);

			//Updated TouchCR Security
			if (res.getStatus() == 'OK') {
				wrapperObj = (PaymentWrapper)JSON.deserialize(res.getBody(), PaymentWrapper.class);

				//get all params from Payment Wrapper
				Map<String, Object> result = getResult(wrapperObj);
				params.putAll(result);

				if (params.get('Method') == 'Refund') {
					//for Refund, the transaction will be negative
					params.put('Amount', (Decimal)params.get('Amount') * -1);
				}

				params.put('StatusCode', res.getStatusCode());
				params.put('Original', res.getBody());

				//update token
				if (res.getHeader('Access-Token') != null) {
					TouchCRHelper.setAuthCredentinals(res.getHeader('Access-Token'));
				}

			} else {
				params.put('Status', 'Error');
				params.put('Endpoint', String.valueOf(req.getEndpoint()));
				params.put('Body', String.valueOf(res.getBody()));
				params.put('StatusCode', String.valueOf(res.getStatusCode()));
				try {
					// message and status
					wrapperObj = (PaymentWrapper)JSON.deserialize(res.getBody(), PaymentWrapper.class);
					params.put('Message', 'Error transaction ' + res.getStatus());
					params.put('Description', wrapperObj.error);
				} catch (Exception e) {
					params.put('Message', 'Error transaction Service Unavailable');
					params.put('Description', 'Error Transaction Service Unavailable');
				}
			}
		}
		else {
			// message and status
			params.put('Status', 'Error');
			params.put('Message', 'Invalid parameters');
		}
		return params;
	}

	public static Map<String, Object> getResult(PaymentWrapper pw) {
		return new Map<String, Object>{
			'PaymentTransaction' => pw.transactionId,
			'Brand' => pw.brand,
			'CardId' => pw.cardId,
			'Customer' => pw.customer,
			'Last4' => pw.last4,
			'Funding' => pw.funding,
			'Captured' => pw.captured,
			'Status' => 'Approved',
			'Message' => 'Your transaction has been approved.'
		};
	}

	//Map for names of the fields credit card
	// TEMPORARILY ADDED connect fields to CreditCard Object
	public static final Map<String, Object> CREDIT_CARD = new Map<String, Object>{
		'CardNumber' => 'creditCardNumber',
		'CardExpirationMonth' => 'expirationMonth',
		'CardExpirationYear' => 'expirationYear',
		'CardCCV' => 'cvv2',
		'Profile' => 'customer',
		'CardId' => 'cardId',
		'SwipeData' => 'swipeData'
	};

	public static final Map<String, Object> PAYMENT_AGENTS = new Map<String, Object>{
		'Authorization' => '/submitTransaction',
		'Charge' => '/submitTransaction',
		'Refund' => '/refund',
		'Void' => '/void'
	};

	public class PaymentWrapper {
		public String transactionId { get; set; }
		public String customer { get; set; }
		public String cardId { get; set; }
		public String brand { get; set; }
		public String last4 { get; set; }
		public String funding { get; set; }
		public String captured { get; set; }
		public String error { get; set; }
	}
}