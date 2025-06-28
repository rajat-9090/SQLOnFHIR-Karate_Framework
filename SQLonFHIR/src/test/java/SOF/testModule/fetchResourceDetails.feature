Feature: Fetching Resource Details from Excel


  @withCount
  Scenario: Read Resource_Name with Count and Call the Resource Feature to Pass the Data from Excel

    * def path = karate.toAbsolutePath("classpath:SOF/testData/ResourceswithCount.xlsx")
    * def resourceDetails = Java.type("SOF.utilities.Excelutility")
    * def allDetails = new resourceDetails(path)
    * def excelDetails = allDetails.readResourceDataWithCount()
    * print "Excel Details with Resource_Name and Count: ", excelDetails
    # Loop over each row and call Resource.feature
    * eval karate.forEach(excelDetails, function(row) {karate.call('classpath:SOF/testModule/Resource.feature@whenwithCount', { resourceName: row.resourceName, resourceCount: row.resourceCount });})



  @withFHIRID
  Scenario: Read Resource_Name with FHIR_ID and Call the Resource Feature to Pass the Data from Excel

    * def path = karate.toAbsolutePath("classpath:SOF/testData/ResourceswithFHIRIDs.xlsx")
    * def resourceDetails = Java.type("SOF.utilities.Excelutility")
    * def allDetails = new resourceDetails(path)
    * def excelDetails = allDetails.readResourceDataWithFHIRID()
    * print "Excel Details with Resource_Name and FHIR_ID: ", excelDetails
    # Loop over each row and call Resource.feature
    * eval karate.forEach(excelDetails, function(row) {karate.call('classpath:SOF/testModule/Resource.feature@whenwithFHIRID', { resourceName: row.resourceName, fhirID: row.fhirID });})