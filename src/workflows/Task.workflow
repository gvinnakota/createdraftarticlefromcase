<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_the_Task_Type_Field</fullName>
        <field>Type</field>
        <literalValue>Email</literalValue>
        <name>Update the Task Type Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update the Task type to Email</fullName>
        <actions>
            <name>Update_the_Task_Type_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>contains</operation>
            <value>Email,Message,Reply,RE:</value>
        </criteriaItems>
        <description>Email Activities - Type: Email</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
