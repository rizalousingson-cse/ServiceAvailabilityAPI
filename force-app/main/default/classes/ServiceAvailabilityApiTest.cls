/**
 * @description Tests shared service-availability request handling and the v1 and v2 REST endpoints.
 * @author Riza Lou Singson
 * @date 2026-11-05
 */
@IsTest
private class ServiceAvailabilityApiTest {
    private static final String TEST_UPRN = 'PROP-1001';
    private static final String UNEXPECTED_ERROR_CODE = 'ERR-001';
    private static final String UPRN_REQUIRED_ERROR_CODE = 'ERR-002';
    private static final String ACCOUNT_NOT_FOUND_ERROR_CODE = 'ERR-003';
    private static final String ACCOUNT_NOT_FOUND_ERROR_MESSAGE = Label.NOT_EXISTING_UPRN;
    private static final String UNEXPECTED_ERROR_MESSAGE = 'An unexpected error occurred.';
    private static final String REST_RESPONSE_AND_DTO_REQUIRED_MESSAGE =
        'A REST response and response DTO are required.';
    private static final String TEST_INTERNAL_EXCEPTION_MESSAGE = 'Internal test detail.';
    private static final String LOGGER_EXCEPTION_REQUIRED_ERROR_MESSAGE =
        'An exception is required for error logging.';
    private static final String LOGGER_MESSAGE_REQUIRED_ERROR_MESSAGE =
        'An error message is required for error logging.';

    @TestSetup
    static void createAccount() {
        User apiUser = TestDataFactory.createApiUser();
        TestDataFactory.createServiceAvailabilityAccount(TEST_UPRN, apiUser);
    }

    @IsTest
    static void returnsAccountInformationFromSharedApi() {
        setUpRequest('v1', TEST_UPRN);

        Test.startTest();
        System.runAs(getApiUser()) {
            new TestableServiceAvailabilityApi().executeRequest();
        }
        Test.stopTest();

        assertSharedResponse();
    }

    @IsTest
    static void rejectsMissingUprnFromSharedApi() {
        setUpRequest('v1', null);

        Test.startTest();
        System.runAs(getApiUser()) {
            new TestableServiceAvailabilityApi().executeRequest();
        }
        Test.stopTest();

        assertErrorResponse(400, UPRN_REQUIRED_ERROR_CODE, Label.UPRN_REQUIRED);
    }

    @IsTest
    static void returnsNotFoundFromSharedApi() {
        setUpRequest('v1', 'UNKNOWN-1001');

        Test.startTest();
        System.runAs(getApiUser()) {
            new TestableServiceAvailabilityApi().executeRequest();
        }
        Test.stopTest();

        assertErrorResponse(404, ACCOUNT_NOT_FOUND_ERROR_CODE, ACCOUNT_NOT_FOUND_ERROR_MESSAGE);
    }

    @IsTest
    static void returnsGenericErrorForUnexpectedExceptions() {
        setUpRequest('v1', TEST_UPRN);

        Test.startTest();
        System.runAs(getApiUser()) {
            new TestableServiceAvailabilityApi().executeRequestWithUnexpectedError();
        }
        Test.stopTest();

        assertErrorResponse(500, UNEXPECTED_ERROR_CODE, UNEXPECTED_ERROR_MESSAGE);
    }

    @IsTest
    static void logsNullExceptionAsErrorRecord() {
        Test.startTest();
        IntegrationErrorLogger.logException(null);
        Test.stopTest();

        Integration_Log_Error__c errorLog = [
            SELECT Message__c
            FROM Integration_Log_Error__c
            LIMIT 1
        ];
        System.assertEquals(LOGGER_EXCEPTION_REQUIRED_ERROR_MESSAGE, errorLog.Message__c);
    }

    @IsTest
    static void logsBlankMessageAsErrorRecord() {
        Test.startTest();
        IntegrationErrorLogger.logError(' ', null, null);
        Test.stopTest();

        Integration_Log_Error__c errorLog = [
            SELECT Message__c
            FROM Integration_Log_Error__c
            LIMIT 1
        ];
        System.assertEquals(LOGGER_MESSAGE_REQUIRED_ERROR_MESSAGE, errorLog.Message__c);
    }

    @IsTest
    static void logsApiExceptionsAsJson() {
        setUpRequest('v1', TEST_UPRN);
        RestContext.response = null;

        Test.startTest();
        System.runAs(getApiUser()) {
            try {
                new TestableServiceAvailabilityApi().executeRequest();
                System.assert(false, 'Expected the missing REST response to be rejected.');
            } catch (IllegalArgumentException exceptionThrown) {
                System.assertEquals(
                    REST_RESPONSE_AND_DTO_REQUIRED_MESSAGE,
                    exceptionThrown.getMessage()
                );
            }
        }
        Test.stopTest();

        Integration_Log_Error__c errorLog = [
            SELECT Message__c, Request__c, Response__c
            FROM Integration_Log_Error__c
            LIMIT 1
        ];
        System.assert(
            errorLog.Message__c.contains('IllegalArgumentException'),
            'The exception type should be logged.'
        );
        System.assert(
            errorLog.Message__c.contains(REST_RESPONSE_AND_DTO_REQUIRED_MESSAGE),
            'The exception message should be logged.'
        );

        Map<String, Object> requestDetails = (Map<String, Object>) JSON.deserializeUntyped(
            errorLog.Request__c
        );
        System.assertEquals('/services/apexrest/availability/v1', requestDetails.get('requestUri'));
        Map<String, Object> parameters = (Map<String, Object>) requestDetails.get('parameters');
        System.assertEquals(TEST_UPRN, parameters.get('UPRN'));
        Map<String, Object> responseDetails = (Map<String, Object>) JSON.deserializeUntyped(
            errorLog.Response__c
        );
        System.assertEquals(null, responseDetails.get('statusCode'));
        System.assertEquals(null, responseDetails.get('responseBody'));
    }

    @IsTest
    static void v1EndpointDelegatesToSharedApi() {
        setUpRequest('v1', TEST_UPRN);

        Test.startTest();
        System.runAs(getApiUser()) {
            ServiceAvailabilityApiV1.getAccountInformation();
        }
        Test.stopTest();

        assertV1Response();
    }

    @IsTest
    static void v2EndpointDelegatesToSharedApi() {
        setUpRequest('v2', TEST_UPRN);

        Test.startTest();
        System.runAs(getApiUser()) {
            ServiceAvailabilityApiV2.getAccountInformation();
        }
        Test.stopTest();

        assertV2Response();
    }

    private static void setUpRequest(String version, String uprn) {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/availability/' + version;
        request.httpMethod = 'GET';
        if (uprn != null) {
            request.addParameter('UPRN', uprn);
        }

        RestContext.request = request;
        RestContext.response = new RestResponse();
    }

    private static User getApiUser() {
        return [
            SELECT Id
            FROM User
            WHERE Alias = 'api_test' AND Profile.Name = 'API Profile'
            LIMIT 1
        ];
    }

    private static void assertSharedResponse() {
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('application/json', RestContext.response.headers.get('Content-Type'));

        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(
            RestContext.response.responseBody.toString()
        );
        System.assertEquals(true, body.get('UPRNExists'));
        System.assertEquals(true, body.get('ReadyForSale'));
        System.assertEquals(3, body.get('ClientJourney'));
        System.assertEquals(true, body.get('AvailableForPreOrder'));
    }

    private static void assertV1Response() {
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('application/json', RestContext.response.headers.get('Content-Type'));

        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(
            RestContext.response.responseBody.toString()
        );
        System.assertEquals(2, body.size());
        System.assertEquals(true, body.get('UPRNExists'));
        System.assertEquals(true, body.get('ReadyForSale'));
    }

    private static void assertV2Response() {
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('application/json', RestContext.response.headers.get('Content-Type'));

        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(
            RestContext.response.responseBody.toString()
        );
        System.assertEquals(4, body.size());
        System.assertEquals(true, body.get('UPRNExists'));
        System.assertEquals(true, body.get('ReadyForSale'));
        System.assertEquals(3, body.get('ClientJourney'));
        System.assertEquals(true, body.get('AvailableForPreOrder'));
    }

    private static void assertErrorResponse(
        Integer expectedStatusCode,
        String expectedErrorCode,
        String expectedError
    ) {
        System.assertEquals(expectedStatusCode, RestContext.response.statusCode);
        System.assertEquals('application/json', RestContext.response.headers.get('Content-Type'));

        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(
            RestContext.response.responseBody.toString()
        );
        System.assertEquals(2, body.size());
        System.assertEquals(expectedErrorCode, body.get('errorCode'));
        System.assertEquals(expectedError, body.get('error'));
    }

    /**
     * @description Exposes protected shared request handling for direct unit testing.
     * @author Riza Lou Singson
     * @date 2026-11-05
     */
    private class TestableServiceAvailabilityApi extends ServiceAvailabilityApi {
        private void executeRequest() {
            handleRequest();
        }

        private void executeRequestWithUnexpectedError() {
            throwDuringSuccessResponse = true;
            handleRequest();
        }

        private Boolean throwDuringSuccessResponse = false;

        protected override Object buildSuccessResponse(ServiceAvailabilityResponseDTO responseDto) {
            if (throwDuringSuccessResponse) {
                throw new IllegalArgumentException(TEST_INTERNAL_EXCEPTION_MESSAGE);
            }
            return super.buildSuccessResponse(responseDto);
        }

    }
}