<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Entitlement_Search_Field</fullName>
        <field>EntitlementSearchFields__c</field>
        <formula>Account.Name+" "+Product_SKU__c+" "+ SKU_Name__c+" "+Entitlement_Product_Name__c</formula>
        <name>Update Entitlement Search Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_startdate</fullName>
        <description>update custom start date field value</description>
        <field>StartDate__c</field>
        <formula>StartDate</formula>
        <name>Update startdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_enddate</fullName>
        <description>update custom end date field value</description>
        <field>EndDate__c</field>
        <formula>EndDate</formula>
        <name>update enddate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Entitlement-updatestartdateandenddate</fullName>
        <actions>
            <name>Update_startdate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>update_enddate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Entitlement.StartDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Entitlement.EndDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>this work flow is used update custom startdate and enddate fields</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Entitlement Search Field</fullName>
        <actions>
            <name>Update_Entitlement_Search_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISNEW(), ISCHANGED( AccountId ) , ISCHANGED( ProductEntitlementMap__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
