/**
 * @description Provides shared request handling and JSON response behavior for versioned service-availability REST endpoints.
 * @author Riza Lou Singson
 * @date 2026-11-05
 */
public abstract with sharing class ServiceAvailabilityApi {
    private static final String UNEXPECTED_ERROR_CODE = 'ERR-001';
    private static final String UNEXPECTED_ERROR_MESSAGE = 'An unexpected error occurred.';
    private static final String REST_RESPONSE_AND_DTO_REQUIRED_MESSAGE =
        'A REST response and response DTO are required.';

    protected ServiceAvailabilityRequestDTO buildRequestDto() {
        ServiceAvailabilityRequestDTO requestDto = new ServiceAvailabilityRequestDTO();
        requestDto.uprn = RestContext.request != null ? RestContext.request.params.get('UPRN') : null;
        return requestDto;
    }

    protected void handleRequest() {
        try {
            ServiceAvailabilityResponseDTO responseDto =
                ServiceAvailabilityApiService.getAccountInformation(buildRequestDto());
            writeJson(RestContext.response, responseDto);
        } catch (Exception exceptionThrown) {
            IntegrationErrorLogger.logException(exceptionThrown);
            writeErrorResponse(
                RestContext.response,
                500,
                UNEXPECTED_ERROR_CODE,
                UNEXPECTED_ERROR_MESSAGE
            );
        }
    }

    protected void writeJson(RestResponse response, ServiceAvailabilityResponseDTO responseDto) {
        if (responseDto == null) {
            throw new IllegalArgumentException(REST_RESPONSE_AND_DTO_REQUIRED_MESSAGE);
        }

        if (response == null) {
            throw new IllegalArgumentException(REST_RESPONSE_AND_DTO_REQUIRED_MESSAGE);
        }

        response.addHeader('Content-Type', 'application/json');
        response.statusCode = responseDto.statusCode;
        if (responseDto.error != null) {
            writeErrorResponse(
                response,
                responseDto.statusCode,
                responseDto.errorCode,
                responseDto.error
            );
            return;
        }

        response.responseBody = Blob.valueOf(JSON.serialize(buildSuccessResponse(responseDto)));
    }

    protected void writeErrorResponse(
        RestResponse response,
        Integer statusCode,
        String errorCode,
        String errorMessage
    ) {
        if (response == null) {
            throw new IllegalArgumentException(REST_RESPONSE_AND_DTO_REQUIRED_MESSAGE);
        }

        response.addHeader('Content-Type', 'application/json');
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf(
            JSON.serialize(
                new Map<String, String>{
                    'errorCode' => errorCode,
                    'error' => errorMessage
                }
            )
        );
    }

    protected virtual Object buildSuccessResponse(ServiceAvailabilityResponseDTO responseDto) {
        return responseDto;
    }
}