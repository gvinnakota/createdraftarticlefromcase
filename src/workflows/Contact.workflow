<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Contact_Owner_Admin</fullName>
        <field>OwnerId</field>
        <lookupValue>pivotaladmin@pivotal.io</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Contact - Owner Admin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Export_Status</fullName>
        <description>Reset the Export Status to "Not Started" whenever a new RPS Validation Check is initiated.</description>
        <field>Export_Status__c</field>
        <literalValue>Not Started</literalValue>
        <name>Reset Export Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Contact_Company_Account_Name</fullName>
        <field>Contact_Company__c</field>
        <formula>Account.Name</formula>
        <name>Set 'Contact Company' - Account Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>RPS_Contact</fullName>
        <apiVersion>40.0</apiVersion>
        <endpointUrl>https://sf.visualcompliance.com/RPS_SF_WS/ContactNotificationService.asmx</endpointUrl>
        <fields>Email</fields>
        <fields>FirstName</fields>
        <fields>Id</fields>
        <fields>LastName</fields>
        <fields>MailingCity</fields>
        <fields>MailingCountry</fields>
        <fields>MailingState</fields>
        <fields>MailingStreet</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>sfintegration@pivotal.io</integrationUser>
        <name>RPS Contact</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>RPS Contact Change</fullName>
        <actions>
            <name>Reset_Export_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RPS_Contact</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>OR(isNew(),  			isChanged(FirstName), 			isChanged(LastName), 			isChanged(Email), 			isChanged(MailingCountry) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
