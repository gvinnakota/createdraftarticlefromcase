<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_Approval_status_to_empty</fullName>
        <field>Approval_Status_picklist__c</field>
        <name>Change Approval status to empty</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>OpportunityId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Line_Product_Family</fullName>
        <field>Product_Family_txt__c</field>
        <formula>Text(Product2.Family)</formula>
        <name>Update Product Family Txt from Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pivotal_Labs_Engagement_SELECTED</fullName>
        <field>Pivotal_Labs_Engagement__c</field>
        <literalValue>1</literalValue>
        <name>Pivotal Labs Engagement SELECTED</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>OpportunityId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Product_Portfolio_Update</fullName>
        <field>Product_Portfolio_txt__c</field>
        <formula>TEXT(Product2.Report_Category__c)</formula>
        <name>Update Portfolio Txt from Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Approved_checkbox</fullName>
        <field>Approved__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Approved checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <targetObject>OpportunityId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Product_Portfolio_txt_from_Produc</fullName>
        <field>Product_Portfolio_txt__c</field>
        <formula>Text( Product2.Report_Category__c )</formula>
        <name>Update Product Portfolio txt from Produc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sales_Price</fullName>
        <description>Set Sales Price = Forecasted New Amount + Forecasted Renewal Amount</description>
        <field>UnitPrice</field>
        <formula>Forecasted_New_Amount__c + Forecasted_Renewal_Amount__c</formula>
        <name>Update Sales Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Selling_Motion_Txt_from_Product</fullName>
        <field>Selling_Motion_txt__c</field>
        <formula>TEXT(Product2.Selling_Motion__c)</formula>
        <name>Update Selling Motion Txt from Product</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Opp Product Fields from Product2</fullName>
        <actions>
            <name>Opportunity_Line_Product_Family</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Product_Portfolio_txt_from_Produc</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Selling_Motion_Txt_from_Product</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the text product family, portfolio and selling motion fields txt fields to allow rollups to opportunity</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
