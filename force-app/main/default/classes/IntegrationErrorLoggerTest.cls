/**
 * @description Tests error-message persistence and request/response serialization in the integration logger.
 * @author Riza Lou Singson
 * @date 2026-11-08
 */
@IsTest
private class IntegrationErrorLoggerTest {
    private static final String EXCEPTION_REQUIRED_ERROR_MESSAGE =
        'An exception is required for error logging.';
    private static final String ERROR_MESSAGE_REQUIRED_ERROR_MESSAGE =
        'An error message is required for error logging.';
    private static final String TEST_EXCEPTION_MESSAGE = 'Logger test exception.';

    @IsTest
    static void logsExceptionAndRestContext() {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/availability/v1';
        request.httpMethod = 'POST';
        request.addParameter('UPRN', 'PROP-1001');
        RestContext.request = request;

        RestResponse response = new RestResponse();
        response.statusCode = 500;
        response.responseBody = Blob.valueOf('{"error":"failure"}');
        RestContext.response = response;

        Test.startTest();
        IntegrationErrorLogger.logException(
            new IllegalArgumentException(TEST_EXCEPTION_MESSAGE)
        );
        Test.stopTest();

        Integration_Log_Error__c errorLog = [
            SELECT Message__c, Request__c, Response__c
            FROM Integration_Log_Error__c
            LIMIT 1
        ];
        System.assert(errorLog.Message__c.contains('IllegalArgumentException'));
        System.assert(errorLog.Message__c.contains(TEST_EXCEPTION_MESSAGE));

        Map<String, Object> requestDetails = (Map<String, Object>) JSON.deserializeUntyped(
            errorLog.Request__c
        );
        System.assertEquals('/services/apexrest/availability/v1', requestDetails.get('requestUri'));
        System.assertEquals('POST', requestDetails.get('httpMethod'));
        Map<String, Object> parameters = (Map<String, Object>) requestDetails.get('parameters');
        System.assertEquals('PROP-1001', parameters.get('UPRN'));

        Map<String, Object> responseDetails = (Map<String, Object>) JSON.deserializeUntyped(
            errorLog.Response__c
        );
        System.assertEquals(500, responseDetails.get('statusCode'));
        System.assertEquals('{"error":"failure"}', responseDetails.get('responseBody'));
    }

    @IsTest
    static void logsNullExceptionFallbackMessage() {
        IntegrationErrorLogger.logException(null);

        Integration_Log_Error__c errorLog = [
            SELECT Message__c
            FROM Integration_Log_Error__c
            LIMIT 1
        ];
        System.assertEquals(EXCEPTION_REQUIRED_ERROR_MESSAGE, errorLog.Message__c);
    }

    @IsTest
    static void logsBlankMessageFallback() {
        IntegrationErrorLogger.logError(' ', null, null);

        Integration_Log_Error__c errorLog = [
            SELECT Message__c, Request__c, Response__c
            FROM Integration_Log_Error__c
            LIMIT 1
        ];
        System.assertEquals(ERROR_MESSAGE_REQUIRED_ERROR_MESSAGE, errorLog.Message__c);
        System.assertEquals('null', errorLog.Request__c);
        System.assertEquals('null', errorLog.Response__c);
    }

    @IsTest
    static void serializesProvidedRequestAndResponse() {
        Map<String, Object> requestData = new Map<String, Object>{
            'requestId' => 'REQ-1001'
        };
        Map<String, Object> responseData = new Map<String, Object>{
            'statusCode' => 404
        };

        IntegrationErrorLogger.logError('Account not found.', requestData, responseData);

        Integration_Log_Error__c errorLog = [
            SELECT Message__c, Request__c, Response__c
            FROM Integration_Log_Error__c
            LIMIT 1
        ];
        System.assertEquals('Account not found.', errorLog.Message__c);
        Map<String, Object> serializedRequest = (Map<String, Object>) JSON.deserializeUntyped(
            errorLog.Request__c
        );
        Map<String, Object> serializedResponse = (Map<String, Object>) JSON.deserializeUntyped(
            errorLog.Response__c
        );
        System.assertEquals('REQ-1001', serializedRequest.get('requestId'));
        System.assertEquals(404, serializedResponse.get('statusCode'));
    }
}