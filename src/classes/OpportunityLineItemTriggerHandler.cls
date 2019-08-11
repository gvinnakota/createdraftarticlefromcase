public with sharing class OpportunityLineItemTriggerHandler extends TriggerHandler {
    public OpportunityLineItemTriggerHandler() {
    }

    /* Context Overrides */

    protected override void beforeInsert() {
        updateOpportunityTeamMembers();
    }

    protected override void beforeUpdate() {
        updateOpportunityTeamMembers();
    }

    protected override void afterInsert() {
         updateProductConcatOnOpp();
    }

    protected override void afterDelete() {
        updateProductConcatOnOpp();
    }

    /* Private Methods */

    private void updateOpportunityTeamMembers() {
        List<Id> oppIds = new List<Id>();
        List<String> oppRegions = new List<String>();

        for (OpportunityLineItem oli : (List<OpportunityLineItem>) Trigger.new) {
            if (oli.Product_Portfolio__c == 'PaaS' || oli.Product_Portfolio__c == 'PaaS - Edu' || oli.Product_Portfolio__c == 'PaaS - Eng Director' || oli.Product_Portfolio__c == 'PaaS - Services' || oli.Product_Portfolio__c == 'Agile - Tx') {
                oppIds.add(oli.OpportunityId);
            }
        }

        List<Opportunity> matchingOpps = [SELECT Id, OwnerId, Is_ISR__c FROM Opportunity WHERE Id IN :oppIds];
        for (Opportunity opp : matchingOpps) {
            // added null check
            if (opp.Is_ISR__c!=null)
                oppRegions.add(opp.Is_ISR__c);
        }


        if (matchingOpps.size() > 0 && oppRegions.size() > 0) {
            List<CNS_Region__c> cnsRegionList = [SELECT Id, CNS_Rep__r.Id, Region__c from CNS_Region__c where Region__c IN :oppRegions and CNS_Rep__r.isactive = true];
            List<OpportunityTeamMember> oppTeam = createOpportunityTeamMembers(matchingOpps, cnsRegionList);

            if (oppTeam.size() > 0) {
                insert oppTeam;
            }
        }
    }

    private List<OpportunityTeamMember> createOpportunityTeamMembers(List<Opportunity> matchingOpps, List<CNS_Region__c> cnsRegionList) {
        List<OpportunityTeamMember> oppTeam = new List<OpportunityTeamMember>();

        for (Opportunity opp : matchingOpps) {
            for (CNS_Region__c cnsRegion : cnsRegionList) {
                if (opp.OwnerId != cnsRegion.CNS_Rep__r.Id && opp.Is_ISR__c == cnsRegion.Region__c && (opp.OwnerId == UserInfo.getUserId() || UserInfo.getProfileId() == '00eU0000000sKBKIA2')) {
                    OpportunityTeamMember otm = new OpportunityTeamMember();
                    otm.OpportunityId = opp.Id;
                    otm.UserId = cnsRegion.CNS_Rep__r.Id;
                    otm.TeamMemberRole = 'Cloud Native Sales Rep';
                    otm.OpportunityAccessLevel = 'Edit';
                    oppTeam.add(otm);
                }
            }
        }

        return oppTeam;
    }

    private void updateProductConcatOnOpp() {
        List<Id> oppIds = new List<Id>();
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();

        if(Trigger.isInsert) {
            oppLineItems = (List<OpportunityLineItem>) Trigger.new;
        } else if(Trigger.isDelete) {
            oppLineItems = (List<OpportunityLineItem>) Trigger.old;
        }

        for (OpportunityLineItem oppLine : oppLineItems) {
            oppIds.add(oppLine.OpportunityId);
        }

        Map<Id, Opportunity> oppsToConcat = new Map<Id, Opportunity>([SELECT Id, Product_Concat__c, (SELECT Id, Product_Name__c FROM OpportunityLineItems) FROM Opportunity WHERE Id IN :oppIds]);

        for(Opportunity opp : oppsToConcat.values()) {
            opp.Product_Concat__c = null;

            for(OpportunityLineItem oppLine : opp.OpportunityLineItems) {
                if (String.isEmpty(opp.Product_Concat__c)) {
                    opp.Product_Concat__c = oppLine.Product_Name__c;
                } else if (!opp.Product_Concat__c.contains(oppLine.Product_Name__c)) {
                    opp.Product_Concat__c += '; ' + oppLine.Product_Name__c;
                }
            }
        }

        update oppsToConcat.values();
    }
}