# +
*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

#imported Libraries
Library           RPA.Browser.Selenium
Library           RPA.RobotLogListener
Library           RPA.HTTP
Library           RPA.Tables
# -

*** Variables ***
${THIS_LOCATOR_MATCHES}=    css:input
${THIS_LOCATOR_DOES_NOT_MATCH}=    this-locator-does-not-match-anything

*** Keywords ***
Click Element If It Appears
    [Arguments]    ${locator}
    Mute Run On Failure    Click Element When Visible
    Run Keyword And Ignore Error    Click Element When Visible    ${locator}

# +
*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    
Close the annoying modal
    Wait Until Page Contains Element   class:modal-dialog 
    Click Button  I guess so...
        
Download the CSV file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    
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
    
    ${modalDataHTML}=   Get data of models
    Log     ${modalDataHTML}
    ${modalData}=    Read Table From Html    ${modalDataHTML}
    Log     ${modalData}
    
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


