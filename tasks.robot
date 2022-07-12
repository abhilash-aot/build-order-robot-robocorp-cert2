# +
*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

#imported Libraries
Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.Robocorp.Vault

# +
*** Variables ***
${VAULT_SECRET_KEY}                    urls 
${ORDER_URL_TYPE}                      orderUrl
${ORDER_DATA_URL_TYPE}                 orderDataUrl
${OUTPUT_DIR}                          ${CURDIR}${/}output${/}
${IMAGE_SCREENSHOTS_DIR}               ${CURDIR}${/}output${/}screenshots
${RECEIPTS_PDF_DIR}                    ${CURDIR}${/}output${/}receipts



# +
*** Keywords ***
Get Url From Vault
      [Arguments]   ${urlType}
      ${secretUrls}=  Get Secret     ${VAULT_SECRET_KEY}
      [return]  ${secretUrls}[${urlType}]

Open the robot order website
    ${orderUrl}=    Get Url From Vault      ${ORDER_URL_TYPE} 
    Open Available Browser  ${orderUrl}   
    
Close the annoying modal
    Wait Until Page Contains Element   class:modal-dialog 
    Click Button  I guess so...
        
Download the CSV file
    ${orderDataUrl}=    Get Url From Vault      ${ORDER_DATA_URL_TYPE} 
    Download    ${orderDataUrl}    overwrite=True
    
Read orders csv file into Orders variable
    ${orders}=
    ...    Read Table From Csv
    ...    orders.csv
    ...    header=True
    Log    ${orders}    
    [return]  ${orders}


Fill and submit the robot order form for single robot
    [Arguments]    ${data}
    
   Select From List By Value  head    ${data}[Head]
   Click Element  //input[@name="body"][@value=${data}[Body]]
   Input Text  //input[@placeholder="Enter the part number for the legs"]  ${data}[Legs]
   Input Text  address  ${data}[Address]
   Click Button    id:preview
  
   Log    ${data}
    
Get the data for placing the order
    Download the CSV file

Place the robot order one by one from the order data Obtained   
    
    ${allOrders}=   Read orders csv file into Orders variable
    
    Open the robot order website
    #the annoying modal comes in each iteration
    Close the annoying modal  
    
    FOR    ${order}    IN    @{allOrders}
       Fill and submit the robot order form for single robot    ${order}
      #  Preview the robot
       # Submit the order
       # ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
       # ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
       # Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
       # Go to order another robot
     END
    
# -

*** Tasks ***
Order the robots one by one from RobotSpareBin Industries Inc 
    Get the data for placing the order 
    Place the robot order one by one from the order data Obtained   

    #Create a ZIP file of the receipts
    #[Teardown]    Close All Browsers
    Log    Done.


