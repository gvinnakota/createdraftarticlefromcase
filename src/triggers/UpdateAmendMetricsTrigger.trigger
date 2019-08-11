trigger UpdateAmendMetricsTrigger on zqu__QuoteChargeSummary__c (before insert, before update) {

System.debug('##### Trigger on zqu__QuoteChargeSummary__c');
    new ZQuoteChargeSummaryTriggerHandler().run();
    
    for (zqu__QuoteChargeSummary__c charge : Trigger.new) {
       
        if(charge.zqu__QuoteRatePlanCharge__c == null){
            // this should only happen in renewal quotes

            if(Trigger.IsInsert){ 
                // adding these query won't effect the TOO MANY SOQL as it is not going to be 
                // executed during the "custom send to zbilling process"
                List<zqu__QuoteRatePlan__c> qrp;
                if(!Test.isRunningTest()){
                    qrp =  [SELECT Id, Name, zqu__SubscriptionRatePlanZuoraId__c 
                            FROM zqu__QuoteRatePlan__c 
                            WHERE Id =: charge.zqu__QuoteRatePlan__c];
                }else{
                    qrp = new List<zqu__QuoteRatePlan__c>();
                    zqu__QuoteRatePlan__c qr = new zqu__QuoteRatePlan__c();
                    qr.Name = 'Test Quote RatePlan';
                    qr.zqu__SubscriptionRatePlanZuoraId__c = 'SubscriptionRatePlanZuoraId12345';
                    qrp.add(qr);

                    Zuora__SubscriptionProductCharge__c spc = new Zuora__SubscriptionProductCharge__c();
                    spc.Name = charge.Name;
                    spc.RATE_USD__c = '1.00';
                    spc.Start_Date__c = '2016-01-01';
                    spc.TCV_USD__c = '100.00';
                    spc.Listed_Price__c = '100.00';
                    spc.Zuora__RatePlanId__c = 'SubscriptionRatePlanZuoraId12345';
                    insert spc;
                }

                System.debug('WHAT IS THE NUMBER :' + qrp);

                if(qrp.size() == 1){

                    System.debug('Retrieve the custom field values from Subscription Product Charges');
                    List<Zuora__SubscriptionProductCharge__c> scs = [
                                                                SELECT ID, Name, Listed_Price__c, RATE_USD__c, Start_Date__c, TCV_USD__c
                                                                FROM Zuora__SubscriptionProductCharge__c
                                                                WHERE Zuora__RatePlanId__c =: qrp[0].zqu__SubscriptionRatePlanZuoraId__c
                                                                    AND Name =: charge.Name ];

                    System.debug('Subscription Product Charges ==> ' + scs);

                    if (scs.size() == 1){
                        System.debug('Found mapping SPC : Setting custom fields from Subscription Product Charge');

                        Zuora__SubscriptionProductCharge__c sc = scs[0];
                        charge.RATE_USD__c = Decimal.valueOf(sc.RATE_USD__c);
                        if (sc.Listed_Price__c != null)
                         	charge.Listed_Price__c = Decimal.valueOf(sc.Listed_Price__c);
                        else 
                            charge.Listed_Price__c = 0;
                        charge.Start_Date__c = sc.Start_Date__c;
                        if (sc.TCV_USD__c != null)
                        	charge.TCV_USD__c = Decimal.valueOf(sc.TCV_USD__c);
                        else
                            charge.TCV_USD__c = 0;
                    }
                }
            }


            Double conversionRate = 1.00;
            if(charge.RATE_USD__c != null){
                conversionRate = Double.valueOf(charge.RATE_USD__c);
                System.debug('RATE_USD__c = ' + conversionRate);
            }

            if (charge.Subscription_Type_Formula__c == 'Renew Subscription') {
                Datetime startDate = Datetime.newInstance(charge.Subscription_Term_End_Date_Formula__c.year(), 
                    charge.Subscription_Term_End_Date_Formula__c.month(),
                    charge.Subscription_Term_End_Date_Formula__c.day());
                charge.Start_Date__c = startDate.format('yyyy-MM-dd');
                
                Date endDate = charge.Subscription_Term_End_Date_Formula__c.addMonths(Integer.valueOf(charge.Renewal_Term_Formula__c));
                charge.End_Date__c = endDate;
            }
            
            System.debug('Renewal Quote - Charge Start Date = '+ charge.Start_Date__c + ' and End Date = ' + charge.End_Date__c);

            if (charge.Custom_TCV_Formula__c != null)
            	charge.TCV_USD__c = charge.Custom_TCV_Formula__c/conversionRate;
            else
                charge.TCV_USD__c = 0;
            if (charge.zqu__MRR__c != null)
            	charge.MRR_USD__c = charge.zqu__MRR__c/conversionRate;
            else
                charge.MRR_USD__c = 0;
            if (charge.MRR_USD__c != null)
            	charge.ARR_USD__c = charge.MRR_USD__c * 12;
            else
                charge.ARR_USD__c = 0;


            if (charge.Product_Category__c == 'Services' || charge.Billing_Period__c == '' || charge.Billing_Period__c == null) {
                charge.ACV_USD__c = charge.TCV_USD__c;
            } else {
                charge.ACV_USD__c = calculateACV(charge);
            }


        } else {
            // use values from quote rateplan charge if available.

            if(charge.MRR_USD_Formula__c != null){
                charge.MRR_USD__c = Decimal.valueOf(charge.MRR_USD_Formula__c);
            }
            if(charge.ARR_USD_Formula__c != null){
                charge.ARR_USD__c = Decimal.valueOf(charge.ARR_USD_Formula__c);    
            }
            if(charge.ACV_USD_Formula__c != null){
                charge.ACV_USD__c = Decimal.valueOf(charge.ACV_USD_Formula__c);
            }
            if(charge.TCV_USD_Formula__c != null){
                charge.TCV_USD__c = Decimal.valueOf(charge.TCV_USD_Formula__c);
            }
            if(charge.RATE_USD_Formula__c != null){
                charge.RATE_USD__c = Decimal.valueOf(charge.RATE_USD_Formula__c);
            }

            if(charge.Billing_Period_Formula__c != null){
                charge.Billing_Period__c = charge.Billing_Period_Formula__c;
            }
            if(charge.Listed_Price_Formula__c != null){
                charge.Listed_Price__c = Decimal.valueOf(charge.Listed_Price_Formula__c);
            }

            if(charge.Start_Date_Formula__c != null){
                charge.Start_Date__c = String.valueOf(charge.Start_Date_Formula__c);
            }


            if(charge.Subscription_Type_Formula__c == 'Renew Subscription'){
                Integer numOfMonths = Integer.valueOf(charge.Renewal_Term_Formula__c);
                if (numOfMonths > 12) {
                    charge.ACV_USD__c = charge.TCV_USD__c/numOfMonths*12.00;
                }else{
                    charge.ACV_USD__c = charge.TCV_USD__c;
                }

            }

            Datetime dateTimeEndDate = null;
            String formattedDate = '';
            if (charge.Subscription_Type_Formula__c != 'New Subscription') {
                if (charge.Subscription_Type_Formula__c == 'Renew Subscription') {
                    Date endDate = charge.Subscription_Term_End_Date_Formula__c.addMonths(Integer.valueOf(charge.Renewal_Term_Formula__c));
                    charge.End_Date__c = endDate;
                } else if (charge.Subscription_Type_Formula__c == 'Amend Subscription') {
                    charge.End_Date__c = charge.Subscription_Term_End_Date_Formula__c;
                }

                if(charge.Start_Date_Formula__c != null){
                    Datetime dateTimeStartDate = datetime.newInstance(charge.Start_Date_Formula__c.year(), charge.Start_Date_Formula__c.month(), charge.Start_Date_Formula__c.day());
                    charge.Start_Date__c = dateTimeStartDate.format('yyyy-MM-dd');
                }
            }else{
                if(charge.End_Date_Formula__c != null){
                    charge.End_Date__c = charge.End_Date_Formula__c;
                }
            }
        }

        System.debug('Display charge :' + charge);

    }


    private Decimal calculateACV(zqu__QuoteChargeSummary__c charge) {

        Decimal tcvUSD = charge.TCV_USD__c;

        Integer numOfMonths = 0;
        Decimal acvUSD = 0;

        if (charge.Subscription_Type_Formula__c == 'Renew Subscription') {
            numOfMonths = Integer.valueOf(charge.Renewal_Term_Formula__c);
            acvUSD = tcvUSD;
            if (numOfMonths > 12) {
                acvUSD = tcvUSD/numOfMonths*12.00;
            }
        } else if (charge.Subscription_Type_Formula__c == 'Amend Subscription') {
            //TODO figure out how to prorate the amend subscriptions
            /*
            System.debug('start date: '+currquote.zqu__StartDate__c+' end date: '+currquote.zqu__SubscriptionTermEndDate__c);
            numOfMonths = currquote.zqu__StartDate__c.monthsBetween(currquote.zqu__SubscriptionTermEndDate__c);
            System.debug('num of months: '+numOfMonths);
            Integer daysinMonth = Date.daysinMonth(currquote.zqu__StartDate__c.addMonths(numOfMonths).year(), currquote.zqu__StartDate__c.addMonths(numOfMonths).month());
            Integer remainingDays = currquote.zqu__StartDate__c.addMonths(numOfMonths).daysBetween(currquote.zqu__SubscriptionTermEndDate__c);
            Decimal daysFraction = remainingDays/daysinMonth;
            System.debug('remainingDays: '+remainingDays);
            System.debug('daysinMonth: '+daysinMonth);
            System.debug('daysFraction: '+daysFraction);
            */
            acvUSD = tcvUSD/(charge.quote_initial_term_formula__c)*12;
        }


        return acvUSD;
    }
}