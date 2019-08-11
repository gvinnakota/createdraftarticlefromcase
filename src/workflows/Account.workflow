<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Account_Governance_Email_Alert_AMER</fullName>
        <description>Account Governance Email Alert - AMER</description>
        <protected>false</protected>
        <recipients>
            <recipient>briviere@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cbraney@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cwant@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jgorman@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pjoorabchi@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Account_Governance_Template</template>
    </alerts>
    <alerts>
        <fullName>Account_Governance_Email_Alert_AMERISR</fullName>
        <description>Account Governance Email Alert - AMER ISR</description>
        <protected>false</protected>
        <recipients>
            <recipient>cbraney@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cwant@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jgorman@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pjoorabchi@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Account_Governance_Template</template>
    </alerts>
    <alerts>
        <fullName>Account_Governance_Email_Alert_APJ</fullName>
        <description>Account Governance Email Alert - APJ</description>
        <protected>false</protected>
        <recipients>
            <recipient>ctam@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Account_Governance_Template</template>
    </alerts>
    <alerts>
        <fullName>Account_Governance_Email_Alert_DEF</fullName>
        <ccEmails>no-reply@pivotal.io</ccEmails>
        <description>Account Governance Email Alert - Default</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Account_Governance_Template</template>
    </alerts>
    <alerts>
        <fullName>Account_Governance_Email_Alert_EMEA</fullName>
        <description>Account Governance Email Alert - EMEA</description>
        <protected>false</protected>
        <recipients>
            <recipient>mhennessy@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sclayton@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Account_Governance_Template</template>
    </alerts>
    <alerts>
        <fullName>Account_Governance_Email_Alert_LABSTART</fullName>
        <description>Account Governance Email Alert - Labs Startup</description>
        <protected>false</protected>
        <recipients>
            <recipient>kdahl@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Account_Governance_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Account_Owner_Admin</fullName>
        <field>OwnerId</field>
        <lookupValue>pivotaladmin@pivotal.io</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Account - Owner Admin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>RPS_Account</fullName>
        <apiVersion>37.0</apiVersion>
        <description>RPS Screening Account Name</description>
        <endpointUrl>https://sf.visualcompliance.com/RPS_SF_WS/AccountNotificationService.asmx</endpointUrl>
        <fields>BillingCity</fields>
        <fields>BillingCountry</fields>
        <fields>BillingState</fields>
        <fields>BillingStreet</fields>
        <fields>Id</fields>
        <fields>Name</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>sfintegration@pivotal.io</integrationUser>
        <name>RPS Account</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Accounts Owned by Admin</fullName>
        <actions>
            <name>Account_Owner_Admin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>All Account need to be owned by Administrator</description>
        <formula>! (Owner.Id = '005U0000001kPdX')</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>RPS Account Change</fullName>
        <actions>
            <name>RPS_Account</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <description>Call RPS for New or Modified Account using Visual Compliance [PT # 126414043]</description>
        <formula>OR(isNew(), isChanged(Name), isChanged(BillingCountry))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
