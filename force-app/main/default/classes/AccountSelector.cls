/**
 * @description Retrieves Account records and service-availability fields by UPRN.
 * @author Riza Lou Singson
 * @date 2026-11-05
 */
public with sharing class AccountSelector {
    public static Account getByUprn(String uprn) {
        List<Account> accounts = [
            SELECT Id, UPRNExists__c, ReadyForSale__c, ClientJourney__c, AvailableForPreOrder__c
            FROM Account
            WHERE Unique_Property_Reference_Number__c = :uprn
            WITH USER_MODE
            LIMIT 1
        ];

        return accounts.isEmpty() ? null : accounts[0];
    }
}