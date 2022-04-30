*** Settings ***
Library           OperatingSystem
Library           Collections
Resource          workmanagement.resource

*** Tasks ***
Report Result
    For Each Input Work Item    Report when possible
