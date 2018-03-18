//TODO: Customize the username and profile. Also check that the username doesn't already exist and
//possibly ensure there are enough org licenses to create a user. Must be 80 characters or less.

global class GoogleLogIn implements Auth.RegistrationHandler {

  private static final String ORG_SUFFIX = '.touchcr-api.org';
  private static final String DEFAULT_ACCOUNTNAME = 'Customers';
  private static final String EXTERNAL_USER_PROFILE = 'Customer';
  private static final String INTERNAL_USER_PROFILE = 'Standard User'; 
  private static final String RECORD_TYPE = 'Customer_Account'; 

  global boolean canCreateUser(Auth.UserData data) {
    System.debug('canCreateUser was called for ' + (data != null ? data.email : 'null'));
    System.debug(data);
    System.debug(data.attributeMap);
    Boolean retVal = (data != null 
            && data.email != null
            && data.lastName != null
            && data.firstName != null);
    System.debug('data.username='+data.username);
    System.debug('data.fullName='+data.fullName);
    System.debug('data.email='+data.email);
    System.debug('data.lastName='+data.lastName);
    System.debug('data.firstName='+data.firstName);
    System.debug('data.provider='+data.provider);
    System.debug(retVal);
    return retVal;
  }

  global User createUser(Id portalId, Auth.UserData data){
    if(!canCreateUser(data)) {
      return null;
    }
    if(AccountExists(data)) {
      System.debug('Account Exists');
      return null;
    }
    if(data.attributeMap.containsKey('sfdc_networkid')) {
      System.debug('Registering Community user: ' + data.email);
      Id contactId;
      Id accountId;
      User u;
      try {

        accountId = createAccount(data);
        System.debug('Created account: '+ accountId);
        contactId = createContact(data, accountId);
        System.debug('Created contact: '+ contactId);
        Boolean isExternalUserProfile = true;
        List<Profile> profiles = [SELECT Id FROM profile WHERE name=:EXTERNAL_USER_PROFILE];
        if (profiles.size() == 0 && Test.isRunningTest()) { 
          profiles = [SELECT Id FROM profile WHERE name= 'System Administrator'];
          isExternalUserProfile = false;
        }
        Profile p = profiles[0];

        System.debug('Found profile: '+ p);
        u = createUser(data,p);
        If (isExternalUserProfile) {
          u.contactId = contactId;
          }

      } catch (Exception e) {
        System.debug(e);
      }
      return u;
    } else {
        // This is not a community, so create a regular standard user
        // User u = new User();
        // Profile p = [SELECT Id FROM profile WHERE name='Standard User'];
        // //TODO: Customize the username. Also check that the username doesn't already exist and
        // //possibly ensure there are enough org licenses to create a user. Must be 80 characters
        // //or less.
        // u.username = data.username + '@myorg.com';
        // u.email = data.email;
        // u.lastName = data.lastName;
        // u.firstName = data.firstName;
        // String alias = data.username;
        // //Alias must be 8 characters or less
        // if(alias.length() > 8) {
        //     alias = alias.substring(0, 8);
        // }
        // u.alias = alias;
        // u.languagelocalekey = UserInfo.getLocale();
        // u.localesidkey = UserInfo.getLocale();
        // u.emailEncodingKey = 'UTF-8';
        // u.timeZoneSidKey = 'America/Los_Angeles';
        // u.profileId = p.Id;
        // return u;
        //This is not a community, so we Assign an internal profile
        // Profile p = [SELECT Id FROM profile WHERE name=:INTERNAL_USER_PROFILE];
        // System.debug('Found profile: '+ p);
        // Keeping it modular, we initialize the user in another method
        // User u = createUser(data,p);
        // return u;
        return null;
    }
  }
  global void updateUser(Id userId, Id portalId, Auth.UserData data){
    System.debug('Update User called for: ' + data.email);
    User u = new User(id=userId);
    System.debug(u);
    u.lastName = data.lastName;
    u.firstName = data.firstName;
    //u.email = data.email;
    //String alias = data.username;
    //Alias must be 8 characters or less
    //if(alias.length() > 8) {
      //alias = alias.substring(0, 8);
      //}
    //u.alias = alias;
    update(u);
  }
  private Id createAccount(Auth.UserData data){
    RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName=:RECORD_TYPE];
    System.debug('Found RecordType: '+ recordType);
    System.debug('Create PeronAccount called for: ' + data.email);
    Account account = new Account();
    account.LastName = data.lastName;
    account.FirstName = data.firstName;
    account.PersonEmail = data.email;
    account.RecordTypeId = recordType.Id;
    insert account;
    System.debug('Account created for ' + data.email + ' id=' + account.id);
    return account.id; 
  }
  private Id createContact(Auth.UserData data, Id accountId){
    Contact contact = [SELECT Id FROM Contact WHERE AccountId =: accountId];
    System.debug('Find contact ' + contact);
    // System.debug('Create Contact called for: ' + data.email);
    // System.debug('Account Id ' + accountId);
    // Contact contact = new Contact();
    // contact.LastName = data.lastName;
    // contact.FirstName = data.firstName;
    // contact.Email = data.email;
    // contact.AccountId = accountId;
    // if (data.attributemap.get('accountId') != null){
    //   contact.accountId = data.attributemap.get('accountId');
    //   } else {
    //     List<Account> accounts = [select Id from Account where Name =:DEFAULT_ACCOUNTNAME];
    //     System.debug('Found account: ' + accounts);
    //     contact.accountId = accounts[0].Id;
    //     }
    // insert contact;
    // System.debug('Contact created for ' + data.email + ' id=' + contact.id);
    return contact.id; 
  }
  private User createUser(Auth.UserData data, Profile p) {
        System.debug('Create User called for: ' + data.email);
        User u = new User();
        u.username = data.email;
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        String alias = data.firstName + data.lastName;
        if(alias.length() > 8) {
            alias = alias.substring(0, 8);
        }
        u.alias = alias;
        u.languagelocalekey = UserInfo.getLocale();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.profileId = p.Id;
        return u;
}
  private Boolean AccountExists(Auth.UserData data) {
    Boolean bool = true;
    try {
      List<Account> account_list = [SELECT Id FROM account WHERE PersonEmail =: data.email];
      if (account_list.isEmpty())
        bool = false;
    } catch (Exception e) {
      System.debug(e);
    }
    System.debug(bool);
    return bool;
  }
}