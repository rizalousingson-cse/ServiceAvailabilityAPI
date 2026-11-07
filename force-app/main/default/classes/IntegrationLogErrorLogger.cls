/**
 * @description Writes exception details and JSON request/response context to Integration Log Error records.
 * @author Riza Lou Singson
 * @date 2026-11-05
 */
public without sharing class IntegrationErrorLogger {
    private static final Integer MESSAGE_MAX_LENGTH = 255;
    private static final Integer JSON_MAX_LENGTH = 32768;
    private static final String EXCEPTION_REQUIRED_ERROR_MESSAGE =
        'An exception is required for error logging.';
    private static final String ERROR_MESSAGE_REQUIRED_ERROR_MESSAGE =
        'An error message is required for error logging.';

    public static void logException(Exception exceptionThrown) {
        String message = exceptionThrown == null
            ? EXCEPTION_REQUIRED_ERROR_MESSAGE
            : exceptionThrown.getTypeName() + ': ' + exceptionThrown.getMessage();
        insertErrorLog(message, getRequestContext(), getResponseContext());
    }

    public static void logError(String message, Object request, Object response) {
        if (String.isBlank(message)) {
            message = ERROR_MESSAGE_REQUIRED_ERROR_MESSAGE;
        }

        insertErrorLog(message, request, response);
    }

    private static void insertErrorLog(String message, Object request, Object response) {
        Integration_Log_Error__c errorLog = new Integration_Log_Error__c(
            Message__c = truncate(message, MESSAGE_MAX_LENGTH),
            Request__c = serializeForLog(request),
            Response__c = serializeForLog(response)
        );
        Database.insert(errorLog, false, AccessLevel.SYSTEM_MODE);
    }

    private static Map<String, Object> getRequestContext() {
        Map<String, Object> requestContext = new Map<String, Object>();
        RestRequest request = RestContext.request;
        if (request != null) {
            requestContext.put('requestUri', request.requestURI);
            requestContext.put('httpMethod', request.httpMethod);
            requestContext.put('parameters', request.params);
            requestContext.put(
                'requestBody',
                request.requestBody == null ? null : request.requestBody.toString()
            );
        }
        return requestContext;
    }

    private static Map<String, Object> getResponseContext() {
        Map<String, Object> responseContext = new Map<String, Object>();
        RestResponse response = RestContext.response;
        if (response != null) {
            responseContext.put('statusCode', response.statusCode);
            responseContext.put(
                'responseBody',
                response.responseBody == null ? null : response.responseBody.toString()
            );
        }
        return responseContext;
    }

    private static String serializeForLog(Object value) {
        return truncate(JSON.serialize(value), JSON_MAX_LENGTH);
    }

    private static String truncate(String value, Integer maxLength) {
        return value.length() > maxLength ? value.left(maxLength) : value;
    }
}