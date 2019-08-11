<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Big_Deal_Close_Date_Change</fullName>
        <description>Big Deal Close Date Change</description>
        <protected>false</protected>
        <recipients>
            <field>Opp_Owner_s_Manager_s_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>sfautomation@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Big_Deal_Close_Date_Change</template>
    </alerts>
    <alerts>
        <fullName>Data_Science_Booked_Email_Alert</fullName>
        <description>Data Science Booked Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ezuniga@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sfautomation@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Data_Science_Booked_Email_Alert</template>
    </alerts>
    <alerts>
        <fullName>Data_Science_ML_Alert</fullName>
        <description>Data Science MC Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ezuniga@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sfautomation@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Data_Science_ML_Alert</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_for_Opportunity_Bookings</fullName>
        <description>Email Alert for Opportunity Bookings</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>aphung@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>asapronov2@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>briviere@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cbraney@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ctam@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>cwant@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>elandon@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>gfenech@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jgorman@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mhennessy@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pjoorabchi@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tarnold@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sfautomation@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Email_Alert_for_Opportunity_Bookings</template>
    </alerts>
    <alerts>
        <fullName>IoT_terms_mentioned</fullName>
        <description>IoT terms mentioned</description>
        <protected>false</protected>
        <recipients>
            <recipient>rarni@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sfautomation@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Mobile_or_IoT_Opp</template>
    </alerts>
    <alerts>
        <fullName>Labs_Booked_Email_Alert</fullName>
        <description>Labs Booked Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>aettinger@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>aluttschyn@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dgoudreau@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jjahnke@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jknowles@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jwhitford@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>krobinson@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mbarinek@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rschmitt@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>wserino@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sfautomation@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Labs_Booked_Email_ALert</template>
    </alerts>
    <alerts>
        <fullName>Labs_ML_Email_Alert</fullName>
        <description>Labs ML Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>aluttschyn@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dgoudreau@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jknowles@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mbarinek@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mkahn@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mrussell@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Labs_ML_Email_Alert</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Booked_Email_Alert_when_MSC_1129_is_booked</fullName>
        <description>Opportunity - Booked Email Alert when Spring One(MSC-1129) is booked</description>
        <protected>false</protected>
        <recipients>
            <recipient>cayoung@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kefird@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sfautomation@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SF_Internal_Support/Email_Alert_for_MSC_booked_alerts</template>
    </alerts>
    <alerts>
        <fullName>PCF_Booked_Email_Alert</fullName>
        <description>PCF Booked Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>ezuniga@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>iandrews@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sfautomation@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/PCF_Booked_Email_ALert</template>
    </alerts>
    <alerts>
        <fullName>PCF_MC_Commit_Alert</fullName>
        <description>PCF MC/Commit Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>rarni@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sfautomation@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/PCF_MC_Alert</template>
    </alerts>
    <alerts>
        <fullName>PCF_Services_Booked_Email_Alert</fullName>
        <description>PCF Services Booked Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>dcicciarelli@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jfitzgerald@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mkahn@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mrussell@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sfautomation@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/PCF_Services_Booked_Email_ALert</template>
    </alerts>
    <alerts>
        <fullName>Renewal_Reminder</fullName>
        <description>Renewal Reminder</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>sfautomation@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Quote_Approval/RenewalReminder</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_when_Total_PAL_0_and_opportunity_is_Booked</fullName>
        <ccEmails>no-reply@pivotal.io</ccEmails>
        <description>Send Email when Total PAL &gt; 0 and opportunity is Booked</description>
        <protected>false</protected>
        <senderAddress>sfautomation@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SF_Internal_Support/Opportunity_PAL_Services_Booked_Email_Alert</template>
    </alerts>
    <alerts>
        <fullName>Services_Booked_Email_Alert</fullName>
        <ccEmails>no-reply@pivotal.io</ccEmails>
        <description>Services Booked Email Alert</description>
        <protected>false</protected>
        <senderAddress>sfautomation@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Services_Booked_Email_Alert</template>
    </alerts>
    <alerts>
        <fullName>Sub_Booked_Email_Alert</fullName>
        <description>Subscription Booked Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>pshea2@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sfautomation@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Subscription_Confirmation/Sub_Booked_Email_Alert</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approve_checkbox_update</fullName>
        <field>Approved__c</field>
        <literalValue>1</literalValue>
        <name>Approve checkbox update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Custom_Service_Attached</fullName>
        <field>Custom_Services_Attached__c</field>
        <literalValue>1</literalValue>
        <name>Check Custom Service Attached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Data_Science_Attached</fullName>
        <field>Data_Science_Attached__c</field>
        <literalValue>1</literalValue>
        <name>Check Data Science Attached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Education_Attached</fullName>
        <field>Education_Attached__c</field>
        <literalValue>1</literalValue>
        <name>Check Education Attached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Forecast_Box</fullName>
        <field>Forecast__c</field>
        <literalValue>1</literalValue>
        <name>Check Forecast Box</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Implementation_Services_Attached</fullName>
        <field>Implementation_Services_Attached__c</field>
        <literalValue>1</literalValue>
        <name>Check Implementation Services Attached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Value_Add_Services_Attached</fullName>
        <field>Value_Add_Services_Attached__c</field>
        <literalValue>1</literalValue>
        <name>Check Value Add Services Attached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Close_Date_Last_Changed_Date</fullName>
        <field>Close_Date_Last_Changed_Date__c</field>
        <formula>today()</formula>
        <name>Close Date Last Changed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pivotal_Labs_Engagement_SELECTED2</fullName>
        <field>Pivotal_Labs_Engagement__c</field>
        <literalValue>1</literalValue>
        <name>Pivotal Labs Engagement SELECTED 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Prior_Close_Date</fullName>
        <field>Prior_Close_Date__c</field>
        <formula>PRIORVALUE(CloseDate)</formula>
        <name>Prior Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Booked_to_False</fullName>
        <field>Booked__c</field>
        <literalValue>0</literalValue>
        <name>Set Booked to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Close_Date_to_TODAY</fullName>
        <description>Set Close Date to Today</description>
        <field>CloseDate</field>
        <formula>TODAY()</formula>
        <name>Set Close Date to TODAY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Core_Order_Processor_to_blank</fullName>
        <field>Core_Order_Processed__c</field>
        <name>Set Core Order Processor to None</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_SO_to_blank</fullName>
        <field>Sales_Order_Number__c</field>
        <name>Set SO# to blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Truncate_Name_Field_at_100</fullName>
        <field>Name</field>
        <formula>LEFT(Name, 100)</formula>
        <name>Truncate Name Field at 100</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Approve_when_recalled</fullName>
        <description>The approve checkbox will be unchecked if the Approval process is recalled</description>
        <field>Approved__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Approve when recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Custom_Service_Attached</fullName>
        <field>Custom_Services_Attached__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Custom Service Attached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Data_Science_Attached</fullName>
        <field>Data_Science_Attached__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Data Science Attached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Education_Attach</fullName>
        <field>Education_Attached__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Education Attach</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Forecast_Box</fullName>
        <field>Forecast__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Forecast Box</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Implementation_Services_Attached</fullName>
        <field>Implementation_Services_Attached__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Implementation Services Attached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Pivotal_Labs_Engagement</fullName>
        <field>Pivotal_Labs_Engagement__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Pivotal Labs Engagement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_Value_Add_Services_Attached</fullName>
        <field>Value_Add_Services_Attached__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck Value Add Services Attached</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opp_Name_with_Account</fullName>
        <field>Name</field>
        <formula>Account_Name__c + ": " + Name</formula>
        <name>Update Opp Name with Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quarter_Start_Date_Date</fullName>
        <field>Quarter_Start_Date_Date__c</field>
        <formula>Quarter_Start_Date__c</formula>
        <name>Update Quarter Start Date-Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Week_Year_Num</fullName>
        <field>Week_Year_Num__c</field>
        <name>Update Week-Year-Num</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Add Account Name to Opportunity Name</fullName>
        <actions>
            <name>Update_Opp_Name_with_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Opportunity Name does not start with Account Name, prepend Account Name-</description>
        <formula>LEFT(Name, LEN( Account.Name )) &lt;&gt;  Account.Name</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Add to MC on Close%2FCommit</fullName>
        <actions>
            <name>Check_Forecast_Box</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Add to MC for commit/closed deals with close dates &gt;= 07/01/13</description>
        <formula>OR(  (  ISPICKVAL(Forecast_Status__c, "Closed" )  &amp;&amp; NOT(Forecast__c)  ),   (  ISPICKVAL( Forecast_Status__c , "Commit")  &amp;&amp; NOT(Forecast__c)  )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Big Deal Close Date Change</fullName>
        <actions>
            <name>Big_Deal_Close_Date_Change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>if forecasted ACV over $400k and close date changes by more than 4 months</description>
        <formula>CloseDate - Prior_Close_Date__c &gt;= 120 &amp;&amp;  Total_Forecasted_ACV__c &gt;= 400000</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clear fields on Clone</fullName>
        <actions>
            <name>Set_SO_to_blank</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>If a Opp is cloned, clear the SO# and other opp specific fields.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Custom Service Attached %3D FALSE</fullName>
        <actions>
            <name>Uncheck_Custom_Service_Attached</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Product_Concat__c</field>
            <operation>notContain</operation>
            <value>Custom Service for Pivotal Data,Custom Service for Pivotal Cloud Foundry</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Custom_Services_Attached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If a line item is removed for one of the Custom Service, update the checkbox for Custom Service Attached.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Custom Service Attached %3D TRUE</fullName>
        <actions>
            <name>Check_Custom_Service_Attached</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Product_Concat__c</field>
            <operation>contains</operation>
            <value>Custom Service for Pivotal Data,Custom Service for Pivotal Cloud Foundry</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Custom_Services_Attached__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>If a line item is added for one of the Custom Service, update the checkbox for Custom Service Attached.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Data Science Attached %3D FALSE</fullName>
        <actions>
            <name>Uncheck_Data_Science_Attached</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Product_Concat__c</field>
            <operation>notContain</operation>
            <value>Data Science</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Data_Science_Attached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If a line item is removed for one of the Data Science, update the checkbox for Data Science, Attached.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Data Science Attached %3D TRUE</fullName>
        <actions>
            <name>Check_Data_Science_Attached</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Product_Concat__c</field>
            <operation>contains</operation>
            <value>Data Science</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Data_Science_Attached__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>If a line item is added for one of the Data Science, update the checkbox for Data Science Attached.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Data Science Booked Email Alert</fullName>
        <actions>
            <name>Data_Science_Booked_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For any DS deal that is Booked, an email will be sent to relevant users.</description>
        <formula>ISPICKVAL(StageName,"Booked") &amp;&amp; Total_Agile_DS__c &gt; 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Data Science ML Email Alert</fullName>
        <actions>
            <name>Data_Science_ML_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For any deal that is checked or unchecked ML that contains Agile - DS, an email will be sent to the relevant folks.</description>
        <formula>AND(ISCHANGED(Forecast__c),Total_Agile_DS__c &gt; 0)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Education Attached %3D FALSE</fullName>
        <actions>
            <name>Uncheck_Education_Attach</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Product_Concat__c</field>
            <operation>notContain</operation>
            <value>Education,Course</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Education_Attached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If a line item is removed for one of the Education, update the checkbox for Education Attached.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Education Attached %3D TRUE</fullName>
        <actions>
            <name>Check_Education_Attached</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Product_Concat__c</field>
            <operation>contains</operation>
            <value>Education,Course</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Education_Attached__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>If a line item is added for one of the Education, update the checkbox for Education Attached.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email Alert for Opportunity Bookings</fullName>
        <actions>
            <name>Email_Alert_for_Opportunity_Bookings</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Booked</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Implementation Services Attached %3D FALSE</fullName>
        <actions>
            <name>Uncheck_Implementation_Services_Attached</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Product_Concat__c</field>
            <operation>notContain</operation>
            <value>Onboarding,Dojo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Implementation_Services_Attached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If a line item is removed for one of the Implementation Services, update the checkbox for Implementation Services Attached.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Implemetation Services Attached %3D TRUE</fullName>
        <actions>
            <name>Check_Implementation_Services_Attached</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Product_Concat__c</field>
            <operation>contains</operation>
            <value>Onboarding,Dojo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Implementation_Services_Attached__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>If a line item is added for one of the Implementation Services, update the checkbox for Implementation Services Attached.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Labs Attach %3D FALSE</fullName>
        <actions>
            <name>Uncheck_Pivotal_Labs_Engagement</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Product_Concat__c</field>
            <operation>notContain</operation>
            <value>Pivotal Labs</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Labs Attach %3D TRUE</fullName>
        <actions>
            <name>Pivotal_Labs_Engagement_SELECTED2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Product_Concat__c</field>
            <operation>contains</operation>
            <value>Pivotal Labs</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Labs Booked Email ALert</fullName>
        <actions>
            <name>Labs_Booked_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For any Labs related deal that is Booked, an email will be sent to relevant users.</description>
        <formula>ISPICKVAL(StageName,"Booked") &amp;&amp; Total_Pivotal_Labs__c &gt; 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Labs ML Email Alert</fullName>
        <actions>
            <name>Labs_ML_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For any deal that is checked or unchecked ML that contains Labs, an email will be sent to the relevant folks.</description>
        <formula>CONTAINS(Product_Concat__c, "Pivotal Labs")   &amp;&amp;  ISCHANGED(Forecast__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Booked Email alert for PAL Services</fullName>
        <actions>
            <name>Send_Email_when_Total_PAL_0_and_opportunity_is_Booked</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This workflow sends an email alert for serviceops@pivotal.io when PAL services are booked.</description>
        <formula>ISPICKVAL(StageName, "Booked") &amp;&amp; Total_PAL__c &gt; 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity - Booked Email alert for Spring One Conference</fullName>
        <actions>
            <name>Opportunity_Booked_Email_Alert_when_MSC_1129_is_booked</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(StageName) &amp;&amp; ISPICKVAL( StageName ,'Booked') &amp;&amp;  CONTAINS(Product_Concat__c, 'SpringOne Platform Conference ')</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PCF Booked Email ALert</fullName>
        <actions>
            <name>PCF_Booked_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>For any PCF related deal that is Booked, an email will be sent to relevant users.</description>
        <formula>ISPICKVAL(StageName, "Booked") &amp;&amp;  Total_Pivotal_CF_Product__c  &gt; 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PCF MC%2FCommit Email ALert</fullName>
        <actions>
            <name>PCF_MC_Commit_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For any PCF deal that is changed to MC true or Commit, an email will be sent to Arni</description>
        <formula>( (Forecast__c &amp;&amp;  ISCHANGED( Forecast__c )) ||  (ISPICKVAL(ForecastCategoryName, "Commit") &amp;&amp; ISCHANGED( ForecastCategoryName)) ) &amp;&amp;  Total_Pivotal_CF_Product__c  &gt; 0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PCF Services Booked Email ALert</fullName>
        <actions>
            <name>PCF_Services_Booked_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For any PCF Services related deal that is Booked, an email will be sent to relevant users.</description>
        <formula>ISPICKVAL(StageName, "Booked") &amp;&amp;  Total_PaaS_Services__c  &gt; 0</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Remove MC when Opp leaves Close%2FCommit</fullName>
        <actions>
            <name>Uncheck_Forecast_Box</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Remove MC when Opp moves to Pipeline. This is to uncheck the forecast checkbox that gets checked in another workflow when an opp enters Close or Commit</description>
        <formula>NOT  (ISPICKVAL(Forecast_Status__c, "Closed" ) ||  ISPICKVAL( Forecast_Status__c , "Commit") ||  ISPICKVAL( Forecast_Status__c , "Upside")  )   &amp;&amp; Forecast__c == True</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Services Booked Email Alert</fullName>
        <actions>
            <name>Services_Booked_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For any services deal that is Booked, an email will be sent to relevant users.</description>
        <formula>ISPICKVAL(StageName,"Booked") &amp;&amp; 
(Total_BCS__c &gt; 0 || Total_Pivotal_Labs__c &gt; 0 ||  Total_Data_Services__c &gt;0 ||  Total_Edu__c &gt; 0 ||  Total_PaaS_Services__c &gt; 0 ||  Total_Transformation__c &gt; 0 ||  Total_Agile_DS__c &gt; 0 ||  Total_CSD__c &gt; 0 ||  Total_App_Tx__c &gt; 0 ||  CONTAINS(Product_Concat__c, 'Custom'))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Booked to False if Open</fullName>
        <actions>
            <name>Set_Booked_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
            <value>Booked</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Closed Date on Closed Lost Opps</fullName>
        <actions>
            <name>Set_Close_Date_to_TODAY</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the Closed Date to TODAY() on Closed Lost opps to prevent closed opps with future close dates.</description>
        <formula>AND(CloseDate &gt; TODAY(), ISPICKVAL(StageName,'Closed Lost'))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Sub Booked Email Alert</fullName>
        <actions>
            <name>Sub_Booked_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>For any Subscription deal that is Booked, an email will be sent to relevant users.</description>
        <formula>ISPICKVAL(StageName,"Booked") &amp;&amp; 
(Total_App__c &gt; 0 || 
Total_Data_Product__c &gt; 0 || 
Total_Pivotal_CF_Product__c &gt; 0)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Truncate Opp Name to 100 Chars</fullName>
        <actions>
            <name>Truncate_Name_Field_at_100</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>LEN(Name)&gt;100</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update from Week Year and Quarter Start Date formulas</fullName>
        <actions>
            <name>Update_Quarter_Start_Date_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Week_Year_Num</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Quarter_Start_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Value Add Services Attached %3D FALSE</fullName>
        <actions>
            <name>Uncheck_Value_Add_Services_Attached</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Product_Concat__c</field>
            <operation>notContain</operation>
            <value>TAM,Customer Solutions Director,DSE,Assurance,Advisory Service,Architecture Review,Transformation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Value_Add_Services_Attached__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If a line item is removed for one of the Value Add Services, update the checkbox for Value Add Services Attached.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Value Add Services Attached %3D TRUE</fullName>
        <actions>
            <name>Check_Value_Add_Services_Attached</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Product_Concat__c</field>
            <operation>contains</operation>
            <value>TAM,Customer Solutions Director,DSE,Assurance,Advisory Service,Architecture Review,Transformation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Value_Add_Services_Attached__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>If a line item is added for one of the Value Add Services, update the checkbox for Value Add Services Attached.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
