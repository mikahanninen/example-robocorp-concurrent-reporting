*** Settings ***
Library           RPA.Excel.Files
Library           RPA.Tables
Resource          workmanagement.resource

*** Tasks ***
Produce items
    [Documentation]
    ...    Get source Excel file from work item.
    ...    Read rows from Excel.
    ...    Creates output work items per row.
    #${path}=    Get Work Item File    orders.xlsx
    Reset REPORTED Value
    Open Workbook    ${CURDIR}${/}orders.xlsx
    ${table}=    Read Worksheet As Table    header=True
    ${length}=    Get Length    ${table}
    FOR    ${row}    IN    @{table}
        ${variables}=    Create Dictionary
        ...    Name=${row}[Name]
        ...    Zip=${row}[Zip]
        ...    Item=${row}[Item]
        ...    Length=${length}
        Create Output Work Item
        ...    variables=${variables}
        ...    save=True
    END
