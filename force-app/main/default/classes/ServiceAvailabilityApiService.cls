/**
 * @description Validates service-availability requests and builds responses from matching Account records.
 * @author Riza Lou Singson
 * @date 2026-11-05
 */
public with sharing class ServiceAvailabilityApiService {
    private static final String UPRN_REQUIRED_ERROR_CODE = 'ERR-002';
    private static final String ACCOUNT_NOT_FOUND_ERROR_CODE = 'ERR-003';
    private static final String ACCOUNT_NOT_FOUND_ERROR_MESSAGE = Label.NOT_EXISTING_UPRN;

    public static ServiceAvailabilityResponseDTO getAccountInformation(ServiceAvailabilityRequestDTO requestDto) {
        ServiceAvailabilityResponseDTO responseDto = new ServiceAvailabilityResponseDTO();
        String uprn = requestDto == null ? null : requestDto.uprn;

        if (String.isBlank(uprn)) {
            responseDto.errorCode = UPRN_REQUIRED_ERROR_CODE;
            responseDto.error = Label.UPRN_REQUIRED;
            responseDto.statusCode = 400;
            return responseDto;
        }

        Account accountRecord = AccountSelector.getByUprn(uprn);
        if (accountRecord == null) {
            responseDto.errorCode = ACCOUNT_NOT_FOUND_ERROR_CODE;
            responseDto.error = ACCOUNT_NOT_FOUND_ERROR_MESSAGE;
            responseDto.statusCode = 404;
            return responseDto;
        }

        responseDto.UPRNExists = accountRecord.UPRNExists__c;
        responseDto.ReadyForSale = accountRecord.ReadyForSale__c;
        responseDto.ClientJourney = accountRecord.ClientJourney__c == null
            ? null
            : Integer.valueOf(String.valueOf(accountRecord.ClientJourney__c));
        responseDto.AvailableForPreOrder = accountRecord.AvailableForPreOrder__c;
        responseDto.statusCode = 200;
        return responseDto;
    }
}