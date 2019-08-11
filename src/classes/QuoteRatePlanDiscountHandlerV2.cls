global class QuoteRatePlanDiscountHandlerV2{
   
    //Default Approver, 1st Manager, 2nd Manager, 3rd Manager, 4th Manager, Owner, Primary Approver, VP, SVP,
    private static string DefaultApprover ='Default Approver';
    private static string ManagerApprover ='Manager';
    private static string VPApprover ='VP'; 
    private static string SVPApprover ='SVP';
    private static string PrimaryApprover ='Primary Approver';
    private static string Role ='Role'; 
    private static string DefaultTheater ='AMER'; 
    private static string Specific ='Specific';
    private static string splitchar='##';
    
    private static Integer DefaultApproverCount = 1;
    private static Integer PrimaryApproverCount =3;
    private static Integer VPApproverCount = 3; 
    private static Integer SVPApproverCount = 1;
    private static Integer ManagerApproverCount = 3;

    private static set<string> PrimaryApproverSet {get; set;}
    private static set<string> VPApproverSet {get; set;}
    private static set<string> ManagerApproverSet {get; set;}
    private static set<string> DefaultApproverSet {get; set;}
    private static set<string> SVPApproverSet {get; set;}

        
     webservice static boolean RemapApprovers(string quoteId) {
       
       set<id> quoteList= new set<id>();
       string actionType ='isUpsert';
       quoteList.add(quoteId);
       
       system.debug('sun quoteId' + quoteId);
       system.debug('sun quoteList' + quoteList);
       
         
       list<zqu__Quote__c> quoteListTemp = [select id, Approval__c from zqu__Quote__c where id IN:quoteList AND Approval__c NOT IN ('In Process','Approved')];
       if (quoteListTemp.size()<=0)
       {
           return true;
       }
         
       UpdateQuoteApproverAndSummary(quoteList, actionType );
       
       return true; 
    }
    
    @auraEnabled
    global static boolean  RemapApproversLightning(string quoteId) {
       
       set<id> quoteList= new set<id>();
       string actionType ='isUpsert';
       quoteList.add(quoteId);
       
       system.debug('sun quoteId' + quoteId);
       system.debug('sun quoteList' + quoteList);
       
         
       list<zqu__Quote__c> quoteListTemp = [select id, Approval__c from zqu__Quote__c where id IN:quoteList AND Approval__c NOT IN ('In Process','Approved')];
       if (quoteListTemp.size()<=0)
       {
           return false;
       }
         
       UpdateQuoteApproverAndSummary(quoteList, actionType );
       
       return true; 
    }
    
    
    
    public static map<id,zqu__Quote__c> queryzquQuoteMap(set<id> quoteList){
          Map<id, zqu__Quote__c> zquQuoteMap;

        zquQuoteMap =  new Map<id, zqu__Quote__c>([select id, OwnerId, Owner_Region__c,  Approval__c,  Approval_Needed__c, Delivery_Office_Region__c, Delivery_Office__c from zqu__Quote__c where id IN:quoteList AND Approval__c NOT IN ('In Process','Approved')]);

         if(Test.isRunningTest())
             zquQuoteMap = new Map<id, zqu__Quote__c>([select id, OwnerId, Owner_Region__c, Approval__c,  Approval_Needed__c, Delivery_Office_Region__c, Delivery_Office__c from zqu__Quote__c]);

     return zquQuoteMap;
    }


    public static list<Quote_Approver_Mapping__c> queryQuoteApproverMap(list<string> ATLst){
        return new list<Quote_Approver_Mapping__c>([SELECT OwnerId,Id,Approval_Level__c,Approval_Type__c,Approver_Type__c,Approver__c,Discount_Limit__c,Display_Order__c,Email_CC__c,Office__c,Product_Key__c,Region__c,Services__c,Theater__c,VP_Approver__c,VP_Discount_Limit__c,Name,Approver_Hierarchy__c FROM Quote_Approver_Mapping__c Quote_Approver_Mapping__c where Approval_Type__c IN:ATLst OR Approval_Type__c = 'All' order by Display_Order__c]);
    }


    public static list<AggregateResult> queryzquQuoteRatePlan(set<id> quoteList, list<string> prdLst){
         return new list<AggregateResult>([select zqu__Quote__c quote, zqu__ProductRatePlan__r.zqu__Product__r.ApprovalType__c  ApprovalType, max(ApproveDiscount__c) max, min(ApproveDiscount__c) min, count(ApproveDiscount__c) appCount from zqu__QuoteRatePlan__c where  zqu__Quote__c IN:quoteList AND Product_Key__c IN:prdLst AND zqu__ProductRatePlan__r.zqu__Product__r.ApprovalType__c != NULL group by zqu__Quote__c, zqu__ProductRatePlan__r.zqu__Product__r.ApprovalType__c order by zqu__Quote__c,zqu__ProductRatePlan__r.zqu__Product__r.ApprovalType__c ]);
        //return new list<AggregateResult>([ select zqu__Quote__c quote, Approval_Type__c ApprovalType, Product__r.Family ProductFamily, max(ApproveDiscount__c) max, min(ApproveDiscount__c) min, count(ApproveDiscount__c) appCount from zqu__QuoteRatePlan__c where  zqu__Quote__c IN:quoteList AND Product_Key__c IN:prdLst  group by zqu__Quote__c, Product__r.ApprovalType__c, Product__r.Family order by zqu__Quote__c, Product__r.ApprovalType__c ]);
    } 

  
     public static map<string,string> getproductServiceMap( set<id> quoteList){
 
        list<zqu__QuoteRatePlan__c> quoteRateplanProdList = [select Product_Rate_Plan_Product_Id__c from zqu__QuoteRatePlan__c where  zqu__Quote__c IN:quoteList];
        set<string> productIdSet = new set<string>();
        for(zqu__QuoteRatePlan__c prp: quoteRateplanProdList){
            productIdSet.add(prp.Product_Rate_Plan_Product_Id__c);
        }
         
        list<Product2> productList =[select ApprovalType__c, Services_Product__c from Product2 where id in: productIdSet];
        map<string,string> getproductServiceMapLocal = new map<string,string>();
        for(Product2 qrplan : productList){
           getproductServiceMapLocal.put(qrplan.ApprovalType__c,qrplan.Services_Product__c );
        }   
        
        return getproductServiceMapLocal;
     } 
        
    public static list<Quote_Discount_Summary__c> queryquoteDiscountSumList(set<id> quoteList, list<string> approvalTypeList){
        return new list<Quote_Discount_Summary__c>([select id, Approval_Type__c, Approval_Type_Count__c, Max_Discount__c, Min_Discount__c, Quote__c from Quote_Discount_Summary__c where Quote__c IN:quoteList AND Approval_Type__c IN:approvalTypeList]);
    }
     
 
    public static void UpdateQuoteApproverAndSummary(set<id> quoteList, string actionType){
            // Initialize
            // 
            // 
            // 
            
            system.debug('sun quoteList' + quoteList);
            system.debug('sun actionType' + actionType);
        
            map<string,Decimal> maxDiscountMap = new map<string,Decimal>();
            map<string,Decimal> minDiscountMap = new map<string, Decimal>();
            map<string,Integer> qouteRatePlanCountMap = new map<string, Integer>();

            map<id,map<string,string>> mapOfApproveType = new map<id,map<string,string>>();
            map<string, list<Quote_Approver_Mapping__c>> QuoteApproverMappingMap = new map<string, list<Quote_Approver_Mapping__c>>();
            map<string,Quote_Discount_Summary__c> discountSummaryMap = new map<string,Quote_Discount_Summary__c>();
            string excludeProductName ='SpringOne Platform Conference';

            PrimaryApproverSet = new set<string>();
            VPApproverSet = new set<string>();
            ManagerApproverSet = new set<string>();
            DefaultApproverSet = new set<string>();
            SVPApproverSet = new set<string>();

            list<string> prdLst =new list<string>();
            list<string> ATLst =new list<string>();
            Map<string, string> productServiceMap = new Map<string, string>();
            

            /**Start**/
             

            List<string> approvalTypeList= new list<string>();  
            map<string, list<zqu__QuoteRatePlan__c>> quoteIdQtRatePlanMap = new map<string, list<zqu__QuoteRatePlan__c>>();
            map<string,list<zqu__QuoteRatePlan__c>> quoteRatePlanMap = new map<string,list<zqu__QuoteRatePlan__c>>();

            // Check Quote Rate Plan 
            list<zqu__QuoteRatePlan__c> quoteRatePlanList = [select Id, zqu__Quote__c, Approval_Type__c, ApproveDiscount__c, Product_Key__c from zqu__QuoteRatePlan__c where zqu__Quote__c IN :quoteList];
            
            if (quoteRatePlanList.size() == 0)
            {
               return;
            }

            for(zqu__QuoteRatePlan__c quoteRatePlan :quoteRatePlanList){
                if(quoteIdQtRatePlanMap.containsKey(quoteRatePlan.zqu__Quote__c)){
                    quoteIdQtRatePlanMap.get(quoteRatePlan.zqu__Quote__c).add(quoteRatePlan);
                }else{
                    quoteIdQtRatePlanMap.put( quoteRatePlan.zqu__Quote__c, new list<zqu__QuoteRatePlan__c> { quoteRatePlan } );
                }
                if(quoteRatePlan.Approval_Type__c != null)
                    approvalTypeList.add(quoteRatePlan.Approval_Type__c);
            }

            for(String quoteId :quoteIdQtRatePlanMap.keyset()){
                list<zqu__QuoteRatePlan__c> quoteIdRPList = quoteIdQtRatePlanMap.get(quoteId);
                quoteRatePlanMap = getzquQuoteRatePlanMap(quoteIdRPList);
                
                system.debug('sun quoteRatePlanMap:'+quoteRatePlanMap);
            }


            /**End**/


            for(string quoteObj : quoteRatePlanMap.keySet()){
                
                system.debug('sun quoteObj:' + quoteObj);
            
                string[] st = quoteObj.split('##');
                ATLst.add(st[1]);
                prdLst.add(quoteObj);
            }
            
            // fetch Needed data
            //list<zqu__Quote__c> quoteOwnerRegionList = [select id, Owner_Region__c from zqu__Quote__c where Id IN:quoteList ];
            map<id,zqu__Quote__c> quoteMap = queryzquQuoteMap(quoteList);
            list<Quote_Approver_Mapping__c> quoteAppMappingList = queryQuoteApproverMap(ATLst);
            list<AggregateResult> quoteRatePalnAgreegateList = queryzquQuoteRatePlan(quoteList, prdLst);
            List<Quote_Discount_Summary__c> quoteDiscountSummaryList = queryquoteDiscountSumList(quoteList, approvalTypeList);
            
            set<Id> quoteOwnerIds = new set<Id>();

            productServiceMap = getproductServiceMap(quoteList);
            // fill approver quoteMapping map.
            for(Quote_Approver_Mapping__c qAppMapping: quoteAppMappingList){
                string mapKey = qAppMapping.Product_Key__c;    //+ splitchar + qAppMapping.Theater__c + splitchar + qAppMapping.Office__c+ splitchar + qAppMapping.Region__c;
                if(QuoteApproverMappingMap.containsKey(mapKey)){
                    QuoteApproverMappingMap.get(mapKey).add(qAppMapping);
                } else {
                  QuoteApproverMappingMap.put(mapKey, new List<Quote_Approver_Mapping__c>{qAppMapping});
                }
                quoteOwnerIds.add(qAppMapping.Approver__c);
            }

            // Fill Maps by Approval Type with Quote Id.
            for(AggregateResult agg: quoteRatePalnAgreegateList){
                zqu__Quote__c q= new zqu__Quote__c();
                q.id = (id) agg.get('quote');
                string max = (string) agg.get('quote');
                maxDiscountMap.put(agg.get('quote')+splitchar+ productServiceMap.get((string)agg.get('ApprovalType')) +splitchar+ agg.get('ApprovalType'),  (decimal)agg.get('max'));
                minDiscountMap.put(agg.get('quote')+splitchar+productServiceMap.get((string)agg.get('ApprovalType')) +splitchar+ agg.get('ApprovalType'), (decimal)agg.get('min'));
                qouteRatePlanCountMap.put(agg.get('quote')+splitchar+productServiceMap.get((string)agg.get('ApprovalType')) +splitchar+ agg.get('ApprovalType'), (integer)agg.get('appCount'));
            }      

            system.debug('maxDiscountMap+++  >>'+maxDiscountMap);
            system.debug('qouteRatePlanCountMap+++  >>'+qouteRatePlanCountMap);

            
            // Fill Quote owner region Map
            for(zqu__Quote__c quoteobj: quoteMap.Values()){
                quoteOwnerIds.add(quoteobj.OwnerId);
            }

            map<string, user> quoteOwnerIdMaps = getOwnerDetails(quoteOwnerIds);
            
            for(Quote_Discount_Summary__c DiscountSummary :quoteDiscountSummaryList){
                discountSummaryMap.put(DiscountSummary.quote__c+splitchar+DiscountSummary.approval_Type__c,DiscountSummary);
            }
            
            // declare variables; 
            string strQuote='';
            zqu__Quote__c quoteobj = null;
            list<Quote_Discount_Summary__c> DiscountSummaryList = new list<Quote_Discount_Summary__c>();
            Decimal maxDiscount = 0.0;
            Decimal minDiscount = 0.0;
            integer approvalCount = 0;
            string OppRegion ='';
            string OppOffice ='';
            string qutOwnerId ='';
            string strProductKey='';
            boolean firstTimeAtLoop = true;
            integer nthItem =0;
            integer totalItem = maxDiscountMap.KeySet().size()-1;

            // loop through the maxdiscount map which has the Quote and Approval Type
            for (string quoteApprovalTypeString: maxDiscountMap.KeySet()){
              firstTimeAtLoop = false;
            
              string[] quoteArray = quoteApprovalTypeString.split(splitchar);
              strQuote = quoteArray[0];
              strProductKey = quoteArray[1]+splitchar+quoteArray[2]; 
              maxDiscount = maxDiscountMap.get(quoteApprovalTypeString);
              minDiscount = minDiscountMap.get(quoteApprovalTypeString);
              approvalCount = qouteRatePlanCountMap.get(quoteApprovalTypeString);
              
              system.debug('quoteMap >>'+quoteMap);
             

              if(quoteMap.size()>0){

                  OppRegion = quoteMap.get(strQuote).Delivery_Office_Region__c;
                  OppOffice = quoteMap.get(strQuote).Delivery_Office__c;
                  qutOwnerId = quoteMap.get(strQuote).OwnerId;
                  
                  system.debug('strProductKey >>'+strProductKey);
                  system.debug('OppRegion >>'+OppRegion);
                  system.debug('OppOffice >>'+OppOffice);
                  system.debug('maxDiscount >>'+maxDiscount);
                  system.debug('QuoteApproverMappingMap >>'+QuoteApproverMappingMap);
                  system.debug('quoteOwnerIdMaps >>'+quoteOwnerIdMaps);

                  PrimaryApproverSet.addAll(FindQuoteApproverByApprovalType( strProductKey, OppRegion, OppOffice, Specific, PrimaryApprover,  minDiscount, maxDiscount, QuoteApproverMappingMap, quoteOwnerIdMaps, qutOwnerId ));

                  system.debug('sun PrimaryApproverSet:' + PrimaryApproverSet);
        
                  VPApproverSet.addAll(FindQuoteApproverByApprovalType( strProductKey, OppRegion, OppOffice, Specific, VPApprover,  minDiscount, maxDiscount, QuoteApproverMappingMap, quoteOwnerIdMaps, qutOwnerId ));
                 
                  ManagerApproverSet.addAll(FindQuoteApproverByApprovalType( strProductKey, OppRegion, OppOffice, Role, ManagerApprover,  minDiscount, maxDiscount, QuoteApproverMappingMap, quoteOwnerIdMaps, qutOwnerId ));
                 
                  SVPApproverSet.addAll(FindQuoteApproverByApprovalType( strProductKey, OppRegion, OppOffice, Specific, SVPApprover,  minDiscount, maxDiscount, QuoteApproverMappingMap, quoteOwnerIdMaps, qutOwnerId ));
                 
                  DefaultApproverSet.addAll(FindQuoteApproverByApprovalType( strProductKey, OppRegion, OppOffice, Specific, DefaultApprover,  minDiscount, maxDiscount, QuoteApproverMappingMap, quoteOwnerIdMaps, qutOwnerId ));

  
                  system.debug(strProductKey + ' -- ' + OppRegion + ' -- ' + OppOffice + ' -- ' +  Specific + ' -- ' +  PrimaryApprover + ' -- ' +   minDiscount + ' -- ' +  maxDiscount + ' -- ' +  QuoteApproverMappingMap + ' -- ' +  quoteOwnerIdMaps + ' -- ' +  qutOwnerId);
                  // find the next item's quote 
                  list<string> discountList = new list<string>();  
                  discountList.addAll(maxDiscountMap.KeySet());
                  string nextQuote='';
                  if(totalItem != nthItem){
                     nextQuote =  discountList[nthItem+1].split(splitchar)[0];
                  }
                      
                  //Get summary Discount to Update MIN and MAX
                  if(actionType == 'isUpsert')            
                    DiscountSummaryList.add(GetQuoteDiscountSummaryByQuotes(discountSummaryMap,strQuote,quoteArray[2],minDiscount,maxDiscount,approvalCount, actionType));
                  else if(actionType == 'isDelete')
                    DiscountSummaryList.add(GetQuoteDiscountSummaryByQuotes(discountSummaryMap,strQuote,quoteArray[2],minDiscount,maxDiscount,approvalCount, actionType));
                  
                  
                  // set the approver in the last quote.
                  if(totalItem == nthItem || (nextQuote != strQuote && quoteMap.containskey(strQuote) && firstTimeAtLoop == false)){

                        system.debug('PrimaryApproverSet >>'+PrimaryApproverSet);
                        system.debug('VPApproverSet >>'+VPApproverSet);
                        system.debug('ManagerApproverSet >>'+ManagerApproverSet);
                        system.debug('SVPApproverSet >>'+SVPApproverSet);
                        system.debug('DefaultApproverSet >>'+DefaultApproverSet);

                      quoteobj = quoteMap.get(strQuote);
                      quoteobj = SetApprovers(quoteobj, PrimaryApproverSet, VPApproverSet, ManagerApproverSet, SVPApproverSet, DefaultApproverSet);
                      quoteMap.put(strQuote,  quoteobj );
                   
                      //qouteDiscountSummaryObj = discountSummaryMap.get(strQuote);
                      // reset the approver set;
                      PrimaryApproverSet.clear();
                      VPApproverSet.clear();
                      ManagerApproverSet.clear();
                      SVPApproverSet.clear();
                      DefaultApproverSet.clear();
                  }             
                  nthItem = nthItem + 1;    
                }
              }
   
              //TODO
              if(quoteMap.values().size()>0)
                  update quoteMap.values();
                 
              //ToDO
              if(DiscountSummaryList.size()>0) 
              if(actionType == 'isUpsert')    
                  upsert DiscountSummaryList;
              else if(actionType == 'isDelete')
                  upsert DiscountSummaryList;

              if(actionType == 'isDelete' && quoteRatePalnAgreegateList.size() == 0)
                  delete quoteDiscountSummaryList;
    }

     
    //Mapping the Primary and secondary approvers in Quote Object
    public static zqu__Quote__c SetApprovers(zqu__Quote__c quoteObj , set<string> PrimaryApproverSet, set<string> VPApproverSet, set<string> ManagerApproverSet, set<string> SVPApproverSet, set<string> DefaultApproverSet){

          list<string> PrimaryApproverLst = new list<string>();
          PrimaryApproverLst.addAll(PrimaryApproverSet);
          list<string> VPApproverLst = new list<string>();
          VPApproverLst.addAll(VPApproverSet);
          list<string> ManagerApproverLst = new list<string>();
          ManagerApproverLst.addAll(ManagerApproverSet);
          list<string> SVPApproverLst = new list<string>();
          SVPApproverLst.addAll(SVPApproverSet);
          list<string> DefaultApproverLst = new list<string>();
          DefaultApproverLst.addAll(DefaultApproverSet);
          
          if(quoteObj!= null){
          
            quoteObj.put('QA_Primary_1__c', null);
            quoteObj.put('QA_Primary_2__c',  null);
            quoteObj.put('QA_Primary_3__c', null);
            quoteObj.put('QA_VP_1__c', null);
            quoteObj.put('QA_VP_2__c', null);
            quoteObj.put('QA_VP_3__c', null);
            quoteObj.put('QA_1st_Manager_1__c', null);
            quoteObj.put('QA_2nd_Manager_1__c', null);
            quoteObj.put('QA_3rd_Manager_1__c', null);
            quoteObj.put('QA_Default_Approver__c', null);
            quoteObj.put('QA_SVP__c', null);     
            quoteObj.put('Approval_Needed__c', false);
            //quoteObj.Status__c = '';
       
             
            Integer index = 1;
            for(string pm :PrimaryApproverLst){
                quoteObj.put('QA_Primary_'+index+'__c',pm);
                index++;
            }
            for(Integer i=2; i<=PrimaryApproverCount; i++){
                if(PrimaryApproverLst.size()>0){
                    quoteObj.Approval_Needed__c = true;
                    if(string.valueOf(quoteObj.get('QA_Primary_'+i+'__c')) == null)
                        quoteObj.put('QA_Primary_'+i+'__c', PrimaryApproverLst[0]);
                }
            }  
            
  
            index = 1;
            for(string vp :VPApproverLst){
                quoteObj.put('QA_VP_'+index+'__c',vp);
                index++;
            }
            for(Integer i=2; i<=VPApproverCount; i++){
                if(VPApproverLst.size()>0){
                    quoteObj.Approval_Needed__c = true;
                    if(string.valueOf(quoteObj.get('QA_VP_'+i+'__c')) == null)
                        quoteObj.put('QA_VP_'+i+'__c', VPApproverLst[0]);
                }
            }


            index = 1;
            for(string manage :ManagerApproverLst){
                if(index==1) 
                  quoteObj.put('QA_1st_Manager_1__c', manage);

                if(index==2) 
                  quoteObj.put('QA_2nd_Manager_1__c', manage);

                if(index==3) 
                  quoteObj.put('QA_3rd_Manager_1__c', manage);
                index++;
            }

            index = 1;
            for(string SVPObj :SVPApproverLst){
                quoteObj.put('QA_SVP__c', SVPObj);
                index++;
            }
              
            index = 1;
            for(string dfltObj :DefaultApproverLst){
                quoteObj.put('QA_Default_Approver__c', dfltObj);
                index++;
            }
 
        }  
        return quoteObj;
    }
    

    public static map<string, user> getOwnerDetails(set<id> OwnerId){
        map<string, user> mapOfOwner = new map<string, user>();
        string manager = 'managerId, manager.managerId, manager.manager.managerId';
        //string query = 'select id, Name, Office__c, Region__c, Theater__c, ' +manager+ ' from user'; 
        string query = 'select id, Name, Region__c, Theater__c, ' +manager+ ' from user'; 
        string whereCond = ' where id IN: OwnerId';
        list<user> UserLst = Database.query(query+whereCond);
        list<string> managerList = new list<string>();
        for(user u:UserLst)
            mapOfOwner.put(u.Id, u);
        return mapOfOwner;
    }

    
    //Find whether the Approval request is for Primary or Secondary
    public static set<string> FindQuoteApproverByApprovalType(string productKey, string OppRegion, string OppOffice, string approverType, string approverLevel, decimal minDiscount, decimal maxDiscount, map<string, list<Quote_Approver_Mapping__c>> QuoteApproverMappingMap, map<string, user> quoteOwnerIdMaps, string qutOwnerId){

        set<string> approverIdSet = new set<string>();
        Map<String, String> approvelLevelMap = new Map<String, String>();
        string approverId = ''; 
        //CSO##APLE##All  ##Specific##West
        string[] productArray = productKey.split('##');
       
        system.debug('QuoteApproverMappingMap >>'+QuoteApproverMappingMap);

        if(QuoteApproverMappingMap.containskey(productKey) || QuoteApproverMappingMap.containskey(productArray[0]+splitchar+'All')){
          
          list<Quote_Approver_Mapping__c> quoteApproverMappingList = QuoteApproverMappingMap.get(productKey);
          //&& approverType == Role This value i removed
          if(QuoteApproverMappingMap.containskey( productArray[0]+splitchar+'All' ) && QuoteApproverMappingMap != null && quoteApproverMappingList != null)
              quoteApproverMappingList.addall(QuoteApproverMappingMap.get(productArray[0]+splitchar+'All'));

          system.debug('quoteApproverMappingList >>'+quoteApproverMappingList);
          
          if(quoteApproverMappingList != null)
          for(Quote_Approver_Mapping__c quoteAppMapObj : quoteApproverMappingList){
            
            system.debug('quoteAppMapObj >>'+quoteAppMapObj);
            decimal discountLimit = quoteAppMapObj.Discount_Limit__c;

            if ( quoteAppMapObj != null && quoteAppMapObj.Approver_Type__c == Specific && approverType == Specific && quoteAppMapObj.Approver_Hierarchy__c == approverLevel && quoteAppMapObj.Approver__c != null ){   
  
                system.debug('quoteAppMapObj App >>'+quoteAppMapObj.Approver__c);
                system.debug('quoteAppMapObj Theater >>'+quoteAppMapObj.Theater__c);
                system.debug('quoteOwnerIdMaps >>'+quoteOwnerIdMaps); 
                system.debug('maxDiscount >>'+maxDiscount); 
                system.debug('discountLimit >>'+discountLimit); 
                system.debug('approverIdSet.size >>'+approverIdSet.size()); 
                system.debug('quoteAppMapObj.Approver_Hierarchy__c / approverLevel  >>'+ quoteAppMapObj.Approver_Hierarchy__c  + ' /'  +  approverLevel     ); 

                //User userDtl = quoteOwnerIdMaps.get(quoteAppMapObj.Approver__c);
                User userDtl = quoteOwnerIdMaps.get(qutOwnerId);
               
                system.debug('userDtl.Theater__c >>'+userDtl.Theater__c); 
                
                system.debug('userDtl.Theater__c /quoteAppMapObj.Theater__c >>'+userDtl.Theater__c  + '/' + quoteAppMapObj.Theater__c); 
                

                if(userDtl.Theater__c == null)
                    userDtl.Theater__c = DefaultTheater;

                if( maxDiscount > discountLimit && approverIdSet.size() < 3 && ( userDtl.Theater__c == quoteAppMapObj.Theater__c || quoteAppMapObj.Theater__c == 'All' || userDtl.Theater__c == 'All' ) ){
                    system.debug('quoteAppMapObj Approval Hir >>'+quoteAppMapObj.Approver_Hierarchy__c);
                    approverIdSet.add(quoteAppMapObj.Approver__c);
                    //if(quoteAppMapObj.Approver__c != null)
                    //    approvelLevelMap.put(quoteAppMapObj.Approval_Level__c, quoteAppMapObj.Approver__c);
                }
                    
                if(approverLevel == DefaultApprover)
                if(maxDiscount > discountLimit && approverIdSet.size() < 3){
                    approverIdSet.add(quoteAppMapObj.Approver__c);
                    //if(quoteAppMapObj.Approver__c != null)
                    //   approvelLevelMap.put(quoteAppMapObj.Approval_Level__c, quoteAppMapObj.Approver__c);
                } 

            } else if ( quoteAppMapObj != null && quoteAppMapObj.Approver_Type__c == Role && approverType == Role ) {
              
                approverId = getManagerId(quoteAppMapObj, quoteOwnerIdMaps, OppRegion, maxDiscount, qutOwnerId, OppOffice);

                if(approverId != '' && approverId != null){
                  
                    approvelLevelMap.put(quoteAppMapObj.Approval_Level__c, approverId);

                }
                              
            }
          }

        } 


        if(approvelLevelMap.size()>0){
            list<string> appList = new list<string>();
            appList.addAll(approvelLevelMap.keySet());
            appList.sort();
            for(string st : appList){  
                approverIdSet.add(approvelLevelMap.get(st)); 
            }
        }
            

        system.debug('approverIdSet >>'+approverIdSet);
        return approverIdSet;
    }

    public static string getManagerId(Quote_Approver_Mapping__c quoteAppMapObj, map<string, user> quoteOwnerIdMaps, string OppRegion, decimal maxDiscount, string qutOwnerId, string OppOffice){

        decimal discountLimit = quoteAppMapObj.Discount_Limit__c;
        User userDtl = quoteOwnerIdMaps.get(qutOwnerId);
        string manager1 = '';
        string manager2 = '';
        string manager3 = ''; 
        string approverId = '';
                
        if((userDtl.Theater__c == quoteAppMapObj.Theater__c || quoteAppMapObj.Theater__c == 'All') && (OppOffice == quoteAppMapObj.Office__c || quoteAppMapObj.Office__c == 'All') && (OppRegion == quoteAppMapObj.Region__c || quoteAppMapObj.Region__c == 'All')){
            manager1 = userDtl.managerId;
            manager2 = userDtl.manager.managerId;
            manager3 = userDtl.manager.manager.managerId;
        }

        if(maxDiscount > discountLimit){ 
          if(quoteAppMapObj.Approver_Hierarchy__c == '1st Manager' && manager1 != null && manager1 != '') {
              approverId = manager1;
          }

          if(quoteAppMapObj.Approver_Hierarchy__c == '2nd Manager' && manager2 != null && manager2 != ''){
              approverId = manager2;
          }              
          
          if(quoteAppMapObj.Approver_Hierarchy__c == '3rd Manager' && manager3 != null && manager3 != ''){
              approverId = manager3;
          }
        }

        return approverId;
    }


    //To Upsert the Quote Obj maximum, minimum, Approval Count in Summary Object
    public static Quote_Discount_Summary__c GetQuoteDiscountSummaryByQuotes(map<string,Quote_Discount_Summary__c> discountSummaryMap, string strQuote, string strApprovalType, decimal minDiscount, decimal maxDiscount, Integer approvalCount, string actionType){
        
        if(maxDiscount == null)
           maxDiscount = 0.0;
        if(minDiscount == null)
           minDiscount = 0.0;
                       
        Quote_Discount_Summary__c qouteDiscountSummaryObj = discountSummaryMap.get(strQuote+splitchar+strApprovalType);
        if(qouteDiscountSummaryObj != null){
           qouteDiscountSummaryObj.Approval_Type__c = strApprovalType;
           qouteDiscountSummaryObj.Approval_Type_Count__c = approvalCount;
           qouteDiscountSummaryObj.Min_Discount__c = minDiscount;
           qouteDiscountSummaryObj.Max_Discount__c = maxDiscount;
           qouteDiscountSummaryObj.Quote__c = strQuote;
        }else{
           qouteDiscountSummaryObj= new Quote_Discount_Summary__c();
           qouteDiscountSummaryObj.Approval_Type__c = strApprovalType;
           qouteDiscountSummaryObj.Approval_Type_Count__c = approvalCount;
           qouteDiscountSummaryObj.Min_Discount__c = minDiscount;
           qouteDiscountSummaryObj.Max_Discount__c = maxDiscount;
           qouteDiscountSummaryObj.Quote__c = strQuote;
        }
        return qouteDiscountSummaryObj;
     }
     
     public static map<string,list<zqu__QuoteRatePlan__c>> getzquQuoteRatePlanMap(list<zqu__QuoteRatePlan__c> zquQuoteRateList){
        map<string,list<zqu__QuoteRatePlan__c>> quoteRatePlanMap = new map<string,list<zqu__QuoteRatePlan__c>>();
  
        for(zqu__QuoteRatePlan__c Qrp : zquQuoteRateList){
            if(quoteRatePlanMap.containskey(Qrp.Product_Key__c)){
                quoteRatePlanMap.get(Qrp.Product_Key__c).add(qrp);
            }else{
                quoteRatePlanMap.put(Qrp.Product_Key__c,new list<zqu__QuoteRatePlan__c>{qrp});
            }
        }
        return quoteRatePlanMap;
    }

 }