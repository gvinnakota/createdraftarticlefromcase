<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>PARTNER Auto-renew Add 1 Year</fullName>
        <active>true</active>
        <description>Add 1 Year to any ACTIVE partnerships when expiry date is reached.</description>
        <formula>Active__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Partnership__c.Agreement_Expiry__c</offsetFromField>
            <timeLength>-4</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
