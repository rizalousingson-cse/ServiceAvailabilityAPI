/**
 * @description Exposes the v1 service-availability REST endpoint and its legacy response fields.
 * @author Riza Lou Singson
 * @date 2026-11-05
 */
@RestResource(urlMapping='/availability/v1')
global with sharing class ServiceAvailabilityApiV1 extends ServiceAvailabilityApi {
    @HttpGet
    global static void getAccountInformation() {
        new ServiceAvailabilityApiV1().handleRequest();
    }

    protected override Object buildSuccessResponse(ServiceAvailabilityResponseDTO responseDto) {
        return new Map<String, Object>{
            'UPRNExists' => responseDto.UPRNExists,
            'ReadyForSale' => responseDto.ReadyForSale
        };
    }
}