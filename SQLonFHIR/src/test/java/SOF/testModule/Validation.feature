Feature: Performing the Validation Process

  Background:
    * url host
    #    * def resourceName = "Observation"
    #    * def dbresourceName = "codeableconcept"
    #    * def fhirID = "00ded5ad-c20c-2c91-6a67-9d3273f0f755"
    #----------------------Reading all the DataBase Details from the json File-------------
    * def config = read("classpath:SOF/testData/sof_mysql_details.json")
    #----------------------Calling DbUtil File for the DB connection-----------------------
    * def DB_Util = Java.type("SOF.utilities.DbUtils")
    * def sof_Table = new DB_Util(config)
    * def failedAttributes = []
    #----------------------Reading patient Attribute Paths from the json File-------------
    # def attributes = read("classpath:SOF/testData/CommonResources/Codeableconcept_Attribute_Path.json")
    #--------------------Calling this Feature File to generate the Outh 2.0 Token---------------
    * def newToken = call read("classpath:SOF/testModule/outh2.0_token.feature")
    #---------------------Storing Details to the Excel Sheet------------------
    * def path = karate.toAbsolutePath("AllValidationResult/" + resourceName + "_Validation_Result.xlsx")
    * def fetch_Excel = Java.type("SOF.utilities.Excelutility")
    * def Validate_Data = new fetch_Excel(path)
    #--------------Calling TimeFormat File for Adding TimeStamp Format In the Excel sheet----------------
    * def timestamp = Java.type("SOF.utilities.TimeFormat")
    * def formattedTime = timestamp.getFormattedTimestamp()
    #----------------------Reading rewrite Attribute Paths from the json File-------------
    * def rewriteMap = read("classpath:SOF/testData/rewrite-Map.json")
    * print rewriteMap
  #--------------------Calling this Feature File to generate the Outh 2.0 Token---------------
  #* def newToken = call read("classpath:SOF/testModule/outh2.0_token.feature")
  #------------------All the DB Data are unavailable so I am using manually placed DB Details-----------------
  #* def DB_Details = read("classpath:SOF/testData/DummyDB_Data.json")
  #* print DB_Details
  #------------------Testing Purposes I am adding this Dummy JSON---------------------
  #    * def JSON_Details = read("classpath:SOF/testData/DummyJSON_Data.json")
  #    * print JSON_Details







  #  @checking
  #  @ignore
  #  Scenario: Fetching Indivisual Patient Details using FHIR ID
  #    Given path resourceName, fhirID
  #    And header ApiKey = ApiKeyValue
  #    And header Authorization = "Bearer " + newToken.accessToken
  #    Then method get
  #    When status 200
  #    * def patientData = response
  #    * print patientData
  #    #------------------Fetching Patient Details from DB using FHIR ID--------------------
  #    # Step 1: Set a default null value
  #    * def DB_Details = sof_Table.readRow("SELECT * FROM demo." + dbresourceName + " WHERE id = '" + fhirID + "'")
  #    * if (!DB_Details) karate.appendTo(failedFHIRIDs, fhirID)
  #    * print DB_Details
  #    * print DB_Details.meta_lastupdated
  #---------------Normalize Specific Fields of "DB_Details"------------------------
  #    * string meta_extension_string_fixed = karate.eval(karate.get("DB_Details.meta_extension").replace("/'/g'", '"'))
  #    * print meta_extension_string_fixed
  #    * def meta_extension_array = karate.fromString(meta_extension_string_fixed)
  #    * print meta_extension_array
  #    * def transform = function(item) { return karate.fromString(item); }
  #    * def meta_extension_json = karate.map(meta_extension_array, transform)
  #    * print meta_extension_json
  #    * def communication_array = karate.fromString(DB_Details.communication)
  #    * print communication_array
  #    #    #----------------------Extract Values from API Response---------------------------------
  #    * def field_meta = $.id
  #    * print field_meta
  #    #    #    #----------------Assertion to compare API Respose with DB Responce-----------------------
  #    * match field_meta == DB_Details.id


  @validationWithCount
  @ignore
  Scenario: Validating API Data with DB Data
    Given path resourceName, fhirID
    And header ApiKey = ApiKeyValue
    And header Authorization = "Bearer " + newToken.accessToken
    Then method get
    When status 200
    * def resourceData = response
    * print resourceData
    * print dbresourceName
    * print fhirID

    #------------------Fetching Resource Details from DB using FHIR ID--------------------
    * def DB_Details = sof_Table.readRows("SELECT * FROM demo." + dbresourceName + " WHERE id = '" + fhirID + "'")
    * if (!DB_Details) karate.appendTo(failedFHIRIDs, fhirID)
    * print DB_Details
    * karate.log('Type of DB Value:', karate.typeOf(DB_Details))
    * print "These are the Attribute Results for this Run", attributes

    #--------------This safeJsonPath Fuction is for Common Resources-------------------
    * def safeJsonPath =
      """
      function (json, path) {
        var keys = path.replace('$.', '').replace('[*]', '.*').split('.');
        var result = json;

        for (var i = 0; i < keys.length; i++) {
          var key = keys[i];

          if (key === '*') {
            if (!Array.isArray(result)) {
              karate.log('WARNING: Expected an array but found:', karate.typeOf(result));
              return null;
            }

            var collected = [];
            for (var j = 0; j < result.length; j++) {
              var sub = result[j];
            // recursively extract remaining path from each sub-object
              var remaining = keys.slice(i + 1).join('.');
              var val = safeJsonPath(sub, '$.' + remaining);
              if (val !== null && typeof val !== 'undefined') {
                if (Array.isArray(val)) {
                  collected = collected.concat(val);
                } else {
                  collected.push(val);
                }
              }
            }

            return collected.length > 0 ? collected : null;
          }

          if (typeof result !== 'object' || result === null || result[key] === undefined) {
            karate.log('WARNING: Attribute not found at step [' + key + '] in path:', path);
            return null;
          }

          result = result[key];
        }

        if (Array.isArray(result)) {
          if (result.length === 0) {
            karate.log('WARNING: Empty list for path:', path);
            return null;
          } else if (result.length === 1) {
            karate.log('auto-flatten 1-element lists');
            return result[0];
          }
        }


        karate.log("*********************************************************************************");
        return result;
      }
      """

    #--------------This safeJsonPathMain Fuction is for Common Resources-------------------

    * def safeJsonPathMain =
      """
      function (json, path) {
        var keys = path.replace('$.', '').replace('[*]', '.*').split('.');
        var result = json;

        for (var i = 0; i < keys.length; i++) {
          if (keys[i] === "*") {  // Handle array wildcard
            if (!Array.isArray(result)) {
              karate.log('WARNING: Expected an array but found:', karate.typeOf(result));
              return null;
            }
            var extractedValues = [];
            for (var j = 0; j < result.length; j++) {
              if (result[j][keys[i + 1]] !== undefined) {
                extractedValues.push(result[j][keys[i + 1]]);
              }
            }
            if (extractedValues.length === 0) {
              karate.log('WARNING: No matching array elements found for:', path);
              return null;
            }
            result = extractedValues;
            i++;  // Skip next key since it's already processed
          } else {
            if (result[keys[i]] === undefined) {
              karate.log('WARNING: Attribute not found in API response:', path);
              return null;
            }
            result = result[keys[i]];
          }
        }

        if (karate.typeOf(result) === 'list' && result.length == 0) {
          karate.log('WARNING: Empty list detected for:', path);
          return null;
        }
        karate.log("*******************************************************************************");
      //karate.log("safeJsonPath Outcome for " + path + ":", result);
        return result;
      }
      """

    #--------------This Function is to Normalize the Stucture of DB Date According to the API Data--------------
    * def normalizeDate =
      """
      function(value) {
        if (value == null) {
          return null;  // Return NULL if the value is null
        }

      // Convert to string only if it's not already a string
        if(karate.typeOf(value) === 'string'){
          return value;
        } else {
          var strValue = value + ""
          if (strValue.match("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}")) {
            return strValue.split('T')[0];  // Extract YYYY-MM-DD
          }
        }

        return strValue;  // Return the converted string value
      }
      """

    #----------------This Fuction is to pointout attribute focus to selected section of the FHIR Data----------------
    * def detectFHIRType =
      """
      function(fieldName) {
        var map = {
          "category": "CodeableConcept",
          "code": "CodeableConcept",
          "interpretation": "CodeableConcept",
          "bodySite": "CodeableConcept",
          "priority": "CodeableConcept",
          "class": "CodeableConcept"
        };
        return map[fieldName] || null;
      }
      """

    #---------------This Fuction to Resolve the Mismatch between common Resource Attributes and DB Colums--------------
    * def resolveApiDBMismatch =
      """
      function(attrPath, dbRow, patientData) {

        karate.log('START: resolveApiDBMismatch');
        karate.log('attrPath:', attrPath);
        karate.log('dbRow.record_id:', dbRow.record_id);
        karate.log('dbRow.seq_no:', dbRow.seq_no);
      // These are the few attributes will skip the deep check and compare directly with Main Data
        var contextOnlyAttrs = ["$.id", "$.record_id", "$.field_name", "$.seq_no"];

        if (contextOnlyAttrs.indexOf(attrPath) === -1) {

          karate.log('Attribute Enters Deep Search Section');

        // If attribute not found inside full FHIR payload then look inside array sections
          var arrayFields = ["identifier", "category", "code", "interpretation", "bodySite", "subject", "priority", "class"];

        // Mapping from DB lowercase field names to actual FHIR JSON field names
          var fieldMap = {
            "bodysite": "bodySite"
          };

          var apiValue = null;
        //var matchedFromArray = false;

          for (var i = 0; i < arrayFields.length; i++) {
            var field = arrayFields[i];
            var normalizedField = field.toLowerCase();
            var actualField = fieldMap[normalizedField] || field;
            karate.log('Checking field:', actualField);

            if (dbRow.record_id && dbRow.record_id.toLowerCase().indexOf(normalizedField + "_") > -1) {
              karate.log('record_id matched field:', actualField);
              var fhirList = safeJsonPath(patientData, "$." + actualField);
              karate.log('fhirList details:', fhirList);

              if (!fhirList || fhirList.length === 0) {
                karate.log('fhirList is empty or null for field:', actualField);
                continue;
              }

            // This section will handle those scenario when we receive "fhirList" as Object
              if (!Array.isArray(fhirList)) {
                karate.log('Wrapping single object into array for field:', actualField);
                fhirList = [fhirList];
              }

              var matchIndex = null;
              for (var j = 0; j < fhirList.length; j++) {
                if (typeof dbRow.seq_no !== 'undefined' && j === dbRow.seq_no) {
                  matchIndex = j;
                  karate.log('Matched seq_no:', j);
                  break;
                }
              }

              if (matchIndex !== null) {
                var contextNode = fhirList[matchIndex];
                karate.log('ContextNode details:', contextNode);

              // Handling the Complex attribute mismatching
                var type = detectFHIRType(actualField);
                karate.log('Detected FHIR type:', type);
                var rewrittenPath = rewriteMap[type] ? rewriteMap[type][attrPath] : null;
                karate.log('Using path:', rewrittenPath ? rewrittenPath : attrPath);

                apiValue = rewrittenPath ? safeJsonPath(contextNode, rewrittenPath) : safeJsonPath(contextNode, attrPath);
                karate.log('Response of Attribute goes though Selected Data:', apiValue);
              //matchedFromArray = true;
                break;
              }
              karate.log('Data is not avaialble for this field:', actualField);

            }
          }

        // Final fallback if not matched via array logic
        } else {
          apiValue = safeJsonPath(patientData, attrPath);
          karate.log('Response of Attribute goes though Full Data:- ', apiValue);
          return apiValue;
        }

      // Returning Deep Search Result Here
        if (Array.isArray(apiValue) && apiValue.length === 1) {
          karate.log("Forcefully getting first value to convert List to String")
          apiValue = apiValue[0];
          return apiValue;
        }
      //karate.log('Response of Attribute goes though Selected Data:- ', apiValue);
        return apiValue;
      }
      """


    #---------------This is the Main Function where the Validate will happen between API Data and DB Data-------------
    * def validateAttribute =
      """
      function (attrPath, dbRow) {
        var commonResources = ['codeableconcept', 'reference', 'identifier'];
        var apiValue;

        if (commonResources.indexOf(dbresourceName) > -1) {
        // For nested/common resources
          karate.log("Found Common Resource and attribute will go through resolveApiDBMismatch function")
          apiValue = resolveApiDBMismatch(attrPath, dbRow, resourceData);
        } else {
        // For main flat resources (e.g., Patient, Observation)
          karate.log("Found Main Resource and attribute will go through validation directly")
          apiValue = safeJsonPathMain(resourceData, attrPath);
        }
        var dbKey = attrPath.replace("$.", "").replace("[*]", "").replace(".", "_"); // Convert JSONPath to DB key format
        var requiredDBKey = karate.lowerCase(dbKey)
        var dbValue = dbRow[requiredDBKey]; // Get value from DB JSON

        dbValue = normalizeDate(dbValue);


        karate.log('--------------------Validation Starts-------------------------');
        karate.log('Checking Attribute:', attrPath);
        karate.log('Extracted API Value:', apiValue);
        karate.log('Extracted DB Key:', requiredDBKey);
        karate.log('Extracted DB Value:', dbValue);
        karate.log('Type of DB Value:', karate.typeOf(dbValue));
        karate.log('Type of API Value:', karate.typeOf(apiValue));

      //If API attribute is missing, DB should also be NULL
        if (apiValue === null) {
          karate.log('NULL CHECK: API is missing this attribute, checking if DB is also NULL');
          var isNullCheck = (dbValue == null);
          var result = {
            "Attribute": attrPath,
            "API_Value": apiValue,
            "DB_Value": dbValue,
            "Match": isNullCheck
          };
          if (!isNullCheck) {
            failedAttributes.push({ "Attribute": attrPath, "Expected": "null", "Found": dbValue });
            karate.log('MISMATCH: Expected NULL but found in DB:', dbValue);
          } else {
            karate.log('NULL CHECK PASSED: Both API and DB have NULL for:', dbKey);
          }
          return result;
        }



      // Handle DB values that are stringified JSON lists
        if (karate.typeOf(dbValue) === 'string' && dbValue.startsWith("['")) {

          karate.log('Entering First Condition regarding Invalid JSON Format');
          karate.log('Converting Stringified JSON List:', dbValue);
          var fixedJsonString = dbValue.replace("/'/g", '"'); // Convert single quotes to double quotes
          dbValue = karate.fromString(fixedJsonString);// Parse corrected JSON
          var transform = function(item) { return karate.fromString(item); };
          dbValue = karate.map(dbValue, transform);
          karate.log('Converted DB Value:', dbValue);

        }

        else if (karate.typeOf(dbValue) === 'string' && dbValue.startsWith("[")) {

          karate.log('Entering Second Condition regarding converting JSON Array to JSON Object');
          dbValue = karate.fromString(dbValue)
          karate.log('Converted DB Value:', dbValue);

        }else{

          karate.log('SKIPPING conversion: Ditect string so directly validating with :', dbKey);

        }

      //Perform Validation & Collect Failures Instead of Stopping the Execution
        if (apiValue !== null) {
          karate.log('Validating:', dbKey, ' | API:', apiValue, ' | DB:', dbValue);
          var isMatch = karate.match(apiValue, dbValue).pass;
          var result = {
            "Attribute": attrPath,
            "API_Value": apiValue,
            "DB_Value": dbValue,
            "Match": isMatch
          };
          if (!isMatch) {
            failedAttributes.push(result);
            karate.log("MISMATCH Details for " + attrPath + ": ", result);
          } else {
            karate.log("MATCH Details for " + attrPath + ": ", result);
          }
          return result;
        }

      }
      """

    * def results = []


    # --------This Section will Handle the Multiple DB Enties and call the Main Funtion for Each Attribute----------
    * eval
      """
      var dbList = (DB_Details && DB_Details.length > 0) ? DB_Details : [{}];

      for (var i = 0; i < dbList.length; i++) {
        var dbRow = dbList[i];
        for (var j = 0; j < attributes.length; j++) {
          var attr = attributes[j];
          var result = validateAttribute(attr, dbRow);
          karate.log('Validation Result for:', result.Attribute, 'API Value:', result.API_Value, 'DB Value:', result.DB_Value, '| Passed:', result.Match);
          karate.log('--------------------Validation Ends-------------------------');
          karate.log("************************************************************************************");
          results.push(result);
        }
      }
      """

    # Format data for Excel
    * def excelData = results.map(function(res) {return [fhirID, res.Attribute, res.API_Value, res.DB_Value, res.Match, formattedTime];})
    * print excelData

    # Write to Excel
    * eval Validate_Data.setCellData(dbresourceName, ['fhirID', 'Attribute', 'API_Value', 'DB_Value', 'Match', 'Execution_Time'], excelData, fhirID)

    #---------------This section will count the Passed and Failed validations--------------------------
    * def attributeCount = attributes.length
    * def passedCount = karate.filter(results, function(res) { return res.Match == true }).length
    * def failedCount = karate.filter(results, function(res) { return res.Match == false }).length

    #-------------Creating the Summary Column with All the Count Details------------------------------
    * eval Validate_Data.setValidationSummary('Summary', fhirID, dbresourceName, attributeCount, passedCount, failedCount)

    #-------------------------Storing the values if Any Mismatches Exist thoughout the Validation-------------------
    * if (failedAttributes.length > 0) karate.log('Validation failed for all these attributes: ' + karate.pretty(failedAttributes))





  @validationWithFHIRID
  @ignore
  Scenario: Validating API Data with DB Data
    * print resourceData
    * print dbresourceName
    * print fhirID

    #------------------Fetching Resource Details from DB using FHIR ID--------------------
    * def DB_Details = sof_Table.readRows("SELECT * FROM demo." + dbresourceName + " WHERE id = '" + fhirID + "'")
    * if (!DB_Details) karate.appendTo(failedFHIRIDs, fhirID)
    * print DB_Details
    * karate.log('Type of DB Value:', karate.typeOf(DB_Details))
    * print "These are the Attribute Results for this Run", attributes

    #--------------This safeJsonPath Fuction is for Common Resources-------------------
    * def safeJsonPath =
      """
      function (json, path) {
        var keys = path.replace('$.', '').replace('[*]', '.*').split('.');
        var result = json;

        for (var i = 0; i < keys.length; i++) {
          var key = keys[i];

          if (key === '*') {
            if (!Array.isArray(result)) {
              karate.log('WARNING: Expected an array but found:', karate.typeOf(result));
              return null;
            }

            var collected = [];
            for (var j = 0; j < result.length; j++) {
              var sub = result[j];
            // recursively extract remaining path from each sub-object
              var remaining = keys.slice(i + 1).join('.');
              var val = safeJsonPath(sub, '$.' + remaining);
              if (val !== null && typeof val !== 'undefined') {
                if (Array.isArray(val)) {
                  collected = collected.concat(val);
                } else {
                  collected.push(val);
                }
              }
            }

            return collected.length > 0 ? collected : null;
          }

          if (typeof result !== 'object' || result === null || result[key] === undefined) {
            karate.log('WARNING: Attribute not found at step [' + key + '] in path:', path);
            return null;
          }

          result = result[key];
        }

        if (Array.isArray(result) && result.length === 0) {
          karate.log('WARNING: Empty list for path:', path);
          return null;
        } else if (result.length === 1) {
          karate.log('auto-flatten 1-element lists');
          return result[0];
        }

        karate.log("*****************************************************************************");
        return result;
      }
      """

    #--------------This safeJsonPathMain Fuction is for Common Resources-------------------

    * def safeJsonPathMain =
      """
      function (json, path) {
        var keys = path.replace('$.', '').replace('[*]', '.*').split('.');
        var result = json;

        for (var i = 0; i < keys.length; i++) {
          if (keys[i] === "*") {  // Handle array wildcard
            if (!Array.isArray(result)) {
              karate.log('WARNING: Expected an array but found:', karate.typeOf(result));
              return null;
            }
            var extractedValues = [];
            for (var j = 0; j < result.length; j++) {
              if (result[j][keys[i + 1]] !== undefined) {
                extractedValues.push(result[j][keys[i + 1]]);
              }
            }
            if (extractedValues.length === 0) {
              karate.log('WARNING: No matching array elements found for:', path);
              return null;
            }
            result = extractedValues;
            i++;  // Skip next key since it's already processed
          } else {
            if (result[keys[i]] === undefined) {
              karate.log('WARNING: Attribute not found in API response:', path);
              return null;
            }
            result = result[keys[i]];
          }
        }

        if (karate.typeOf(result) === 'list' && result.length == 0) {
          karate.log('WARNING: Empty list detected for:', path);
          return null;
        }
        karate.log("**************************************************************************");
      //karate.log("safeJsonPath Outcome for " + path + ":", result);
        return result;
      }
      """

    #--------------This Function is to Normalize the Stucture of DB Date According to the API Data--------------
    * def normalizeDate =
      """
      function(value) {
        if (value == null) {
          return null;  // Return NULL if the value is null
        }

      // Convert to string only if it's not already a string
        if(karate.typeOf(value) === 'string'){
          return value;
        } else {
          var strValue = value + ""
          if (strValue.match("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}")) {
            return strValue.split('T')[0];  // Extract YYYY-MM-DD
          }
        }

        return strValue;  // Return the converted string value
      }
      """


    * def normalizeAPIValue =
      """
      function(value) {
        if (value == null) {
          return null;  // Return NULL if the value is null
        }

      // Convert to string only if it's a Map or return as it is
        if(karate.typeOf(value) === 'map'){
          return JSON.stringify(value);
        } else {
          return value;
        }

      }
      """

    #----------------This Fuction is to pointout attribute focus to selected section of the FHIR Data----------------
    * def detectFHIRType =
      """
      function(fieldName) {
        var map = {
          "category": "CodeableConcept",
          "code": "CodeableConcept",
          "interpretation": "CodeableConcept",
          "bodySite": "CodeableConcept",
          "priority": "CodeableConcept"
        };
        return map[fieldName] || null;
      }
      """

    #---------------This Fuction to Resolve the Mismatch between common Resource Attributes and DB Colums--------------
    * def resolveApiDBMismatch =
      """
      function(attrPath, dbRow, patientData) {

        karate.log('START: resolveApiDBMismatch');
        karate.log('attrPath:', attrPath);
        karate.log('dbRow.record_id:', dbRow.record_id);
        karate.log('dbRow.seq_no:', dbRow.seq_no);
      // These are the few attributes will skip the deep check and compare directly with Main Data
        var contextOnlyAttrs = ["$.id", "$.record_id", "$.field_name", "$.seq_no"];

        if (contextOnlyAttrs.indexOf(attrPath) === -1) {

          karate.log('Attribute Enters Deep Search Section');

        // If attribute not found inside full FHIR payload then look inside array sections
          var arrayFields = ["identifier", "category", "code", "interpretation", "bodySite", "subject", "priority", "class"];

        // Mapping from DB lowercase field names to actual FHIR JSON field names
          var fieldMap = {
            "bodysite": "bodySite"
          };

          var apiValue = null;
        //var matchedFromArray = false;

          for (var i = 0; i < arrayFields.length; i++) {
            var field = arrayFields[i];
            var normalizedField = field.toLowerCase();
            var actualField = fieldMap[normalizedField] || field;
            karate.log('Checking field:', actualField);

            if (dbRow.record_id && dbRow.record_id.toLowerCase().indexOf(normalizedField + "_") > -1) {
              karate.log('record_id matched field:', actualField);
              var fhirList = safeJsonPath(patientData, "$." + actualField);
              karate.log('fhirList details:', fhirList);

              if (!fhirList || fhirList.length === 0) {
                karate.log('fhirList is empty or null for field:', actualField);
                continue;
              }

            // This section will handle those scenario when we receive "fhirList" as Object
              if (!Array.isArray(fhirList)) {
                karate.log('Wrapping single object into array for field:', actualField);
                fhirList = [fhirList];
              }

              var matchIndex = null;
              for (var j = 0; j < fhirList.length; j++) {
                if (typeof dbRow.seq_no !== 'undefined' && j === dbRow.seq_no) {
                  matchIndex = j;
                  karate.log('Matched seq_no:', j);
                  break;
                }
              }

              if (matchIndex !== null) {
                var contextNode = fhirList[matchIndex];
                karate.log('ContextNode details:', contextNode);

              // Handling the Complex attribute mismatching
                var type = detectFHIRType(actualField);
                karate.log('Detected FHIR type:', type);
                var rewrittenPath = rewriteMap[type] ? rewriteMap[type][attrPath] : null;
                karate.log('Using path:', rewrittenPath ? rewrittenPath : attrPath);

                apiValue = rewrittenPath ? safeJsonPath(contextNode, rewrittenPath) : safeJsonPath(contextNode, attrPath);
                karate.log('Response of Attribute goes though Selected Data:', apiValue);
              //matchedFromArray = true;
                break;
              }
              karate.log('Data is not avaialble for this field:', actualField);

            }
          }

        // Final fallback if not matched via array logic
        } else {
          apiValue = safeJsonPath(patientData, attrPath);
          karate.log('Response of Attribute goes though Full Data:- ', apiValue);
          return apiValue;
        }

      // Returning Deep Search Result Here
        if (Array.isArray(apiValue) && apiValue.length === 1) {
          karate.log("Forcefully getting first value to convert List to String")
          apiValue = apiValue[0];
          return apiValue;
        }
      //karate.log('Response of Attribute goes though Selected Data:- ', apiValue);
        return apiValue;
      }
      """


    #---------------This is the Main Function where the Validate will happen between API Data and DB Data-------------
    * def validateAttribute =
      """
      function (attrPath, dbRow) {
        var commonResources = ['codeableconcept', 'reference', 'identifier'];
        var apiValue;

        if (commonResources.indexOf(dbresourceName) > -1) {
        // For nested/common resources
          karate.log("Found Common Resource and attribute will go through resolveApiDBMismatch function")
          apiValue = resolveApiDBMismatch(attrPath, dbRow, resourceData);
        } else {
        // For main flat resources (e.g., Patient, Observation)
          karate.log("Found Main Resource and attribute will go through validation directly")
          apiValue = safeJsonPathMain(resourceData, attrPath);
        }
        var dbKey = attrPath.replace("$.", "").replace("[*]", "").replace(".", "_"); // Convert JSONPath to DB key format
        var requiredDBKey = karate.lowerCase(dbKey)
        var dbValue = dbRow[requiredDBKey]; // Get value from DB JSON

        dbValue = normalizeDate(dbValue);

        //karate.log('Before Convert API Value to String:', apiValue);

        //apiValue = normalizeAPIValue(apiValue);



        karate.log('--------------------Validation Starts-------------------------');
        karate.log('Checking Attribute:', attrPath);
        karate.log('Extracted API Value:', apiValue);
        karate.log('Extracted DB Key:', requiredDBKey);
        karate.log('Extracted DB Value:', dbValue);
        karate.log('Type of DB Value:', karate.typeOf(dbValue));
        karate.log('Type of API Value:', karate.typeOf(apiValue));

      //If API attribute is missing, DB should also be NULL
        if (apiValue === null) {
          karate.log('NULL CHECK: API is missing this attribute, checking if DB is also NULL');
          var isNullCheck = (dbValue == null);
          var result = {
            "Attribute": attrPath,
            "API_Value": apiValue,
            "DB_Value": dbValue,
            "Match": isNullCheck
          };
          if (!isNullCheck) {
            failedAttributes.push({ "Attribute": attrPath, "Expected": "null", "Found": dbValue });
            karate.log('MISMATCH: Expected NULL but found in DB:', dbValue);
          } else {
            karate.log('NULL CHECK PASSED: Both API and DB have NULL for:', dbKey);
          }
          return result;
        }



      // Handle DB values that are stringified JSON lists
        if (karate.typeOf(dbValue) === 'string' && dbValue.startsWith("['")) {

          karate.log('Entering First Condition regarding Invalid JSON Format');
          karate.log('Converting Stringified JSON List:', dbValue);
          var fixedJsonString = dbValue.replace("/'/g", '"'); // Convert single quotes to double quotes
          dbValue = karate.fromString(fixedJsonString);// Parse corrected JSON
          var transform = function(item) { return karate.fromString(item); };
          dbValue = karate.map(dbValue, transform);
          karate.log('Converted DB Value:', dbValue);

        }

        else if (karate.typeOf(dbValue) === 'string' && dbValue.startsWith("[")) {

          karate.log('Entering Second Condition regarding converting JSON Array to JSON Object');
          dbValue = karate.fromString(dbValue)
          karate.log('Converted DB Value:', dbValue);

        }else{

          karate.log('SKIPPING conversion: Ditect string so directly validating with :', dbKey);

        }

      //Perform Validation & Collect Failures Instead of Stopping the Execution
        if (apiValue !== null) {
          karate.log('Validating:', dbKey, ' | API:', apiValue, ' | DB:', dbValue);
          var isMatch = karate.match(apiValue, dbValue).pass;
          var result = {
            "Attribute": attrPath,
            "API_Value": apiValue,
            "DB_Value": dbValue,
            "Match": isMatch
          };
          if (!isMatch) {
            failedAttributes.push(result);
            karate.log("MISMATCH Details for " + attrPath + ": ", result);
          } else {
            karate.log("MATCH Details for " + attrPath + ": ", result);
          }
          return result;
        }

      }
      """

    * def results = []


    # --------This Section will Handle the Multiple DB Enties and call the Main Funtion for Each Attribute----------
    * eval
      """
      var dbList = (DB_Details && DB_Details.length > 0) ? DB_Details : [{}];

      for (var i = 0; i < dbList.length; i++) {
        var dbRow = dbList[i];
        for (var j = 0; j < attributes.length; j++) {
          var attr = attributes[j];
          var result = validateAttribute(attr, dbRow);
          karate.log('Validation Result for:', result.Attribute, 'API Value:', result.API_Value, 'DB Value:', result.DB_Value, '| Passed:', result.Match);
          karate.log('--------------------Validation Ends-------------------------');
          karate.log("**************************************************************************************");
          results.push(result);
        }
      }
      """

    # Format data for Excel
    * def excelData = results.map(function(res) {return [fhirID, res.Attribute, res.API_Value, res.DB_Value, res.Match, formattedTime];})
    * print excelData

    # Write to Excel
    * eval Validate_Data.setCellData(dbresourceName, ['fhirID', 'Attribute', 'API_Value', 'DB_Value', 'Match', 'Execution_Time'], excelData, fhirID)

    #---------------This section will count the Passed and Failed validations--------------------------
    * def attributeCount = attributes.length
    * def passedCount = karate.filter(results, function(res) { return res.Match == true }).length
    * def failedCount = karate.filter(results, function(res) { return res.Match == false }).length

    #-------------Creating the Summary Column with All the Count Details------------------------------
    * eval Validate_Data.setValidationSummary('Summary', fhirID, dbresourceName, attributeCount, passedCount, failedCount)

    #-------------------------Storing the values if Any Mismatches Exist thoughout the Validation-------------------
    * if (failedAttributes.length > 0) karate.log('Validation failed for all these attributes: ' + karate.pretty(failedAttributes))









