*** Settings ***
Library           Collections
Library           RPA.Browser.Selenium
Library           RPA.Robocorp.WorkItems
Library           RPA.Tables

*** Tasks ***
Consume items
    [Documentation]    Login and then cycle through work items.
    ${Login OK}=    Run Keyword And Return Status
    ...    Login
    IF    ${Login OK}
        For Each Input Work Item    Handle item
    ELSE
        ${error_message}=    Set Variable
        ...    Unable to login to target system. Please check that the site/application is up and available.
        Log    ${error_message}    level=ERROR
        ${payload}=    Get Work Item Payload
        Create Output Work Item
        ...    variables=${payload}
        ...    save=True
        Release Input Work Item
        ...    state=FAILED
        ...    exception_type=APPLICATION
        ...    message=${error_message}
    END

*** Keywords ***
Login
    [Documentation]
    ...    Simulates a login that fails 1/5 times to highlight APPLICATION exception handling.
    ...    In this example login is performed only once for all work items.
    ${Login as James Bond}=    Evaluate    random.randint(1, 5)
    IF    ${Login as James Bond} != 1
        Log    Logged in as Bond. James Bond.
    ELSE
        Fail    Login failed
    END

Action for item
    [Documentation]
    ...    Simulates handling of one work item that fails 1/5 times to
    ...    highlight BUSINESS exception handling.
    [Arguments]    ${payload}
    ${Item Action OK}=    Evaluate    random.randint(1, 5)
    ${random_sleep_time}=    Evaluate    random.randint(5, 10)
    Sleep    ${random_sleep_time}
    IF    ${Item Action OK} != 1
        Log    Did a thing item for: ${payload}
    ELSE
        Fail    Failed to handle item for: ${payload}.
    END

Handle item
    [Documentation]    Error handling around one work item.
    ${payload}=    Get Work Item Payload
    ${Item Handled}=    Run Keyword And Return Status
    ...    Action for item    ${payload}
    Create Output Work Item
    ...    variables=${payload}
    ...    save=True
    IF    ${Item Handled}
        Log TO Console    All Good
    ELSE
        # Giving a good error message here means that data related errors can
        # be fixed faster in Control Room.
        ${error_message}=    Set Variable
        ...    Failed to handle item for: ${payload}.
        #Release Input Work Item
        #...    state=FAILED
        #...    exception_type=BUSINESS
        #...    message=${error_message}
    END
    Release Input Work Item    DONE
