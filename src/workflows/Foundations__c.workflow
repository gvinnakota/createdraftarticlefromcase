<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Update Foundation - Month Consumption Collected</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Foundations__c.Month_Consumption_Collected__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
