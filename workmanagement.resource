*** Settings ***
Library           Collections
Library           RPA.Robocorp.Process
Library           RPA.Robocorp.Vault
Library           RPA.Robocorp.WorkItems

*** Variables ***
${ACTIVITY_ID_STEP_2}    da6366d6-6b53-4b38-bc91-fd9814c543f3
${ACTIVITY_ID_STEP_3}    8c66f3c3-b852-4f4d-8937-8141c7b49775
@{NOT_COMPLETED_STATES}    IN_PROGRESS    PENDING

*** Keywords ***
Reset REPORTED Value
    ${secrets}=    Get Secret    PROCESS_DETAILS
    Set To Dictionary    ${secrets}    REPORTED=0
    Set Secret    ${secrets}

Is step completed
    [Arguments]    ${activityId}
    ${work_items}=    Get all work items for a process run
    ${result}=    Evaluate    not any([item['state'] in ${NOT_COMPLETED_STATES} for item in $work_items if "${activityId}" == item['activityId']])
    [Return]    ${result}

Get all work items for a process run
    [Arguments]    ${activityId}=${NONE}
    ${secrets}=    Get Secret    PROCESS_DETAILS
    Set Credentials
    ...    workspace_id=%{RC_WORKSPACE_ID}
    ...    process_id=%{RC_PROCESS_ID}
    Set Apikey    ${secrets}[APIKEY]
    ${work_items}=    List Process Run Work Items
    ...    process_run_id=%{RC_PROCESS_RUN_ID}
    ...    include_data=True
    Log Many    ${work_items}
    IF    "${activityId}" != "${NONE}"
        ${work_items}=    Evaluate    [item for item in $work_items if "${activityId}" == item['activityId']]
    END
    [Return]    ${work_items}

Report When Possible
    ${is_completed}=    Is step completed    ${ACTIVITY_ID_STEP_2}
    IF    ${is_completed}
        Log To Console    Step 2 completed. Reporting can be done.
        ${secrets}=    Get Secret    PROCESS_DETAILS
        IF    "${secrets}[REPORTED]" == "0"
            Set To Dictionary    ${secrets}    REPORTED=1
            Set Secret    ${secrets}
            Log To Console    \nNOW REPORTING
            ${work_items}=    Get all work items for a process run    ${ACTIVITY_ID_STEP_3}
            FOR    ${index}    ${item}    IN ENUMERATE    @{work_items}
                Log To Console    ITEM: ${index}\n${item}
            END
        ELSE
            Log To Console    \nWAS ALREADY REPORTED
        END
    ELSE
        Log To Console    Step is still IN_PROGRESS. Reporting can't be done yet.
    END
