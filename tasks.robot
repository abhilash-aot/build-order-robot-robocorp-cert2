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
Library           OperatingSystem
Library           RPA.PDF
Library           RPA.Archive


# +
*** Variables ***
${VAULT_SECRET_KEY}                    urls 
${ORDER_URL_TYPE}                      orderUrl
${ORDER_DATA_URL_TYPE}                 orderDataUrl
${RETRY_TIMES}                         10x
${RETRY_INTERVAL}                      1s
${OUTPUT_DIR}                          ${CURDIR}${/}output
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

Submit the Robot Order Form And Open the Recipet Page
  Click Element    id:order
  Wait Until Page Contains Element  id:receipt
  
Create screenshot and pdf output Directories
  Create Directory    ${OUTPUT_DIR}
  Empty Directory     ${OUTPUT_DIR}
  Create Directory    ${IMAGE_SCREENSHOTS_DIR}
  Empty Directory     ${IMAGE_SCREENSHOTS_DIR}
  Create Directory    ${RECEIPTS_PDF_DIR}
  Empty Directory     ${RECEIPTS_PDF_DIR}
  

Save a screenshot of each of the ordered robot
  [Arguments]  ${id}
  Wait Until Page Contains Element   id:robot-preview-image
  Screenshot    id:robot-preview-image  ${IMAGE_SCREENSHOTS_DIR}${/}${id}.png
  [return]  ${IMAGE_SCREENSHOTS_DIR}${/}${id}.png
  
Save each order HTML receipt as a PDF file
  [Arguments]  ${id}
  ${receiptHTMLData} =  Get Element Attribute    id:receipt    outerHTML
  Html To Pdf    ${receiptHTMLData}    ${RECEIPTS_PDF_DIR}${/}${id}.pdf
  [Return]  ${RECEIPTS_PDF_DIR}${/}${id}.pdf

Embed the screenshot of the robot to the PDF receipt
  [Arguments]  ${img}  ${pdf}
  Open Pdf  ${pdf}
  ${listImg} =  Create List  ${img}
  Add Files To Pdf  ${listImg}  ${pdf}  append=True
  Close Pdf
  
Fill and submit the robot order form for single robot
    [Arguments]    ${data}
    
   Select From List By Value  head    ${data}[Head]
   Click Element  //input[@name="body"][@value=${data}[Body]]
   Input Text  //input[@placeholder="Enter the part number for the legs"]  ${data}[Legs]
   Input Text  address  ${data}[Address]
   #  Preview the robot
   Click Button    id:preview
   
   #this form submission fails in site with error some times so need to try again in case
   Wait Until Keyword Succeeds
  ...  ${RETRY_TIMES}
  ...  ${RETRY_INTERVAL}
  ...  Submit the Robot Order Form And Open the Recipet Page
  
    
   ${screenshotTaken} =  Save a screenshot of each of the ordered robot  ${data}[Order number]
    
   ${pdfFile} =  Save each order HTML receipt as a PDF file  ${data}[Order number]
   
   Embed the screenshot of the robot to the PDF receipt  ${screenshotTaken}  ${pdfFile}
   
   # Go to order another robot
   Click Button    id:order-another
   
    
Get the data for placing the order
    Download the CSV file
    
Create Consolidated Reciepts in Zip format
    Archive Folder With Zip    ${RECEIPTS_PDF_DIR}    ${CURDIR}${/}output${/}consolidatedreceipts.zip    

Place the robot order one by one from the order data Obtained   
    
    ${allOrders}=   Read orders csv file into Orders variable
    
    Open the robot order website  
    
    FOR    ${order}    IN    @{allOrders}
       #the annoying modal comes in each iteration
       Close the annoying modal
       
       Fill and submit the robot order form for single robot    ${order}
       
     END
    
# -

*** Tasks ***
Order the robots one by one from RobotSpareBin Industries Inc 
    
    #step 1
    Get the data for placing the order
    #step 2
    Create screenshot and pdf output Directories
    #step 3
    Place the robot order one by one from the order data Obtained
    #step 4
    Create Consolidated Reciepts in Zip format
    
    #[Teardown]    Close All Browsers
    
    Log    Done.


