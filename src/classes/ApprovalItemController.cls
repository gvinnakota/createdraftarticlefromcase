public with sharing class ApprovalItemController {

    public String relatedRecordId { get; set; }

    public List<ApprovalStep> getAllApprovalStep() {
        List<ApprovalStep> lstApprovalStep = new List<ApprovalStep>();
        ProcessInstance processInstance = getProcessInstance();
        Map<Id, ProcessNode> mpProcessNode = getProcessNode(processInstance);

        if (processInstance == null) return lstApprovalStep;

        for (ProcessInstanceStep stepInstance : processInstance.Steps) {
            ApprovalStep approvalStep = new ApprovalStep(stepInstance, mpProcessNode.get(stepInstance.StepNodeID));
            lstApprovalStep.add(approvalStep);
        }
        return lstApprovalStep;
    }


    public Map<Id, ProcessNode> getProcessNode(ProcessInstance processInstance) {
        if (processInstance == null) return null;

        return new Map<Id, ProcessNode>([
                SELECT Id, Name
                FROM ProcessNode
                WHERE ProcessDefinitionId = :processInstance.ProcessDefinitionId
        ]);
    }

    private ProcessInstance getProcessInstance() {
        List<ProcessInstance> lstProcessInstance = [
                SELECT Id, ProcessDefinitionID, (SELECT StepStatus, StepNodeId, OriginalActor.Name, ActorId, Actor.Name, Comments, CreatedDate, CreatedById, CreatedBy.Name FROM Steps ORDER BY CreatedDate DESC)
                FROM ProcessInstance
                WHERE TargetObjectId = :relatedRecordId
        ];

        if (lstProcessInstance.size() == 0) {
            return null;
        }

        return lstProcessInstance[0];
    }

    public class ApprovalStep {
        public ProcessInstanceStep instanceStep { get; set; }
        public ProcessNode nodeStep { get; set; }

        public ApprovalStep(ProcessInstanceStep instanceStep, ProcessNode node) {
            this.instanceStep = instanceStep;
            this.nodeStep = node;
        }
    }
}