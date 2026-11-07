### Deployment and integration runbooks
- [Pre-deployment runbook](runbook/PRE_DEPLOYMENT.md): pre-requisite steps prior to deployment release
- [Post-deployment runbook](runbook/POST_DEPLOYMENT.md): OAuth setup, Integration user set-up, Steps to execute API callouts

## Service Availability API
The Service Availability API provides two GET endpoints that look up an Account by its unique property reference number (UPRN). Pass the `UPRN` query parameter to either version:

```http
GET /services/apexrest/availability/v1?UPRN=PROP-1001
GET /services/apexrest/availability/v2?UPRN=PROP-1001
```

### Assumptions on Service Availability API
- Each UPRN identifies one relevant Account. No validation upon insertion of the records in the Account but the selector returns at most one matching record.
- Callers authenticate to Salesforce and have record access to the matching Account and read access to the queried fields. The Account query runs in user mode with sharing enforced.
- Exceptions raised through the shared REST request handler are logged. Logger fields have finite capacities: messages are truncated to 255 characters, and serialized request and response data are truncated to 32,768 characters.
