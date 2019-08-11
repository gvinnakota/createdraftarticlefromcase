public with sharing class TaskTriggerHandler extends TriggerHandler {
    public TaskTriggerHandler() {}

    /* Context Overides */
    protected override void beforeInsert() {updateTaskType();
    }
    protected override void afterInsert() {updateLeadStatus();
    }
    
    /* Private Methods */
    private void updateTaskType() {
        //String userRoleStr = [SELECT Id, Name FROM UserRole WHERE Id = :userinfo.getUserRoleId()].Name;
        
        /*25 Sept To fix list has no rows to assign error*/
        String userRoleStr;
        for(UserRole usr : (list<UserRole>)[SELECT Id, Name FROM UserRole WHERE Id = :userinfo.getUserRoleId()]){userRoleStr = usr.Name;        
        }
        for (Task taskObj : (List<Task>)Trigger.new) {if (!String.isBlank(userRoleStr) && userRoleStr.contains('ISR')) {if (taskObj.Subject.startsWithIgnoreCase('Message Sent:')) {taskObj.type = 'ISR-Email Sent';
                }
                if (taskObj.Subject.startsWithIgnoreCase('Reply:')) {taskObj.type = 'ISR-Email Response Received';
                }
            }
        }
    }

    private void updateLeadStatus() {List<Id> leadIds =  new List<Id>();
        List<Lead> updateLeads = new List<Lead>();
        for (Task taskObj : (List<Task>)Trigger.new) {if(!String.isBlank(taskObj.type)){if (taskObj.type.startsWithIgnoreCase('isr') && taskObj.whoId!=null && taskObj.whoId.getsobjectType() == Lead.sobjectType) {leadIds.add(taskObj.whoId);
                }
            }
        }
        List<Lead> leadList = [Select Id,status,OwnerId from Lead where Id IN : leadIds AND (Status = 'New' OR Status = 'Raw' OR Status = 'Back to Marketing')];
        for(Lead leadObj:leadList) {if (leadObj.OwnerId == UserInfo.getUserId()){leadObj.Status  = 'Working';
                updateLeads.add(leadObj);
            }
        }
        try {if(updateLeads.size()>0) {update updateLeads;
            }
        }
        catch (Exception e){ErrorLog.CreateER(e);
        }
    }
}