Feature: OAuth 2.0 Token Generation

  Background:
    * url Access_Token_URL
    * form field grant_type = 'client_credentials'
    * form field client_id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    * form field client_any = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    * form field scope = "https://sqlonfhir-anything.fhir.azurehealthcareapis.com/.default"


  Scenario: Creating the New Token Everytime when the Test Runs
    Given path "oauth2/v2.0/token"
    And header accept = "application/json"
    When method post
    Then status 200
    * def accessToken = response.access_token
    * print "This is the Newly Created Access Token" , accessToken
