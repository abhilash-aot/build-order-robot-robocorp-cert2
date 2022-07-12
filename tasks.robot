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
# -

*** Variables ***
${VAULT_SECRET_KEY}                    urls 
${ORDER_URL_TYPE}                      orderUrl
${ORDER_DATA_URL_TYPE}                 orderDataUrl


# +
*** Keywords ***
Get Url From Vault
      [Arguments]   ${urlType}
      Log   ${VAULT_SECRET_KEY}
      ${secretUrls}=  Get Secret     ${VAULT_SECRET_KEY}
      Log   ${secretUrls}
      Log   ${secretUrls}[${urlType}]
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
    
Opem the info modal
    Click Button  Show model info    
    
Close the info modal
    Wait Until Page Contains Element   Hide modal info
    Click Button  Hide modal info      

Get data of models
    Opem the info modal
    ${html_table}=    Get Element Attribute    id:model-info    outerHTML
    [return]    ${html_table}


Fill the robot order form
    [Arguments]    ${data}
    
    Log    ${data}
    
    
# -

*** Tasks ***
Order the robots one by one from RobotSpareBin Industries Inc 

    #Get the data for placing the order 
    Download the CSV file
    ${allOrders}=   Read orders csv file into Orders variable
    Log  ${allOrders} 
   
    #Open the robotSparebin site and close the annoying modal   
    Open the robot order website
    Close the annoying modal
    
    #${modalDataHTML}=   Get data of models
    #Log     ${modalDataHTML}
    #${modalData}=    Read Table From Html    ${modalDataHTML}
    #Log     ${modalData}
    
     #Order the robots one by one from RobotSpareBin Industries Inc 
     FOR    ${order}    IN    @{allOrders}
       Fill the robot order form    ${order}
      #  Preview the robot
       # Submit the order
       # ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
       # ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
       # Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
       # Go to order another robot
    END
    #Create a ZIP file of the receipts
    #[Teardown]    Close All Browsers
    Log    Done.


