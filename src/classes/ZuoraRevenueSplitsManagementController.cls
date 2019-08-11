/**
 * Created by klukawski on 12/13/18.
 */

public with sharing class ZuoraRevenueSplitsManagementController {
    public CronTrigger scheduledJob {get; set;}
    public Boolean enableSchedule {get; set;}
    public Boolean enableAbort {get; set;}
    @TestVisible
    private String cronJobName = 'Create Revenue Splits';

    public Revenue_Splits_Request__c request {get; set;}

    public ZuoraRevenueSplitsManagementController(){
        List<CronTrigger> jobs = [
                SELECT Id, NextFireTime, CronJobDetail.Name, CronExpression
                FROM CronTrigger
                WHERE CronJobDetail.Name = :cronJobName
        ];

        if(jobs.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Job is not scheduled, use the "Schedule" button to fix this'));
            enableSchedule = true;
            enableAbort = false;
        } else {
            scheduledJob = jobs.get(0);
            enableSchedule = false;
            enableAbort = true;
        }

        if(ApexPages.currentPage().getParameters().containsKey('id')){
            ApexPages.addMessage(new ApexPages.Message(
                    ApexPages.Severity.INFO,
                    'Request has been submitted, you can check it\'s status here: <a href="/'
                            + ApexPages.currentPage().getParameters().get('id')
                            + '">Link</a>')
            );
        }

        request = new Revenue_Splits_Request__c(
                Type__c = 'Manual'
        );
    }

    public PageReference cancel(){
        return new PageReference('/');
    }

    public PageReference schedule(){
        System.schedule(cronJobName, '0 0 * * * ?', new ZuoraRevenueSplitHelper());
        PageReference ref = Page.ZuoraRevenueSplitsManagement;
        ref.setRedirect(true);
        return ref;
    }

    public PageReference abort(){
        System.abortJob(scheduledJob.Id);
        PageReference ref = Page.ZuoraRevenueSplitsManagement;
        ref.setRedirect(true);
        return ref;
    }

    public PageReference runManually(){
        insert request;

        PageReference ref = Page.ZuoraRevenueSplitsManagement;
        ref.setRedirect(true);
        ref.getParameters().put('id', request.Id);
        return ref;
    }
}