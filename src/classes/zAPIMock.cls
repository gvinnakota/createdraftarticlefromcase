/******************************************************************************
Name                :    zAPIMock
Author              :    Reid Beckett, Launchpad
Description         :    Mock implementation for Zuora SOAP API callouts
Date                :    10/05/2018
*******************************************************************************/
public class zAPIMock implements System.StubProvider, IzAPI {
    public static Boolean Mock_Error = false;
    public static Boolean Mock_SendToZBilling_Error = false;
    
    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
        Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, 
        List<Object> listOfArgs) {
            if(stubbedMethodName == 'zcreate'){
                return zcreate((List<Zuora.zObject>)listOfArgs.get(0));
            }
            if(stubbedMethodName == 'zquery'){
                return zquery((String)listOfArgs.get(0));
            }
            if(stubbedMethodName == 'zupdate'){
                return zupdate((List<Zuora.zObject>)listOfArgs.get(0));
            }
            if(stubbedMethodName == 'zdelete'){
                return zdelete((String)listOfArgs.get(0), (List<String>)listOfArgs.get(1));
            }
            if(stubbedMethodName == 'zsubscribe'){
                return zsubscribe((List<Zuora.zApi.SubscribeRequest>)listOfArgs.get(0));
            }
            if(stubbedMethodName == 'sendToZBilling'){
                return sendToZBilling((List<zqu.zQuoteUtil.ZBillingQuoteCollection>)listOfArgs.get(0));
            }
        return null;
    }

    //wrap all Zuora.zApi methods
    public List<Zuora.zApi.SaveResult> zcreate(List<Zuora.zObject> zobjs){
        List<Zuora.zApi.SaveResult> results = new List<Zuora.zApi.SaveResult>();
        for(Zuora.zObject zobj : zobjs){
            Zuora.zApi.SaveResult obj = new Zuora.zApi.SaveResult();
            obj.id = 'dafhasdgkj';
            obj.success = !Mock_Error;
            if(Mock_Error){
                Zuora.zObject err = new Zuora.zObject('Error');
                err.setValue('Code', 'X');
                err.setValue('Message', 'Mock error');
                obj.Errors = new List<Zuora.zObject>{err};
            }
            results.add(obj);
        }
        return results;
    }

    public List<Zuora.zObject> zquery(String zoql){
        Zuora.zObject zobj = new Zuora.zObject('Account');
        zobj.setValue('Id', 'dafhasdgkj');
        List<Zuora.zObject> results = new List<Zuora.zObject>{
            zobj
        };
        return results;
    }

    public List<Zuora.zApi.SaveResult> zupdate(List<Zuora.zObject> zobjs){
        Zuora.zApi.SaveResult obj = new Zuora.zApi.SaveResult();
        obj.id = 'dafhasdgkj';
        obj.success = !Mock_Error;
        if(Mock_Error){
            Zuora.zObject err = new Zuora.zObject('Error');
            err.setValue('Code', 'X');
            err.setValue('Message', 'Mock error');
            obj.Errors = new List<Zuora.zObject>{err};
        }
        return new List<Zuora.zApi.SaveResult>{obj};
    }

    public List<Zuora.zApi.DeleteResult> zdelete(String zType, List<String> zIds){
        Zuora.zApi.DeleteResult obj = new Zuora.zApi.DeleteResult();
        obj.id = 'dafhasdgkj';
        obj.success = !Mock_Error;
        if(Mock_Error){
            Zuora.zObject err = new Zuora.zObject('Error');
            err.setValue('Code', 'X');
            err.setValue('Message', 'Mock error');
            obj.Errors = new List<Zuora.zObject>{err};
        }
        return new List<Zuora.zApi.DeleteResult>{obj};
    }

    public List<Zuora.zApi.SubscribeResult> zsubscribe(List<Zuora.zApi.SubscribeRequest> subscribeRequests){
        Zuora.zApi.SubscribeResult obj = new Zuora.zApi.SubscribeResult();
        obj.success = !Mock_Error;
        List<Zuora.zObject> invoicedatas = new List<Zuora.zObject>();
        Zuora.zObject invoicedata = new Zuora.zObject('InvoiceData');
        Zuora.zObject invoice = new Zuora.zObject('Invoice');
        invoice.setValue('AmountWithoutTax', 42534);
        invoice.setValue('TaxAmount', 233);
        invoicedata.setValue('Invoice', invoice);
        invoicedatas.add(invoicedata);
        obj.InvoiceDatas = invoicedatas;
        return new List<Zuora.zApi.SubscribeResult>{obj};
    }

    public List<zqu.zQuoteUtil.zBillingResult> sendToZBilling(List<zqu.zQuoteUtil.ZBillingQuoteCollection> quoteCollections){
        List<zqu.zQuoteUtil.zBillingResult> results = new List<zqu.zQuoteUtil.zBillingResult>();
        zqu.zQuoteUtil.zBillingResult result = new zqu.zQuoteUtil.zBillingResult();
        result.success = !Mock_SendToZBilling_Error;
        if(Mock_SendToZBilling_Error){
            result.message = 'Mock error';
        }
        results.add(result);
        return results;
    }
}