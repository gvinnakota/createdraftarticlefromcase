<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_Internal_Case_Team_of_Owner_Comment</fullName>
        <description>ANNE TEST Alert Internal Case Team of Owner Comment</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Executive</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Anchor</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Customer Engineer</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Customer Support Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Customer Support Representative</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Designated Support Engineer</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Engagement Director</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Escalation Management</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Executive Management</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Observer</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Pivotal Cloud Foundry Solutions</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Pivotal Data Engineer</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Platform Architect</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Product Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>R&amp;D Engineer</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Support Product Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Support Success</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Notify_Case_Team_on_Adding_New_Comment</template>
    </alerts>
    <alerts>
        <fullName>Automated_notification_alert</fullName>
        <description>Automated notification alert</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Automated_Case_Received_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Customer_Service_Email_Ticket_pivotal_io_alert</fullName>
        <description>Customer Service Email Ticket - pivotal.io alert</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Automated_Case_Received_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>EMC_Federation_Email_Ticket_Alert</fullName>
        <description>EMC Federation Email Ticket Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/EMC_Federation_Email_Ticket_Template</template>
    </alerts>
    <alerts>
        <fullName>EM_Acceptance_of_Request_for_EM_Engagement</fullName>
        <description>EM Acceptance of Request for EM Engagement</description>
        <protected>false</protected>
        <recipients>
            <recipient>sfintegration@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/EM_Acceptance_of_Request_for_EM_Engagement</template>
    </alerts>
    <alerts>
        <fullName>EM_Acceptance_of_Request_for_SP_EM_Engagement</fullName>
        <description>EM Acceptance of Request for SP EM Engagement</description>
        <protected>false</protected>
        <recipients>
            <recipient>sfintegration@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/EM_Acceptance_of_Request_for_SP_EM_Engagement</template>
    </alerts>
    <alerts>
        <fullName>Email_Notification_for_cases_through_EH_SP_email_escalation_channel</fullName>
        <description>Email Notification for cases through EH/SP email escalation channel</description>
        <protected>false</protected>
        <recipients>
            <recipient>ssmalldon@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Email_Template_for_cases_through_EH_SP_email_escalation_channel</template>
    </alerts>
    <alerts>
        <fullName>Email_notification_to_the_CSR_CE_team_that_an_Update_Request_was_made</fullName>
        <description>Email notification to the CSR &amp; CE team that an Update Request was made.</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Executive</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Anchor</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Customer Support Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Customer Support Representative</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Designated Support Engineer</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Engagement Director</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Escalation Management</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Executive Management</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Observer</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Pivotal Cloud Foundry Solutions</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Pivotal Data Engineer</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Platform Architect</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Support Product Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Request_Update_Template_for_CSR_and_CE</template>
    </alerts>
    <alerts>
        <fullName>Email_notification_to_the_user_who_requested_update</fullName>
        <description>Email notification to the user who requested update.</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Request_Update</template>
    </alerts>
    <alerts>
        <fullName>Entitlements_Milestone_missed</fullName>
        <description>Entitlements Milestone missed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Entitlements</template>
    </alerts>
    <alerts>
        <fullName>Internal_notification_for_Support_Escalations</fullName>
        <description>Internal notification for Support Escalations</description>
        <protected>false</protected>
        <recipients>
            <recipient>amarshall@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ssmalldon@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Internal_notification_for_Support_Escalations</template>
    </alerts>
    <alerts>
        <fullName>New_EH_SP_Support_Case</fullName>
        <description>New EH/SP Support Case</description>
        <protected>false</protected>
        <recipients>
            <recipient>ssmalldon@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/New_EH_SP_Support_Case</template>
    </alerts>
    <alerts>
        <fullName>Non_Technical_Portal_Case</fullName>
        <description>Non Technical Portal Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Automated_Case_Received_Email_Template</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_EH_SP_group_about_severity</fullName>
        <description>Notification to EH/SP group about severity</description>
        <protected>false</protected>
        <recipients>
            <recipient>ssmalldon@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Notification_for_EH_SP_and_severity</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_escalation_group_for_severity_1</fullName>
        <description>Notification to escalation group for severity 1</description>
        <protected>false</protected>
        <recipients>
            <recipient>sfintegration@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Notification_for_case_with_severity1</template>
    </alerts>
    <alerts>
        <fullName>Notify_Case_Contact</fullName>
        <description>Notify Case Contact</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Comment_Notification_for_case_contact</template>
    </alerts>
    <alerts>
        <fullName>Notify_Case_Contact_External_Case_Team</fullName>
        <description>Notify Case Contact &amp; External Case Team</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer Contact</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Comment_Notification_for_case_contact</template>
    </alerts>
    <alerts>
        <fullName>Notify_Case_Owner_of_assignment_Alert</fullName>
        <description>Notify Case Owner of assignment Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Notify_Case_Owner_of_assignment_Template</template>
    </alerts>
    <alerts>
        <fullName>Notify_Case_Owner_of_comment_update_alert</fullName>
        <description>Notify Case Owner &amp; Case Team of Case Feed Comment Update Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Account Executive</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Anchor</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Customer Engineer</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Customer Support Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Customer Support Representative</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Designated Support Engineer</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Engagement Director</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Escalation Management</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Executive Management</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Observer</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Pivotal Cloud Foundry Solutions</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Pivotal Data Engineer</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Platform Architect</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Product Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>R&amp;D Engineer</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Support Product Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Support Success</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Notify_Case_Owner_Case_Team_of_Case_Feed_Comment_Update</template>
    </alerts>
    <alerts>
        <fullName>Notify_Case_Owner_of_reopened_ticket</fullName>
        <description>Notify Case Owner of reopened ticket</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Notify_Case_Owner_of_reopened_ticket</template>
    </alerts>
    <alerts>
        <fullName>Notify_Queue_of_Updated_Unassigned_Ticket_Data_Support</fullName>
        <description>Notify Queue of Updated Unassigned Ticket - Data Support</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Notify_Queue_of_Updated_Unassigned_Ticket_Template</template>
    </alerts>
    <alerts>
        <fullName>Notify_Queue_of_Updated_Unassigned_Ticket_GSS_Escalations</fullName>
        <description>Notify Queue of Updated Unassigned Ticket - GSS Escalations</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Notify_Queue_of_Updated_Unassigned_Ticket_Template</template>
    </alerts>
    <alerts>
        <fullName>Notify_Success_Team_of_Case_Creation</fullName>
        <description>Notify Success Team of Case Creation</description>
        <protected>false</protected>
        <recipients>
            <recipient>Support Success</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Notify_success_team</template>
    </alerts>
    <alerts>
        <fullName>Notifying_user_that_the_case_has_been_created_by_EH_SP_escalation</fullName>
        <description>Notifying user that the case has been created by EH SP escalation</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Notifying_user_that_the_case_has_been_created_by_EH_SP_escalation</template>
    </alerts>
    <alerts>
        <fullName>PWS_Email_Response_Internal_Alert</fullName>
        <description>PWS Email Response - Internal Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>PWS_Support</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/PWS_Email_Response_Internal_Template</template>
    </alerts>
    <alerts>
        <fullName>PoC_Email_Ticket_Alert</fullName>
        <description>PoC Email Ticket Alert</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/PoC_Email_Ticket</template>
    </alerts>
    <alerts>
        <fullName>Reminder_Request_for_EscalationManager_Engagement</fullName>
        <description>Reminder - Request for EscalationManager Engagement</description>
        <protected>false</protected>
        <recipients>
            <recipient>sfintegration@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Reminder_Request_for_EM_Engagement</template>
    </alerts>
    <alerts>
        <fullName>Reminder_Request_for_SP_EM_Engagement</fullName>
        <description>Reminder - Request for SP EM Engagement</description>
        <protected>false</protected>
        <recipients>
            <recipient>sfintegration@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Reminder_Request_for_SP_EM_Engagement</template>
    </alerts>
    <alerts>
        <fullName>Request_for_Escalation_Management_Engagement</fullName>
        <description>Request for Escalation Management Engagement</description>
        <protected>false</protected>
        <recipients>
            <recipient>sfintegration@pivotal.io</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Request_for_EM_Engagement</template>
    </alerts>
    <alerts>
        <fullName>Request_for_SP_EM_Engagement</fullName>
        <ccEmails>no-reply@pivotal.io</ccEmails>
        <description>Request for SP EM Engagement</description>
        <protected>false</protected>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Request_for_SP_EM_Engagement</template>
    </alerts>
    <alerts>
        <fullName>Request_received</fullName>
        <description>Portal Technical Case Received Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All_Support/Request_received</template>
    </alerts>
    <alerts>
        <fullName>Survey_Email</fullName>
        <description>Survey Email</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>no-reply@pivotal.io</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Pivotal_Support_Surveys/Survey_Case_Resolution_Customer_Survey</template>
    </alerts>
    <fieldUpdates>
        <fullName>Request_Update_Value_change</fullName>
        <field>Requestupdate__c</field>
        <literalValue>0</literalValue>
        <name>Request Update Value change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Case_Solved_Time_c_on_Case_Reopen</fullName>
        <description>Clear the Date/Time Stamp of Case_Solved_Time__c when a Case is Reopened (Case Status updated from Solved to any Open Status Value).</description>
        <field>Case_solved_time__c</field>
        <name>Reset Case_Solved_Time__c on Case Reopen</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Notify_Case_Team</fullName>
        <field>Notify_Success_Team__c</field>
        <literalValue>0</literalValue>
        <name>Reset Notify Case Team</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_EM_Disengage_Time</fullName>
        <field>EM_Disengage_Time__c</field>
        <formula>NOW()</formula>
        <name>Set EM Disengage Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Escalation_Accept_Time</fullName>
        <field>Escalation_Accept_Time__c</field>
        <formula>NOW()</formula>
        <name>Set Escalation Accept Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Escalation_Request_Time</fullName>
        <field>Escalation_Request_Time__c</field>
        <formula>NOW()</formula>
        <name>Set Escalation Request Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Origin</fullName>
        <description>https://www.pivotaltracker.com/story/show/164335871 Updates case origin from EMAIL - EHSP to just EMAIL to not affect reporting based on story requirements</description>
        <field>Origin</field>
        <literalValue>Email</literalValue>
        <name>Update Case Origin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>EU_Safe_Harbour</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Case Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Owner_To_SP_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Special_Practices_CSR</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Case Owner To SP Queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Citi_Case_Priority_to_Severity_1</fullName>
        <field>Priority</field>
        <literalValue>Severity 1 - Critical</literalValue>
        <name>Update Citi Case Priority to  Severity 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Solved_Time_on_Case</fullName>
        <description>used to update casesolved time field</description>
        <field>Case_solved_time__c</field>
        <formula>Now()</formula>
        <name>Update Solved Time on Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_Closed</fullName>
        <description>Change Status of case to closed</description>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Update Status to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_ThreadId_Text</fullName>
        <field>ThreadId_Text__c</field>
        <formula>ThreadId__c</formula>
        <name>Update ThreadId Text</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>updatespecialhandeling</fullName>
        <description>this field update will set Case: Special Handling to: Special Practices (US Citizen, US Soil)</description>
        <field>Special_Handling_Type__c</field>
        <literalValue>Special Practices (US Citizen, US Soil)</literalValue>
        <name>updatespecialhandeling</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ANNE TEST Notify Case Team of Case Owner Comment</fullName>
        <actions>
            <name>Alert_Internal_Case_Team_of_Owner_Comment</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(ISCHANGED(Comments__c),NOT(ISPICKVAL( Status , 'Closed')),OwnerId = $User.Id )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Automated notification trigger</fullName>
        <actions>
            <name>Automated_notification_alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>The workflow is used to send a notification when a case is created from email-to-case except for federation,on demand services,customer service,support escalations,poc email-to-cases</description>
        <formula>OR(
  (
    AND(
     InboundEmailAlias__c!=null,
     OR(
        ISNEW(),
        ISCHANGED(InboundEmailAlias__c)
        ),
     InboundEmailAlias__c != PRIORVALUE(InboundEmailAlias__c),
     AND( 
        InboundEmailAlias__c != 'federation-support@pivotal.io',
        InboundEmailAlias__c != 'poc-support@pivotal.io',
        InboundEmailAlias__c != 'customer-service@pivotal.io',
        InboundEmailAlias__c != 'support-escalations@pivotal.io', 
        InboundEmailAlias__c != 'ehsp-escalations@pivotal.io',
        InboundEmailAlias__c != 'ehsp-support@pivotal.io') 
         )
        ),
     (AND(
         ISNEW(),
         ISPICKVAL( Origin , 'Email'),
         ParentId!=NULL
         )
       )
    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Case-Special Handling field on case to%3A Special Practices %28US Citizen%2C US Soil%29</fullName>
        <actions>
            <name>updatespecialhandeling</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This work flow is used to update Case: Special Handling to:  Special Practices (US Citizen, US Soil)</description>
        <formula>or( (isnew()&amp;&amp;OwnerId=$Label.Special_Practices_CSR),(ischanged(OwnerId)&amp;&amp;OwnerId =$Label.Special_Practices_CSR))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Change of Request Update</fullName>
        <actions>
            <name>Email_notification_to_the_CSR_CE_team_that_an_Update_Request_was_made</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Email_notification_to_the_user_who_requested_update</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Requestupdate__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Request_Update_Value_change</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Citi Severity 1 Cases</fullName>
        <actions>
            <name>Update_Citi_Case_Priority_to_Severity_1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>equals</operation>
            <value>Citi</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Pivotal_Customer_Number__c</field>
            <operation>equals</operation>
            <value>AN-0026302</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Clear Case_Solved_Time%5F%5Fc on Case</fullName>
        <actions>
            <name>Reset_Case_Solved_Time_c_on_Case_Reopen</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear the Date/Time stamp when the Case Status is updated from Solved to any OPEN Status.</description>
        <formula>AND(     ISCHANGED(Status),     PRIORVALUE(Status) = 'Solved',     NOT(ISPICKVAL(Status,'Closed'))    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Customer Service Email Ticket - pivotal%2Eio</fullName>
        <actions>
            <name>Customer_Service_Email_Ticket_pivotal_io_alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(InboundEmailAlias__c!=null,
ISCHANGED(InboundEmailAlias__c),
InboundEmailAlias__c != PRIORVALUE(InboundEmailAlias__c) ,  InboundEmailAlias__c ='customer-service@pivotal.io'
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>EH%2FSP Escalation Accept Time</fullName>
        <actions>
            <name>EM_Acceptance_of_Request_for_SP_EM_Engagement</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Escalation_Accepted__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Special_Handling_Type__c</field>
            <operation>equals</operation>
            <value>Executive Handling (Non-BRICE),"Special Practices (US Citizen, US Soil)"</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EH%2FSP Escalation request Time</fullName>
        <actions>
            <name>Request_for_SP_EM_Engagement</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Escalation_Accepted__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Special_Handling_Type__c</field>
            <operation>equals</operation>
            <value>Executive Handling (Non-BRICE),"Special Practices (US Citizen, US Soil)"</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Escalation_Management_Escalation__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reminder_Request_for_SP_EM_Engagement</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Escalation_Request_Time__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>EM Disengage Time</fullName>
        <actions>
            <name>Set_EM_Disengage_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.EM_Disengage__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EMC Federation Email Ticket</fullName>
        <actions>
            <name>EMC_Federation_Email_Ticket_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(InboundEmailAlias__c!=null,ISCHANGED(InboundEmailAlias__c),InboundEmailAlias__c != PRIORVALUE(InboundEmailAlias__c), InboundEmailAlias__c ='federation-support@pivotal.io')</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Escalation Accept Time</fullName>
        <actions>
            <name>EM_Acceptance_of_Request_for_EM_Engagement</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Escalation_Accept_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Escalation_Accepted__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Escalation Request Time</fullName>
        <actions>
            <name>Request_for_Escalation_Management_Engagement</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Set_Escalation_Request_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Escalation_Management_Escalation__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Escalation_Accepted__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Special_Handling_Type__c</field>
            <operation>notEqual</operation>
            <value>Executive Handling (Non-BRICE),"Special Practices (US Citizen, US Soil)"</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Reminder_Request_for_EscalationManager_Engagement</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Escalation_Request_Time__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>INACTIVE Notify Case Owner %26 Case Team of Case Feed Comment Update</fullName>
        <actions>
            <name>Notify_Case_Owner_of_comment_update_alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(      ISCHANGED(Comments__c),    OwnerId &lt;&gt; $User.Id,    ISPICKVAL(Is_this_internal_Pivotal_external_Custom__c, "Internal Pivotal"))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Internal notification for Support Escalations</fullName>
        <actions>
            <name>Internal_notification_for_Support_Escalations</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>support-escalations.dev@pivotal.io</description>
        <formula>ISPICKVAL(Origin, 'Email - Support Escalations')</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Move Case Solved To Closed</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solved</value>
        </criteriaItems>
        <description>System to move a case to Closed status (Read only) 7 days after a ticket has moved to solved status.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Status_to_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Non Technical Portal Case</fullName>
        <actions>
            <name>Non_Technical_Portal_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Community</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Non-Technical</value>
        </criteriaItems>
        <description>Non-Technical case created via Portal</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notification for EH%2FSP with severity</fullName>
        <actions>
            <name>Notification_to_EH_SP_group_about_severity</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Origin, 'Email - EHSP Support')</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notification for cases through EH%2FSP email escalation channel</fullName>
        <actions>
            <name>Email_Notification_for_cases_through_EH_SP_email_escalation_channel</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>New_EH_SP_Support_Case</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notifying_user_that_the_case_has_been_created_by_EH_SP_escalation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Origin, 'Email - EHSP Escalations')</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notification for escalation group for severity1</fullName>
        <actions>
            <name>Notification_to_escalation_group_for_severity_1</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 AND 3)</booleanFilter>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Severity 1 - Critical</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Special_Handling__c</field>
            <operation>notEqual</operation>
            <value>Executive Handling (Non-BRICE)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Special_Handling__c</field>
            <operation>notEqual</operation>
            <value>Special Practices (US Citizen,US Soil)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notify Case Contact %26 External Case Team of Case Feed Comment Update</fullName>
        <actions>
            <name>Notify_Case_Contact_External_Case_Team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 
NOT(ISPICKVAL( Status , 'Closed')), 
ISCHANGED( Case_Comments__c ), 
Contact.HasOptedOutOfEmail = FALSE, 
Contact.Interact_with_Community__c = TRUE, 
/* ContactId &lt;&gt; $User.ContactId, */ 
ISPICKVAL(Is_this_internal_Pivotal_external_Custom__c, "External Customer") 
)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Case Contact of received request</fullName>
        <actions>
            <name>Request_received</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>OR( AND(InboundEmailAlias__c!=null,
ISCHANGED(InboundEmailAlias__c),
InboundEmailAlias__c != PRIORVALUE(InboundEmailAlias__c) , 
InboundEmailAlias__c='ehsp-support@pivotal.io'),  

AND  (  ISPICKVAL(Origin , 'Community'),  RecordType.Name = 'Technical',  ISNEW() ,  $Organization.Name &lt;&gt; 'Talkdesk'  )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Case Owner %26 Case Team of Case Feed Comment Update</fullName>
        <actions>
            <name>Notify_Case_Owner_of_comment_update_alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(      ISCHANGED(Comments__c),    OwnerId &lt;&gt; $User.Id,    ISPICKVAL(Is_this_internal_Pivotal_external_Custom__c, "Internal Pivotal")    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Case Owner of assignment</fullName>
        <actions>
            <name>Notify_Case_Owner_of_assignment_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>OR(ISNEW(),ISCHANGED(OwnerId))&amp;&amp; OwnerId &lt;&gt; $User.Id &amp;&amp; BEGINS(OwnerId , '005')</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Case Owner of comment update</fullName>
        <actions>
            <name>Notify_Case_Owner_of_comment_update_alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED(Comments__c),NOT(ISPICKVAL( Status , 'Closed')),OwnerId &lt;&gt; $User.Id )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Case Owner of reopened ticket Trigger</fullName>
        <actions>
            <name>Notify_Case_Owner_of_reopened_ticket</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 
   OwnerId &lt;&gt; $User.Id,
   ISCHANGED(Status), 
   OR(
      PRIORVALUE(Status)='Solved',
      PRIORVALUE(Status)='Closed'
     ),
   ISPICKVAL(Status,'Open')
    )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Queue of Updated Unassigned Ticket - Data Support</fullName>
        <actions>
            <name>Notify_Queue_of_Updated_Unassigned_Ticket_Data_Support</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(    NOT(ISPICKVAL( Status , 'Solved')),  ISCHANGED( Comments__c) ,   OR(         ISPICKVAL(Products__c , 'Pivotal VRP'),         ISPICKVAL(Products__c , 'Pivotal Command Center'),         ISPICKVAL(Products__c , 'Pivotal Chorus'),         ISPICKVAL(Products__c , 'MADlib'),         ISPICKVAL(Products__c , 'Pivotal GPText'),         ISPICKVAL(Products__c , 'Pivotal HD'),         ISPICKVAL(Products__c , 'Pivotal Greenplum'),         ISPICKVAL(Products__c , 'Open Source Redis'),         ISPICKVAL(Products__c , 'Pivotal Greenplum Command Center'),         ISPICKVAL(Products__c , 'Pivotal HDP'),         ISPICKVAL(Products__c , 'Pivotal HDB'),         ISPICKVAL(Products__c , 'Pivotal R'),         ISPICKVAL(Products__c , 'Open Source PostgreSQL'),         ISPICKVAL(Products__c , 'Datometry Workload Manager'),         ISPICKVAL(Products__c , 'Pivotal Greenplum Chorus'),         ISPICKVAL(Products__c , 'Pivotal GemFire'),         ISPICKVAL(Products__c , 'Pivotal GemFire XD')   ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Notify Queue of Updated Unassigned Ticket - Support Escalations</fullName>
        <actions>
            <name>Notify_Queue_of_Updated_Unassigned_Ticket_Data_Support</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notify_Queue_of_Updated_Unassigned_Ticket_GSS_Escalations</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( OR(NOT(ISPICKVAL( Status , 'Solved')),NOT(ISPICKVAL( Status , 'Closed'))), 								 IsChanged(Comments__c), 								 Owner:Queue.DeveloperName  ='Support_Escalation'		 				)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PWS Email Response - Internal Trigger</fullName>
        <actions>
            <name>PWS_Email_Response_Internal_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(InboundEmailAlias__c!=null,
ISCHANGED(InboundEmailAlias__c),
InboundEmailAlias__c != PRIORVALUE(InboundEmailAlias__c) ,    
OR(   InboundEmailAlias__c  = 'pws-account@pivotal.io',   
InboundEmailAlias__c  = 'pws-feedback@pivotal.io',  
InboundEmailAlias__c = 'pws-support@pivotal.io',  InboundEmailAlias__c = 'support@run.pivotal.io' )  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PoC Email Ticket Trigger</fullName>
        <actions>
            <name>PoC_Email_Ticket_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(InboundEmailAlias__c!=null,ISCHANGED(InboundEmailAlias__c),InboundEmailAlias__c != PRIORVALUE(InboundEmailAlias__c) , InboundEmailAlias__c='poc-support@pivotal.io')</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Route EHSP Cases To SP Queue</fullName>
        <actions>
            <name>Update_Case_Owner_To_SP_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( OwnerId ='00G0P000002dug4UAA',  ISPICKVAL(Origin,'Email'),  IsESHP__c =TRUE)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Route EUSafe Cases To EU Queue</fullName>
        <actions>
            <name>Update_Case_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Special_Handling__c</field>
            <operation>equals</operation>
            <value>EU - Safe Harbour</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Success Team - Email Notification - Email Alert V2</fullName>
        <actions>
            <name>Notify_Success_Team_of_Case_Creation</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Notify_Case_Team</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Success Team - Email Notification - Email Alert V2</description>
        <formula>Notify_Success_Team__c = true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Case Origin</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>contains</operation>
            <value>Email -</value>
        </criteriaItems>
        <description>https://www.pivotaltracker.com/story/show/164089172 - Update the case origin when it hits the queue to change email addresses to just EMAIL</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Solved Time on Case</fullName>
        <actions>
            <name>Update_Solved_Time_on_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>used to update casesolved time field</description>
        <formula>AND(ISCHANGED(Status),ispickval(Status,'solved'))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update ThreadId Text</fullName>
        <actions>
            <name>Update_ThreadId_Text</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.ThreadId__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Workflow for creation of case</fullName>
        <actions>
            <name>Automated_notification_alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 
   CaseNumber &lt;&gt; Null,  
   OR( ISPICKVAL(Origin, 'Phone') ,
       ISPICKVAL(Origin, 'Service Cloud')
      )
    )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
