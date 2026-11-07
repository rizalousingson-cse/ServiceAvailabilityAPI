/**
 * @description Exposes the v2 service-availability REST endpoint with the expanded account response.
 * @author Riza Lou Singson
 * @date 2026-11-05
 */
@RestResource(urlMapping='/availability/v2')
global with sharing class ServiceAvailabilityApiV2 extends ServiceAvailabilityApi {
    @HttpGet
    global static void getAccountInformation() {
        new ServiceAvailabilityApiV2().handleRequest();
    }

    protected override Object buildSuccessResponse(ServiceAvailabilityResponseDTO responseDto) {
        return new Map<String, Object>{
            'UPRNExists' => responseDto.UPRNExists,
            'ReadyForSale' => responseDto.ReadyForSale,
            'ClientJourney' => responseDto.ClientJourney,
            'AvailableForPreOrder' => responseDto.AvailableForPreOrder
        };
    }
}