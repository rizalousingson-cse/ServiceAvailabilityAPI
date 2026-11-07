/**
 * @description Creates shared test records for service-availability API tests.
 * @author Riza Lou Singson
 * @date 2026-11-08
 */
@IsTest
public class TestDataFactory {
    public static User createApiUser() {
        Profile apiProfile = [
            SELECT Id
            FROM Profile
            WHERE Name = 'API Profile'
            LIMIT 1
        ];
        User apiUser = new User(
            Alias = 'api_test',
            Email = 'service-availability-api@example.test',
            EmailEncodingKey = 'UTF-8',
            LastName = 'API Profile Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = apiProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'service-availability-api-' + DateTime.now().getTime() + '@example.test'
        );
        insert apiUser;
        return apiUser;
    }

    public static Account createServiceAvailabilityAccount(String uprn, User apiUser) {
        Account accountRecord = new Account(
            Name = 'Eligibility Test Account',
            Unique_Property_Reference_Number__c = uprn,
            UPRNExists__c = true,
            ReadyForSale__c = true,
            ClientJourney__c = 3,
            AvailableForPreOrder__c = true
        );
        System.runAs(apiUser) {
            insert accountRecord;
        }
        return accountRecord;
    }
}