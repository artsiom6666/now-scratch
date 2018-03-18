public with sharing class EmailQualityScore {

    private static List<Account> aAccountToUpdate;
    private static List<Lead> aLeadToUpdate;

    /**
    * @description score quality of email on the basis of
    *               1.  Date email address first see
    *               2.  Valid syntax
    *               3.  Inbox receiving
    *               4.  Velocity
    *               5.  Popularity
    *               6.  Date last opened
    * @param  Map<String, List<SObject>>
    * @return Map<String, List<SObject>>
    */
    public static Map<String, List<SObject>> scoreEmailQuality(Map<String, List<SObject>> inputM) {

        List<SObject> aObject = inputM.get(TowerDataAPIClient.OBJECT_SECTION);
        List<Case> listCase = inputM.get(TowerDataAPIClient.CASE_SECTION);

        Case caseRecord;

        Integer iCountNumberObj = 0;
        if (aObject[0].getSObjectType() == Schema.Account.getSObjectType()) {
            List<Account> aAccount = (List<Account>) aObject;
            Date startDate = System.today();
            aAccountToUpdate = new List<Account>();

            for (Account objItem: aAccount) {
                //  Age of email address from today in months
                Integer ageOfEmailAdress = -1;
                // Difference between last opened and append date in month
                Integer differenceLastOpenedAndAppendDate = -1;
                // Fields store count state (good, ok, poor) for email of Account
                Integer goodCondition = 0;
                Integer okCondition = 0;
                Integer poorCondition = 0;

                Boolean flagException = false;

                iCountNumberObj++;

                //  Age of email address from today in months = today’s date - Date email address first seen
                if (objItem.EAM_Date_First_Seen__c == 'now') {
                    ageOfEmailAdress = 0;
                }
                else {
                    if (objItem.EAM_Date_First_Seen__c != null) {
                        try {
                            Date firstSeenDate = Date.valueOf(objItem.EAM_Date_First_Seen__c);
                            ageOfEmailAdress = firstSeenDate.monthsBetween(startDate);
                            if (startDate.day() > firstSeenDate.day()) ageOfEmailAdress++;
                        }
                        catch(Exception e) {
                            flagException = true;
                        }
                    }
                }
                // Difference between last opened and append date in month = today’s month/year - date last opened
                if (objItem.EAM_Month_Last_Opened__c != null) {
                    try{
                        Date lastOpenedDate = Date.valueOf(objItem.EAM_Month_Last_Opened__c + '-01');
                        differenceLastOpenedAndAppendDate = lastOpenedDate.monthsBetween(startDate);
                    }
                    catch(Exception e) {
                        flagException = true;
                    }
                }

                if (!flagException) {
                    /**
                    *   To determine status of e-mail on the basis of age email address
                    *   <= 2 months -> POOR
                    *   > 2 months AND < 13 months -> OK
                    *   >= 13 months -> GOOD
                    */
                    if (ageOfEmailAdress <= 2 && ageOfEmailAdress >= 0) {
                        poorCondition++;
                    }
                    else {
                        if (ageOfEmailAdress > 2 && ageOfEmailAdress < 13) {
                            okCondition++;
                        }
                        else {
                            if (ageOfEmailAdress >= 13) {
                                goodCondition++;
                            }
                        }
                    }

                    /**
                    *   To determine status of e-mail on the basis of velocity
                    *   0, 1 or 10 -> POOR
                    *   2 to 4 -> OK
                    *   5 to 9 -> GOOD
                    */
                    if (objItem.EAM_Velocity__c == 0 || objItem.EAM_Velocity__c == 1 || objItem.EAM_Velocity__c == 10) {
                        poorCondition++;
                    }
                    else {
                        if (objItem.EAM_Velocity__c >= 2 && objItem.EAM_Velocity__c <= 4) {
                            okCondition++;
                        }
                        else {
                            if (objItem.EAM_Velocity__c >= 5 && objItem.EAM_Velocity__c <= 9) {
                                goodCondition++;
                            }
                        }
                    }

                    /**
                    *   To determine status of e-mail on the basis of popularity
                    *   0, 1 or 10 -> POOR
                    *   2 to 4 -> OK
                    *   5 to 9 -> GOOD
                    */
                    if (objItem.EAM_Popularity__c == 0 || objItem.EAM_Popularity__c == 1 || objItem.EAM_Popularity__c == 10) {
                        poorCondition++;
                    }
                    else {
                        if (objItem.EAM_Popularity__c >= 2 && objItem.EAM_Popularity__c <= 4) {
                            okCondition++;
                        }
                        else {
                            if (objItem.EAM_Popularity__c >= 5 && objItem.EAM_Popularity__c <= 9) {
                                goodCondition++;
                            }
                        }
                    }

                    /**
                    *   To determine status of e-mail on the basis of difference between last opened and append date
                    *   > 3 -> POOR
                    *   > 2 AND <= 3 -> OK
                    *   > 3 -> POOR
                    */
                    if (differenceLastOpenedAndAppendDate > 3) {
                        poorCondition++;
                    }
                    else {
                        if (differenceLastOpenedAndAppendDate == 3) {
                            okCondition++;
                        }
                        else {
                            if (differenceLastOpenedAndAppendDate <= 2 && differenceLastOpenedAndAppendDate >= 0) {
                                goodCondition++;
                            }
                        }
                    }

                    //  4 POOR - *
                    if (poorCondition == 4) {
                        caseRecord = getExceptionEmailOrStar(ageOfEmailAdress, objItem, differenceLastOpenedAndAppendDate, '*');
                    }

                    //  1 to 3 POOR - **
                    if (poorCondition >= 1 && poorCondition <= 3) {
                        caseRecord = getExceptionEmailOrStar(ageOfEmailAdress, objItem, differenceLastOpenedAndAppendDate, '**');
                    }

                    //  4 OK - ***
                    if (okCondition == 4) {
                        caseRecord = getExceptionEmailOrStar(ageOfEmailAdress, objItem, differenceLastOpenedAndAppendDate, '***');
                    }

                    //  NO POOR AND 1 to 3 GOOD -   ****
                    if (poorCondition == 0 && (goodCondition >= 1 && goodCondition <= 3)) {
                        caseRecord = getExceptionEmailOrStar(ageOfEmailAdress, objItem, differenceLastOpenedAndAppendDate, '****');
                    }

                    //  4 GOOD - *****
                    if (goodCondition == 4) {
                        caseRecord = getExceptionEmailOrStar(ageOfEmailAdress, objItem, differenceLastOpenedAndAppendDate, '*****');
                    }
                }

                if (caseRecord != null) {
                    listCase.add(caseRecord);
                }

                //  If quality of email don`t definitely set the field Email Gold Stars - nothing
                if (aAccountToUpdate.size() < iCountNumberObj) {
                    objItem.Email_Quality__c = '';
                    aAccountToUpdate.add(objItem);
                }
            }

            inputM.put(TowerDataAPIClient.OBJECT_SECTION, aAccountToUpdate);
        }

        if (aObject[0].getSObjectType() == Schema.Lead.getSObjectType()) {
            List<Lead> aLead = (List<Lead>) aObject;
            Date startDate = System.today();
            aLeadToUpdate = new List<Lead>();

            for (Lead objItem: aLead) {
                //  Age of email address from today in months
                Integer ageOfEmailAdress = -1;
                // Difference between last opened and append date in month
                Integer differenceLastOpenedAndAppendDate = -1;
                // Fields store count state (good, ok, poor) for email of Account
                Integer goodCondition = 0;
                Integer okCondition = 0;
                Integer poorCondition = 0;
                Boolean flagException = false;

                iCountNumberObj++;

                //  Age of email address from today in months = today’s date - Date email address first seen
                if (objItem.EAM_Date_First_Seen__c == 'now') {
                    ageOfEmailAdress = 0;
                }
                else {
                    if (objItem.EAM_Date_First_Seen__c != null) {
                        try {
                            Date firstSeenDate = Date.valueOf(objItem.EAM_Date_First_Seen__c);
                            ageOfEmailAdress = firstSeenDate.monthsBetween(startDate);
                            if (startDate.day() > firstSeenDate.day()) ageOfEmailAdress++;
                        }
                        catch(Exception e) {
                            flagException = true;
                        }
                    }
                }

                // Difference between last opened and append date in month = today’s month/year - date last opened
                if (objItem.EAM_Month_Last_Opened__c != null) {
                    try {
                        Date lastOpenedDate = Date.valueOf(objItem.EAM_Month_Last_Opened__c + '-01');
                        differenceLastOpenedAndAppendDate = lastOpenedDate.monthsBetween(startDate);
                    }
                    catch(Exception e) {
                        flagException = true;
                    }
                }

                if (!flagException) {

                    /**
                    *   To determine status of e-mail on the basis of age email address
                    *   <= 2 months -> POOR
                    *   > 2 months AND < 13 months -> OK
                    *   >= 13 months -> GOOD
                    */
                    if (ageOfEmailAdress <= 2 && ageOfEmailAdress >= 0) {
                        poorCondition++;
                    }
                    else {
                        if (ageOfEmailAdress > 2 && ageOfEmailAdress < 13) {
                            okCondition++;
                        }
                        else {
                            if (ageOfEmailAdress >= 13) {
                                goodCondition++;
                            }
                        }
                    }

                    /**
                    *   To determine status of e-mail on the basis of velocity
                    *   0, 1 or 10 -> POOR
                    *   2 to 4 -> OK
                    *   5 to 9 -> GOOD
                    */
                    if (objItem.EAM_Velocity__c == 0 || objItem.EAM_Velocity__c == 1 || objItem.EAM_Velocity__c == 10) {
                        poorCondition++;
                    }
                    else {
                        if (objItem.EAM_Velocity__c >= 2 && objItem.EAM_Velocity__c <= 4) {
                            okCondition++;
                        }
                        else {
                            if (objItem.EAM_Velocity__c >= 5 && objItem.EAM_Velocity__c <= 9) {
                                goodCondition++;
                            }
                        }
                    }

                    /**
                    *   To determine status of e-mail on the basis of popularity
                    *   0, 1 or 10 -> POOR
                    *   2 to 4 -> OK
                    *   5 to 9 -> GOOD
                    */
                    if (objItem.EAM_Popularity__c == 0 || objItem.EAM_Popularity__c == 1 || objItem.EAM_Popularity__c == 10) {
                        poorCondition++;
                    }
                    else {
                        if (objItem.EAM_Popularity__c >= 2 && objItem.EAM_Popularity__c <= 4) {
                            okCondition++;
                        }
                        else {
                            if (objItem.EAM_Popularity__c >= 5 && objItem.EAM_Popularity__c <= 9) {
                                goodCondition++;
                            }
                        }
                    }

                    /**
                    *   To determine status of e-mail on the basis of difference between last opened and append date
                    *   > 3 -> POOR
                    *   > 2 AND <= 3 -> OK
                    *   > 3 -> POOR
                    */
                    if (differenceLastOpenedAndAppendDate > 3) {
                        poorCondition++;
                    }
                    else {
                        if (differenceLastOpenedAndAppendDate == 3) {
                            okCondition++;
                        }
                        else {
                            if (differenceLastOpenedAndAppendDate <= 2 && differenceLastOpenedAndAppendDate >= 0) {
                                goodCondition++;
                            }
                        }
                    }

                    //  4 POOR - *
                    if (poorCondition == 4) {
                        caseRecord = getExceptionEmailOrStar (ageOfEmailAdress, objItem, differenceLastOpenedAndAppendDate, '*');
                    }

                    //  1 to 3 POOR - **
                    if (poorCondition >= 1 && poorCondition <= 3) {
                        caseRecord = getExceptionEmailOrStar (ageOfEmailAdress, objItem, differenceLastOpenedAndAppendDate, '**');
                    }

                    //  4 OK - ***
                    if (okCondition == 4) {
                        caseRecord = getExceptionEmailOrStar (ageOfEmailAdress, objItem, differenceLastOpenedAndAppendDate, '***');
                    }

                    //  NO POOR AND 1 to 3 GOOD -   ****
                    if (poorCondition == 0 && (goodCondition >= 1 && goodCondition <= 3)) {
                        caseRecord = getExceptionEmailOrStar (ageOfEmailAdress, objItem, differenceLastOpenedAndAppendDate, '****');
                    }

                    //  4 GOOD - *****
                    if (goodCondition == 4) {
                        caseRecord = getExceptionEmailOrStar (ageOfEmailAdress, objItem, differenceLastOpenedAndAppendDate, '*****');
                    }
                }

                if (caseRecord != null) {
                    listCase.add(caseRecord);
                }

                //  If quality of email don`t definitely set the field Email Gold Stars - nothing
                if (aLeadToUpdate.size() < iCountNumberObj) {
                    objItem.Email_Quality__c = '';
                    aLeadToUpdate.add(objItem);
                }
            }
            inputM.put(TowerDataAPIClient.OBJECT_SECTION, aLeadToUpdate);
        }
        inputM.put(TowerDataAPIClient.CASE_SECTION, listCase);

        return inputM;
    }

    /**
    * @description to set gold stars or (red warning and to create case depending on
    *               1.  Date email address first see
    *               2.  Valid syntax
    *               3.  Inbox receiving
    *               4.  Velocity
    *               5.  Popularity
    *               6.  Date last opened)
    * @param    Integer - age of email adress
    *           SObject - Account or Lead
    *           Integer - difference between last opened and append date
    *           String  - star
    * @return   Case
    */
    private static Case getExceptionEmailOrStar(Integer ageOfEmailAdress, SObject objItemInput, Integer differenceLastOpenedAndAppendDate, String countStar) {

        Case caseRecordItem;

        if (objItemInput.getSObjectType() == Schema.Account.getSObjectType()) {
            Account objItem = (Account) objItemInput;

            //  to set red warning 'FRAUD WARNING' and to create case Fraud Investigate when
            //  age of email address from today <= 2 month AND (Velocity = null or 0 OR Popularity = null or 0 OR Last Open = null)
            if (ageOfEmailAdress <= 2 && ((objItem.EAM_Velocity__c == null || objItem.EAM_Velocity__c == 0) ||
                (objItem.EAM_Popularity__c == null || objItem.EAM_Popularity__c == 0) || objItem.EAM_Month_Last_Opened__c == null)) {
                objItem.Email_Quality__c = 'FW';
                caseRecordItem = new Case(
                    Subject = 'Fraud Investigate', AccountId = objItem.Id,
                    Status = 'New', Origin = 'Email'
                );
            }
            else {
                //  to set red warning 'POSSIBLE SPAM TRAP' and to create case Opt Out Email Address when
                //  Velocity > 8 AND Popularity > 8 AND Difference between last opened and append date > 6 months
                if (objItem.EAM_Velocity__c > 8 && objItem.EAM_Popularity__c > 8 && differenceLastOpenedAndAppendDate > 6) {
                    objItem.Email_Quality__c = 'ST';
                    caseRecordItem = new Case(
                        Subject = 'Opt Out Email Address', AccountId = objItem.Id,
                        Status = 'New', Origin = 'Email'
                    );
                }
                else {
                    //  to set red warning 'POSSIBLE BOUNCE ALERT' and to create case Opt Out Email Address when
                    //  Inbox receiving = NOK
                    if (!objItem.Email_Box_Valid__c) {
                        objItem.Email_Quality__c = 'BA';
                        caseRecordItem = new Case(
                            Subject = 'Opt Out Email Address', AccountId = objItem.Id,
                            Status = 'New', Origin = 'Email'
                        );
                    }
                    else {
                        //  to set red warning 'HARD BOUNCE ALERT' and to create case Correct Email Address when
                        //  Valid syntax = NOK
                        if (!objItem.Email_Valid__c) {
                            objItem.Email_Quality__c = 'HB';
                            caseRecordItem = new Case(
                                Subject = 'Correct Email Address', AccountId = objItem.Id,
                                Status = 'New', Origin = 'Email'
                            );
                        }
                        else {
                            objItem.Email_Quality__c = countStar;
                        }
                    }
                }
            }
            aAccountToUpdate.add(objItem);
        }

        if (objItemInput.getSObjectType() == Schema.Lead.getSObjectType()) {
            Lead objItem = (Lead) objItemInput;

            //  to set red warning 'FRAUD WARNING' and to create case Fraud Investigate when
            //  age of email address from today <= 2 month AND (Velocity = null or 0 OR Popularity = null or 0 OR Last Open = null)
            if (ageOfEmailAdress <= 2 && ((objItem.EAM_Velocity__c == null || objItem.EAM_Velocity__c == 0) ||
                (objItem.EAM_Popularity__c == null || objItem.EAM_Popularity__c == 0) || objItem.EAM_Month_Last_Opened__c == null)) {
                objItem.Email_Quality__c = 'FW';
                caseRecordItem = new Case(
                    Subject = 'Fraud Investigate', AccountId = objItem.Id,
                    Status = 'New', Origin = 'Email'
                );
            }
            else {
                //  to set red warning 'POSSIBLE SPAM TRAP' and to create case Opt Out Email Address when
                //  Velocity > 8 AND Popularity > 8 AND Difference between last opened and append date > 6 months
                if (objItem.EAM_Velocity__c > 8 && objItem.EAM_Popularity__c > 8 && differenceLastOpenedAndAppendDate > 6) {
                    objItem.Email_Quality__c = 'ST';
                    caseRecordItem = new Case(
                        Subject = 'Opt Out Email Address', AccountId = objItem.Id,
                        Status = 'New', Origin = 'Email'
                    );
                }
                else {
                    //  to set red warning 'POSSIBLE BOUNCE ALERT' and to create case Opt Out Email Address when
                    //  Inbox receiving = NOK
                    if (!objItem.Email_Box_Valid__c) {
                        objItem.Email_Quality__c = 'BA';
                        caseRecordItem = new Case(
                            Subject = 'Opt Out Email Address', AccountId = objItem.Id,
                            Status = 'New', Origin = 'Email'
                        );
                    }
                    else {
                        //  to set red warning 'HARD BOUNCE ALERT' and to create case Correct Email Address when
                        //  Valid syntax = NOK
                        if (!objItem.Email_Valid__c) {
                            objItem.Email_Quality__c = 'HB';
                            caseRecordItem = new Case(
                                Subject = 'Correct Email Address', AccountId = objItem.Id,
                                Status = 'New', Origin = 'Email'
                            );
                        }
                        else {
                            objItem.Email_Quality__c = countStar;
                        }
                    }
                }
            }
            aLeadToUpdate.add(objItem);
        }
        return caseRecordItem;
    }
}