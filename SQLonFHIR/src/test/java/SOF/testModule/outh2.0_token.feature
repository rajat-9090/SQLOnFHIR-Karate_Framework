Feature: OAuth 2.0 Token Generation

  Background:
    * url Access_Token_URL
    * form field grant_type = 'client_credentials'
    * form field client_id = "4a72cffb-8191-418d-926f-50b1463e26ef"
    * form field client_secret = "rob8Q~2McZ4PSJjERYqTU8f0-UpeWEJGSXzH5b9H"
    * form field scope = "https://sqlonfhir-sqlonfhir.fhir.azurehealthcareapis.com/.default"


  Scenario: Creating the New Token Everytime when the Test Runs
    Given path "oauth2/v2.0/token"
    And header accept = "application/json"
    When method post
    Then status 200
    * def accessToken = response.access_token
    * print "This is the Newly Created Access Token" , accessToken
