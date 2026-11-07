# Service Availability API: Post-deployment Runbook

Complete these steps after the API metadata has been deployed successfully.

## 1. Create Salesforce User with the following details:
Name	Integration User
Email <admin/devops/designated email>
Username	serviceavailability.integration@orgfarm.com
User License	Salesforce
Profile	API Profile
Check Generate new password and notify user immediately.

## 2. Configure OAuth for external callers of Salesforce Web Service APIs
Note: Configuration Steps are based on the Winter '27 Org.
Slight variation of the steps if Salesforce version is different.

   ## 2.1. In Salesforce Setup, create/configure a Connected App or External Client App for the integration. Enable OAuth and select the OAuth scopes needed to call the Salesforce API. Please refer below steps

   - Setup -> App Manager -> New App dropdown New External Client App Manager and input below details:
   External Client App Name: Serviceavailability
   API Name: Serviceavailability
   Contact Email: <admin/devops/designated email>
   Distribution State: Local
   Description: Service availability API
   Leave all other inputs as blank

   - API (Enable OAuth Settings) -> check the Enable Oauth.

   Callback URL: https://salesforce.com

   OAuth Scopes -> Select OAuth Scopes
   Manage user data via APIs (api)
   Perform requests at any time (refresh_token, offline_access)

   - Flow Enablement -> check Enable Client Credentials Flow.
   Confirm Enablement of the Client Credential Flow.

   - All other configurations -> leave as is.

   - Create.

   - Edit Policies -> OAuth Policies
   OAuth Flows and External Client App Enhancements
   Click Enable Client Credentials Flow
   Run As (Username) -> serviceavailability.integration@orgfarm.com
   - Save.

## 3. Call and verify the API
Call the API using Postman. 
You may use the sample collection at "runbook/API Collections and Environment/ServiceAvailabilityAPI.postman_collection.json".
Please import "runbook/API Collections and Environment/ServiceApi environment.postman_environment.json" as well.