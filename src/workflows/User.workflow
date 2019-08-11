<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Federation_ID_changed</fullName>
        <description>Federation ID changed</description>
        <protected>false</protected>
        <recipients>
            <recipient>dweller@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>hgeisert@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Administrative/Federation_ID_udpated</template>
    </alerts>
    <alerts>
        <fullName>Pivotal_Account_Verification_Alert</fullName>
        <description>Pivotal Account Verification</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Pivotal_Account_Verification_Template</template>
    </alerts>
    <alerts>
        <fullName>Send_Verification_Email_to_User</fullName>
        <description>Send Verification Email to User</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Pivotal_Account_Verification_Template</template>
    </alerts>
    <alerts>
        <fullName>User_Deactivated_On_DPL_Status</fullName>
        <description>User Deactivated On DPL Status</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Denied_Party_List_DPL_User_Blocked_Email_Notification</template>
    </alerts>
    <rules>
        <fullName>Send UAA Verification Link to the User</fullName>
        <actions>
            <name>Send_Verification_Email_to_User</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISNULL(UAA_Verification_Link__c)),     ISCHANGED(UAA_Verification_Link__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>User Deactivation on DPL Status</fullName>
        <actions>
            <name>User_Deactivated_On_DPL_Status</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(    Contact.DPL_Status__c = "Restricted",    IsActive = FALSE    )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
