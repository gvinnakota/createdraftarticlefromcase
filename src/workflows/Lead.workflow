<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Lead_in_Labs_Queue_48_hours_2</fullName>
        <description>Lead in Labs Queue &gt; 48 hours</description>
        <protected>false</protected>
        <recipients>
            <recipient>elim@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jhum@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>svaziri@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tmccollough@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Lead_in_Labs_Queue_48_Hours</template>
    </alerts>
    <alerts>
        <fullName>Notify_BD_of_Hortonworks_Reg</fullName>
        <description>Notify BD of Hortonworks Reg</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Deal_Reg_Email_Templates/BDS_Hortonworks_Notification</template>
    </alerts>
    <alerts>
        <fullName>Send_Ack_for_HW</fullName>
        <description>Send Acknowledgement to Submitter</description>
        <protected>false</protected>
        <recipients>
            <field>Partner_Account_Rep_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Deal_Reg_Email_Templates/BDS_Deal_Reg_Lead_Ack</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_Lead_Owner_to_HW_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>BD_Deal_Reg</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Lead Owner to HW Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Lead in Labs Queue %3E48 Hours</fullName>
        <active>true</active>
        <description>Workflow to notify the Labs team that a Lead has been in the Labs Queue for more than 48 hours.</description>
        <formula>AND(  Owner:Queue.Id = "00GU0000001Lskl",  Original_Lead_Source_Description__c = "Labs_Website_ContactUs_Submission"  )</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Lead_in_Labs_Queue_48_hours_2</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Lead.CreatedDate</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
