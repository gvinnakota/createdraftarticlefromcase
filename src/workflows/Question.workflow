<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>X01R0P0000001Mdv</fullName>
        <description>Priority</description>
        <field>Priority</field>
        <literalValue>high</literalValue>
        <name>chatter_answers_num_subscriptions_above_</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>chatter_answers_no_best_reply_within_time_limit_wf</fullName>
        <active>false</active>
        <formula>NOT(ISPICKVAL(Priority,'high')) &amp;&amp; ISBLANK(BestReplyId)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>X01R0P0000001Mdv</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Question.CreatedDate</offsetFromField>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>chatter_answers_num_subscriptions_above_limit_wf</fullName>
        <actions>
            <name>X01R0P0000001Mdv</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>NOT(ISPICKVAL(Priority,'high')) &amp;&amp; ISBLANK(BestReplyId) &amp;&amp; NumSubscriptions &gt;= 20</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
