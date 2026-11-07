/**
 * @description Carries account service-availability data and response status or error details.
 * @author Riza Lou Singson
 * @date 2026-11-05
 */
public class ServiceAvailabilityResponseDTO {
    public Boolean UPRNExists { get; set; }
    public Boolean ReadyForSale { get; set; }
    public Integer ClientJourney { get; set; }
    public Boolean AvailableForPreOrder { get; set; }
    public String errorCode { get; set; }
    public String error { get; set; }
    public transient Integer statusCode { get; set; }
}