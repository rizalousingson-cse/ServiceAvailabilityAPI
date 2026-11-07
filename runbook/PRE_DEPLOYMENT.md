# Service Availability API: Pre-deployment Runbook

None.


## 2. Check Account data assumptions

- Confirm `Unique_Property_Reference_Number__c` is populated for Accounts that should be returned. It is a 15-character text field and is not configured as unique.
- Identify and resolve duplicate UPRNs before enabling integrations. The selector returns at most one matching Account and does not disambiguate duplicates.
- Confirm `UPRNExists__c`, `ReadyForSale__c`, and `AvailableForPreOrder__c` have the intended values.
- `ClientJourney__c` is numeric with scale zero; populated values must be convertible to an integer for the v2 response.

## 3. Check security and integration prerequisites

- Identify the intended Salesforce integration user or portal user and verify that the license supports the required API and Apex REST access.
- Plan to assign the integration principal the `API Profile`, or configure an equivalent profile for its license with API access, access to both REST classes, Account read access, and read access to all queried fields. The principal also needs record-level access to intended Accounts; the API query runs with sharing and in user mode.
- Review access to `Integration_Log_Error__c`. Exception logging inserts records in system mode, and request/response context may contain sensitive data. Limit who can read the logs.
- Decide which OAuth flow is appropriate for each caller before creating OAuth configuration. A public browser or mobile client must not contain a client secret.

## 4. Validate and test

Authorize the target org and run a validation-only deployment. Replace `<org-alias>` with the target org alias:

```bash
sf project deploy start \
  --dry-run \
  --source-dir force-app/main/default \
  --target-org <org-alias> \
  --test-level RunSpecifiedTests \
  --tests ServiceAvailabilityApiTest \
  --wait 30
```

Confirm that the deployment validates and `ServiceAvailabilityApiTest` passes. If production deployment policy requires broader test execution, follow that policy (for example, run the required local tests) rather than relying only on the specified test.

Investigate and resolve test failures, missing dependencies, permission issues, or metadata conflicts before proceeding with the production deployment.
