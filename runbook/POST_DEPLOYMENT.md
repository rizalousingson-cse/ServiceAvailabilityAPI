# Service Availability API: Post-deployment Runbook

Complete these steps after the API metadata has been deployed successfully.

## 1. Create Salesforce User with the following details:
-Name:	Integration User <br/>
-Email: <admin/devops/designated email> <br/>
-Username:	serviceavailability.integration@orgfarm.com <br/>
-User: License	Salesforce <br/>
-Profile: API Profile <br/>
-Check Generate new password and notify user immediately. <br/>

## 2. Configure OAuth for external callers of Salesforce Web Service APIs
-Note: Configuration Steps are based on the Winter '27 Org.
-Slight variation of the steps if Salesforce version is different.

   ## 2.1. In Salesforce Setup, create/configure a Connected App or External Client App for the integration. Enable OAuth and select the OAuth scopes needed to call the Salesforce API. Please refer below steps

   - Go to Setup -> App Manager -> New App dropdown New External Client App Manager and input below details: <br/>
   External Client App Name: Serviceavailability <br/>
   API Name: Serviceavailability <br/>
   Contact Email: <admin/devops/designated email> <br/>
   Distribution State: Local <br/>
   Description: Service availability API <br/>
   Leave all other inputs as blank <br/>

   - API (Enable OAuth Settings) -> check the Enable Oauth.

   Callback URL: https://salesforce.com

   OAuth Scopes -> Select OAuth Scopes <br/>
   Manage user data via APIs (api) <br/>
   Perform requests at any time (refresh_token, offline_access) <br/>

   - Flow Enablement -> check Enable Client Credentials Flow. <br/>
   Confirm Enablement of the Client Credential Flow.

   - All other configurations -> leave as is.

   - Create.

   - Edit Policies -> OAuth Policies
   OAuth Flows and External Client App Enhancements
   Click Enable Client Credentials Flow
   Run As (Username) -> serviceavailability.integration@orgfarm.com
   - Save.

## 3. Call and verify the API
Call the API using Postman or other API tool. 
You may use the sample collection at [API Collections](runbook/API Collections and Environment).
Please import ([API Collections](runbook/API Collections and Environment) as well.
