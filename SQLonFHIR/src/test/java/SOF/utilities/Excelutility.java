package SOF.utilities;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Excelutility {

    public FileInputStream fip;
    public FileOutputStream fop;
    public XSSFWorkbook workbook;
    public XSSFSheet sheet;
    public XSSFRow row;
    public XSSFCell cell;
    private String path;

    public Excelutility(String path) {

        this.path=path;
        createExcelFileIfNotExists();
    }

    // Method to check and create Excel file
    private void createExcelFileIfNotExists() {
        try {
            File file = new File(path);
            File parentDir = file.getParentFile();

            // Ensure parent directory exists
            if (parentDir != null && !parentDir.exists()) {
                parentDir.mkdirs();
            }

            // Create a new Excel file if it does not exist
            if (!file.exists()) {
                System.out.println("Excel file not found. Creating a new one...");
                XSSFWorkbook workbook = new XSSFWorkbook();
                FileOutputStream fop = new FileOutputStream(file);
                workbook.write(fop);
                fop.close();
                workbook.close();
            }
        } catch (Exception e) {
            System.err.println("Error creating Excel file: " + e.getMessage());
        }
    }


    // Method to read resourceName and resourceCount from Excel
    public List<Map<String, Object>> readResourceDataWithCount() throws Exception {
        List<Map<String, Object>> resourceList = new ArrayList<>();
        fip = new FileInputStream(new File(path));
        workbook = new XSSFWorkbook(fip);
        sheet = workbook.getSheetAt(0); // Assuming first sheet

        // Read Header Row
        Row headerRow = sheet.getRow(0);
        int resourceCol = -1, countCol = -1;

        for (int i = 0; i < headerRow.getLastCellNum(); i++) {
            Cell cell = headerRow.getCell(i);
            if (cell != null) {
                String header = cell.getStringCellValue().trim();
                if (header.equalsIgnoreCase("Resource_Name")) {
                    resourceCol = i;
                } else if (header.equalsIgnoreCase("Count")) {
                    countCol = i;
                }
            }
        }

        // Read Data Rows
        for (int i = 1; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);
            if (row != null) {
                Map<String, Object> data = new HashMap<>();
                data.put("resourceName", row.getCell(resourceCol).getStringCellValue());
                data.put("resourceCount", (int) row.getCell(countCol).getNumericCellValue());
                resourceList.add(data);
            }
        }

        workbook.close();
        fip.close();
        return resourceList;
    }

    // Method to read resourceName and FHIRId from Excel
    public List<Map<String, Object>> readResourceDataWithFHIRID() throws Exception {
        List<Map<String, Object>> resourceList = new ArrayList<>();
        fip = new FileInputStream(new File(path));
        workbook = new XSSFWorkbook(fip);
        sheet = workbook.getSheetAt(0); // First sheet

        // Read Header Row
        Row headerRow = sheet.getRow(0);
        int resourceCol = -1, fhirIdCol = -1;

        for (int i = 0; i < headerRow.getLastCellNum(); i++) {
            Cell cell = headerRow.getCell(i);
            if (cell != null) {
                String header = cell.getStringCellValue().trim();
                if (header.equalsIgnoreCase("Resource_Name")) {
                    resourceCol = i;
                } else if (header.equalsIgnoreCase("fhirID")) {
                    fhirIdCol = i;
                }
            }
        }

        // Read Data Rows
        for (int i = 1; i <= sheet.getLastRowNum(); i++) {
            Row row = sheet.getRow(i);
            if (row != null) {
                Map<String, Object> data = new HashMap<>();
                data.put("resourceName", row.getCell(resourceCol).getStringCellValue());
                data.put("fhirID", row.getCell(fhirIdCol).getStringCellValue());
                resourceList.add(data);
            }
        }

        workbook.close();
        fip.close();
        return resourceList;
    }


    public int getRowCount(String sheetName) throws Exception {

        fip= new FileInputStream(path);
        workbook= new XSSFWorkbook(fip);
        sheet= workbook.getSheet(sheetName);
        int rowcount= sheet.getLastRowNum();
        workbook.close();
        fip.close();
        return rowcount;

    }


    public int getCellCount(String sheetName, int rownum) throws Exception {

        fip= new FileInputStream(path);
        workbook= new XSSFWorkbook(fip);
        sheet= workbook.getSheet(sheetName);
        row= sheet.getRow(rownum);
        int cellcount= row.getLastCellNum();
        workbook.close();
        fip.close();
        return cellcount;
    }


    public String getCellData(String sheetName, int rownum, int column) throws Exception {

        fip= new FileInputStream(path);
        workbook= new XSSFWorkbook(fip);
        sheet= workbook.getSheet(sheetName);
        row= sheet.getRow(rownum);
        cell=row.getCell(column);

        DataFormatter formatter= new DataFormatter();
        String data;
        try {

            data=formatter.formatCellValue(cell);

        }catch (Exception e) {

            data="";
        }

        workbook.close();
        fip.close();
        return data;
    }



    public void setCellData(String sheetName, List<String> columnNames, List<List<Object>> dataList, String fhirID) throws Exception {

        System.out.println("Writing data to Excel: " + dataList.size() + " rows");

        File xlfile = new File(path);

        // Step 1: Create file if it doesn't exist
        if (!xlfile.exists()) {
            System.out.println("Excel file does not exist. Creating new file...");
            workbook = new XSSFWorkbook();
            fop = new FileOutputStream(path);
            workbook.write(fop);
            fop.close();
        }

        // Step 2: Open the existing Excel file
        fip = new FileInputStream(path);
        workbook = new XSSFWorkbook(fip);

        // Step 3: Create sheet if it does not exist
        if (workbook.getSheetIndex(sheetName) == -1) {
            workbook.createSheet(sheetName);
        }

        sheet = workbook.getSheet(sheetName);

        // Step 4: Create header row if it does not exist
        Row headerRow = sheet.getRow(0);
        if (headerRow == null) {
            headerRow = sheet.createRow(0);
        }

        // Step 5: Store column indexes dynamically
        Map<String, Integer> colIndexes = new HashMap<>();

        for (int i = 0; i < columnNames.size(); i++) {
            Cell cell = headerRow.getCell(i);
            if (cell == null) {
                cell = headerRow.createCell(i);
                cell.setCellValue(columnNames.get(i));
            }
            colIndexes.put(columnNames.get(i), i);
        }

        // Step 6: Check if fhirID already exists and remove old data if found
        int fhirIDColumnIndex = colIndexes.get("fhirID");
        int lastRow = sheet.getLastRowNum();
        List<Integer> rowsToRemove = new ArrayList<>();

        for (int i = 1; i <= lastRow; i++) { // Start from row 1 (skip header)
            Row row = sheet.getRow(i);
            if (row != null) {
                Cell fhirCell = row.getCell(fhirIDColumnIndex);
                if (fhirCell != null && fhirID.equals(fhirCell.getStringCellValue())) {
                    rowsToRemove.add(i);
                }
            }
        }

        // Remove existing rows for the same fhirID
        for (int rowIndex : rowsToRemove) {
            sheet.removeRow(sheet.getRow(rowIndex));
        }

        // Step 7: Write new data, appending at the bottom
        int rowNum = sheet.getLastRowNum() + 1;

        com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper(); // Create ObjectMapper

        for (List<Object> rowData : dataList) {
            Row row = sheet.createRow(rowNum);

            for (int i = 0; i < rowData.size(); i++) {
                Cell cell = row.createCell(i);

                // Handle different data types (String, Boolean, etc.)
                Object value = rowData.get(i);
                if (value == null) {
                    cell.setCellValue("N/A");
                } else if (value instanceof Boolean) {
                    cell.setCellValue((Boolean) value);
                } else if (value instanceof Number) {
                    cell.setCellValue(((Number) value).doubleValue());
                } else if (value instanceof Map) {
                    try {
                        // Properly convert Maps to clean JSON string
                        String jsonString = mapper.writeValueAsString(value);
                        cell.setCellValue(jsonString);
                    } catch (Exception e) {
                        cell.setCellValue(value.toString()); // fallback in case JSON conversion fails
                    }
                } else {
                    // Normal string value
                    cell.setCellValue(value.toString());
                }
            }

            rowNum++;
        }

        // Step 7: Write the updated data to the Excel file
        fop = new FileOutputStream(path);
        workbook.write(fop);

        // Step 8: Close resources
        workbook.close();
        fip.close();
        fop.close();

        System.out.println("Excel write successful: " + path);
        System.out.println("Excel write successful for FHIR ID: " + fhirID + " in sheet: " + sheetName);
    }



    public void setValidationSummary(String sheetName, String fhirID, String resourceName, int attributeCount, int passed, int failed) throws Exception {

        File xlfile = new File(path);

        // Step 1: Create file if missing
        if (!xlfile.exists()) {
            workbook = new XSSFWorkbook();
            fop = new FileOutputStream(path);
            workbook.write(fop);
            fop.close();
        }

        // Step 2: Open Excel file
        fip = new FileInputStream(path);
        workbook = new XSSFWorkbook(fip);
        fip.close();

        // Step 3: Get or create sheet
        if (workbook.getSheetIndex(sheetName) == -1) {
            workbook.createSheet(sheetName);
        }
        sheet = workbook.getSheet(sheetName);

        // Step 4: Create header row if missing
        Row headerRow = sheet.getRow(0);
        if (headerRow == null) {
            headerRow = sheet.createRow(0);
            headerRow.createCell(0).setCellValue("fhirID");
            headerRow.createCell(1).setCellValue("resourceName");
            headerRow.createCell(2).setCellValue("Attribute_Count");
            headerRow.createCell(3).setCellValue("Passed");
            headerRow.createCell(4).setCellValue("Failed");
        }

        // Step 5: Check if fhirID already exists
        int lastRow = sheet.getLastRowNum();
        int existingRowIndex = -1;

        for (int i = 1; i <= lastRow; i++) {
            Row row = sheet.getRow(i);
            if (row != null) {
                Cell idCell = row.getCell(0);
                Cell resourceCell = row.getCell(1);

                if (idCell != null && resourceCell != null &&
                        fhirID.equals(idCell.getStringCellValue()) &&
                        resourceName.equals(resourceCell.getStringCellValue())) {
                    existingRowIndex = i;
                    break;
                }
            }
        }

        // Step 6: Add or update row
        Row row;
        if (existingRowIndex == -1) { // Add new row
            row = sheet.createRow(lastRow + 1);
        } else { // Update existing row
            row = sheet.getRow(existingRowIndex);
        }

        row.createCell(0).setCellValue(fhirID);
        row.createCell(1).setCellValue(resourceName);
        row.createCell(2).setCellValue(attributeCount);
        row.createCell(3).setCellValue(passed);
        row.createCell(4).setCellValue(failed);

        // Step 7: Save and close the file
        fop = new FileOutputStream(path);
        workbook.write(fop);
        fop.close();
        workbook.close();

        System.out.println("Excel Summary Updated for fhirID: " + fhirID + ", resourceName: " + resourceName);
    }



}
