
## Service Availability API
The Service Availability API provides two GET endpoints that look up an Account by its unique property reference number (UPRN). Include the `UPRN` query parameter in either request:

```http
GET /services/apexrest/availability/v1?UPRN=1322131
GET /services/apexrest/availability/v2?UPRN=1322131
```

Both versions return JSON. Version 1 returns the `UPRNExists` and `ReadyForSale` fields. Version 2 returns those fields plus `ClientJourney` and `AvailableForPreOrder`.

If `UPRN` is missing or blank, the API returns HTTP 400. If no matching Account is found, it returns HTTP 404. Unexpected processing errors are logged and return HTTP 500.

### Request processing and classes

The shared request flow reads `UPRN` from the query string, passes it to the service layer, and serializes the result as JSON. The version-specific API class controls the success response shape.

| Class | Responsibility |
| --- | --- |
| `ServiceAvailabilityApi` | Abstract base class that handles shared request processing, JSON serialization, and error handling. |
| `ServiceAvailabilityApiV1` | Exposes the v1 GET endpoint and returns the response fields: `UPRNExists` and `ReadyForSale`. |
| `ServiceAvailabilityApiV2` | Exposes the v2 GET endpoint and returns the v1 fields plus `ClientJourney` and `AvailableForPreOrder`. |
| `ServiceAvailabilityApiService` | Validates the request, retrieves the Account, and maps its data or any handled error to the response DTO. |
| `AccountSelector` | Queries the Account by its unique property reference number and selects the fields required by the API. |
| `ServiceAvailabilityRequestDTO` | Carries request data, including the UPRN supplied by the caller. |
| `ServiceAvailabilityResponseDTO` | Carries the Account availability fields and response status or error details. |

### Assumptions and access
- The UPRN (Unique Property Reference Number) is assumed to be any alphanumeric characters of length 15.
- Each UPRN is expected to identify one relevant Account. The selector returns at most one matching record; uniqueness is not validated when Account records are inserted.
- Callers authenticate to Salesforce and need record access to the matching Account and read access to the queried fields. The Account query runs in user mode, and the API classes enforce sharing.
- Exceptions raised through the shared REST request handler are logged. Logger fields have finite capacities: messages are truncated to 255 characters, and serialized request and response data are truncated to 32,768 characters.
- An integration user is needed to set-up as pre-requisite prior to configuring the external app services. This integration user is assigned to an API Profile. This configuration is stated in detail in the post-deployment steps in the runbook folder.

### Deployment and integration runbooks
- [Post-deployment runbook](runbook/POST_DEPLOYMENT.md): OAuth setup, Integration user set-up, Steps to execute API callouts
