public class PACDataLoaderController{
    public List<PAC__c> pacs {get;set;}
    public Integer all {get;set;}
    public Integer unassigned {get;set;}
    public Integer allocated {get;set;}

    public Boolean isSandbox {
        get{
            if(isSandbox == null){
                isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return isSandbox;
        }
        set;
    }

    public Integer assigned {get;set;}

    private List<AggregateResult> inventory;

    public Integer inventoryLength {
        get{
            return inventory.size() * 12 + 300;
        }
        private set;
    }

    public String inventoryChartLabels {
        get{
            List<String> labels = new List<String>();
            for(AggregateResult res: inventory){
                labels.add(String.escapeSingleQuotes(res.get('Product__c') + ' with quantity ' + res.get('quantity') + ' pcs and duration of ' + res.get('duration') + ' years'));
            }
            return JSON.serialize(labels);
        }
        private set;
    }

    public String inventoryChartValues {
        get{
            List<Integer> values = new List<Integer>();
            for(AggregateResult res: inventory){
                values.add(Integer.valueOf(res.get('remainingKeys')));
            }
            return JSON.serialize(values);
        }
        private set;
    }

    public Document file{get; set;}
    public PACProvider pacProvider {get; private set;}

    public Boolean isFileSelected{
        get {
            return pacProvider != null;
        }
        private set;
    }

    public PACDataLoaderController(){
        if(ApexPages.currentPage().getParameters().containsKey('id')){
            System.debug('file selected');
            file = [SELECT Body, Name FROM Document WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
            pacProvider = new PACProvider(file.Body.toString());
        }else{
            pacs = [SELECT Id, Status__c FROM PAC__c];

            all = pacs.size();
            unassigned = 0;
            allocated = 0;
            assigned = 0;

            inventory = [
                    SELECT COUNT(Id) remainingKeys, Product__c, Grouping_Field__c, MIN(Quantity__c) quantity, MIN(Duration__c) duration
                    FROM PAC__c
                    WHERE Status__c = 'Unassigned'
                    GROUP BY Product__c, Grouping_Field__c
                    ORDER BY Product__c ASC, MIN(Duration__c) ASC, MIN(Quantity__c) ASC
            ];

            for(PAC__c pac: pacs){
                if(pac.Status__c == 'Unassigned'){
                    unassigned++;
                }
                if(pac.Status__c == 'Allocated'){
                    allocated++;
                }
                if(pac.Status__c == 'Assigned'){
                    assigned++;
                }
            }
            System.debug('file not selected');
            file = new Document();
        }
    }

    public List<PACHelper.PACWrapper> getPACWrappers() {
        return pacProvider.getAllPACWrappers();
    }

    public PageReference submitFile(){
        file.FolderId = UserInfo.getUserId();
        insert file;
        pacProvider = new PACProvider(file.Body.toString());
        PageReference pr = Page.PACDataLoader;
        pr.getParameters().put('id', file.Id);
        return pr;
    }

    public Boolean getContainsDuplicates() {
        return (pacProvider != null) && pacProvider.containsDuplicates();
    }

    public PageReference saveRecords(){
        pacProvider.saveRecords();
        return new PageReference('/' + PAC__c.SObjectType.getDescribe().getKeyPrefix());
    }

    public PageReference deletePACs(){
        delete pacs;
        return getRedirect();
    }

    public PageReference unassignAll(){
        for(PAC__c pac: pacs){
            pac.Status__c = 'Unassigned';
            pac.Allocation_Date__c = null;
            pac.Assignment_Date__c = null;
            pac.Quote__c = null;
        }
        update pacs;
        return getRedirect();
    }

    public PageReference unassignAllocated(){
        for(PAC__c pac: pacs){
            if(pac.Status__c == 'Allocated'){
                pac.Status__c = 'Unassigned';
                pac.Allocation_Date__c = null;
                pac.Assignment_Date__c = null;
                pac.Quote__c = null;
            }
        }
        update pacs;
        return getRedirect();
    }

    public PageReference unassignAssigned(){
        for(PAC__c pac: pacs){
            if(pac.Status__c == 'Assigned'){
                pac.Status__c = 'Unassigned';
                pac.Allocation_Date__c = null;
                pac.Assignment_Date__c = null;
                pac.Quote__c = null;
            }
        }
        update pacs;
        return getRedirect();
    }

    private PageReference getRedirect(){
        PageReference ref = Page.PACDataLoader;
        ref.setRedirect(true);
        return ref;
    }
}