<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Article_Owner_Creator_of_Approval_Status_Update</fullName>
        <ccEmails>no-reply@pivotal.io</ccEmails>
        <description>Notify Article Creator of Approval Status Update</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Knowledge_Article/Support_BizOps_Knowledge_Approval_Status_Update</template>
    </alerts>
    <fieldUpdates>
        <fullName>Published_from_Approval</fullName>
        <field>Notes__c</field>
        <formula>"Published from Approval"</formula>
        <name>Published from Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatus_Admin_Approval_Rejected</fullName>
        <description>Update Approval Status to 'Admin Approval Rejected'</description>
        <field>Approval_Status__c</field>
        <literalValue>Admin Approval Rejected</literalValue>
        <name>UpdateStatus: Admin Approval Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatus_Approved_for_Publication</fullName>
        <description>Update Approval Status to 'Approved for Publication'</description>
        <field>Approval_Status__c</field>
        <literalValue>Approved for Publication</literalValue>
        <name>UpdateStatus: Approved for Publication</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatus_Content_Approval_Submitted</fullName>
        <description>Update Approval Status to 'Submitted for Content Approval'</description>
        <field>Approval_Status__c</field>
        <literalValue>Submitted for Content Approval</literalValue>
        <name>UpdateStatus: Content Approval Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatus_Content_Approved</fullName>
        <description>Update Approval Status to 'Approved Content Submitted for Admin Approval'</description>
        <field>Approval_Status__c</field>
        <literalValue>Approved Content Submitted for Admin Approval</literalValue>
        <name>UpdateStatus: Content Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatus_Content_Rejected</fullName>
        <description>Update Approval Status to 'Content Approval Rejected'</description>
        <field>Approval_Status__c</field>
        <literalValue>Content Approval Rejected</literalValue>
        <name>UpdateStatus: Content Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatus_Recalled_by_Submitter</fullName>
        <description>Update Approval Status to 'Recalled by Submitter'</description>
        <field>Approval_Status__c</field>
        <literalValue>Recalled_by_Submitter</literalValue>
        <name>UpdateStatus: Recalled by Submitter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Summary_Field</fullName>
        <description>Update the standard Summary field with Article Number, Original Publication Date (Legacy Articles from ZenDesk) OR First Published Date (For Newly Created Articles), and Article Author.</description>
        <field>Summary</field>
        <formula>"Article Number: " &amp;
RIGHT( ArticleNumber, 4) &amp;
" ■ "  &amp;

"Publication Date: "&amp;

IF(ISBLANK(Original_Publication_Date__c),
   IF(ISBLANK(FirstPublishedDate),

/* If NEITHER Original Publication Date (Zendesk) OR First Publication Date (Salesforce) available Default to Today's Date */

CASE(MONTH(TODAY()),
1,"January ",
2,"February ",
3,"March ",
4,"April ",
5,"May ",
6,"June ",
7,"July ",
8,"August ",
9,"September ",
10,"October ",
11,"November ",
12,"December ",
"")
&amp;
TEXT(DAY(TODAY()))
&amp;
", "
&amp;
TEXT(YEAR(TODAY()))


,


/* If First Published Date (Salesforce) is available, update Summary to First Published Date  */      

CASE(MONTH( DATEVALUE(FirstPublishedDate) ),
1,"January ",
2,"February ",
3,"March ",
4,"April ",
5,"May ",
6,"June ",
7,"July ",
8,"August ",
9,"September ",
10,"October ",
11,"November ",
12,"December ",
"")
&amp;
TEXT(DAY(DATEVALUE(FirstPublishedDate)))
&amp;
", "
&amp;
TEXT(YEAR(DATEVALUE(FirstPublishedDate)))

)
,
/* If Original Publication Date (ZenDesk Legacy Date) is available, update Summary to Original Publication Date */

CASE(MONTH(Original_Publication_Date__c),
1,"January ",
2,"February ",
3,"March ",
4,"April ",
5,"May ", 
6,"June ",
7,"July ",
8,"August ",
9,"September ",
10,"October ",
11,"November ",
12,"December ",
"")
&amp;
TEXT(DAY(Original_Publication_Date__c))
&amp;
", "
&amp;
TEXT(YEAR(Original_Publication_Date__c))
)


&amp;
" ■ "  &amp;
"Author: " &amp;
IF( ISBLANK(Article_Author_Lookup__c) ,
        Article_Author__c,
        Article_Author_Lookup__r.FirstName&amp;" "&amp; Article_Author_Lookup__r.LastName
   )</formula>
        <name>Update Summary Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <knowledgePublishes>
        <fullName>Publish_Article</fullName>
        <action>PublishAsNew</action>
        <label>Publish Article</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <rules>
        <fullName>Update Standard Summary with Article Number%2C Publication Date%2C and Author</fullName>
        <actions>
            <name>Update_Summary_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Standard Summary with Article Number, Original Publication Date (Legacy Articles from ZenDesk) OR First Published Date (For Newly Created Articles), and Article Author.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
