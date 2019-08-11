trigger UpdateAmendSumTrigger on zqu__QuoteRatePlanCharge__c (before insert, before update) {

    System.debug('##### Trigger on zqu__QuoteRatePlanCharge__c');

    for (zqu__QuoteRatePlanCharge__c charge : Trigger.new) {

        // set end date of each charge for amendment and renewal
        if (charge.Subscription_Type__c == 'Renew Subscription') {
            Date endDate = charge.SubscriptionTerm_End_Date_Formula__c.addMonths(Integer.valueOf(charge.Renewal_Term_Formula__c));
            Datetime dateTimeEndDate = datetime.newInstance(endDate.year(), endDate.month(), endDate.day());
            charge.End_Date__c = dateTimeEndDate.format('dd-MM-YYYY');

        } else if (charge.Subscription_Type__c == 'Amend Subscription') {
            Datetime dateTimeEndDate = datetime.newInstance(charge.SubscriptionTerm_End_Date_Formula__c.year(), charge.SubscriptionTerm_End_Date_Formula__c.month(), charge.SubscriptionTerm_End_Date_Formula__c.day());
            charge.End_Date__c = dateTimeEndDate.format('dd-MM-YYYY');
        }


        Double conversionRate = 1.00;
        if(charge.RATE_USD__c != null){
            conversionRate = Double.valueOf(charge.RATE_USD__c);
        }

        Decimal tcvValue = 0;
        if (charge.Subscription_Type__c == 'New Subscription') {
            if (charge.zqu__ChargeType__c == 'Recurring') {
                Decimal initialTerm = charge.Initial_Term__c;
                Decimal quantity = 1;
                if (charge.zqu__FeeType__c == 'Per Unit') {
                    quantity = charge.zqu__Quantity__c; 
                }
                if (charge.Payment_Plan_Formula__c == 'Annual') {
                    if(charge.zqu__EffectivePrice__c != null && quantity != null && initialTerm != null) tcvValue = initialTerm/12*charge.zqu__EffectivePrice__c*quantity;
                }
                if (charge.Payment_Plan_Formula__c == 'Monthly') {
                    tcvValue = initialTerm*charge.zqu__EffectivePrice__c*quantity;
                }
                if (charge.Payment_Plan_Formula__c == 'Quarterly') {
                    tcvValue = initialTerm/3*charge.zqu__EffectivePrice__c*quantity;
                }
                if (charge.Payment_Plan_Formula__c == 'Semi-Annual') {
                    tcvValue = initialTerm/6*charge.zqu__EffectivePrice__c*quantity;
                }
                tcvValue = tcvValue;
            } else {
                tcvValue = charge.zqu__PreviewedTCV__c;
            }
        } else {
            tcvValue = charge.zqu__PreviewedTCV__c;
        }
        charge.Custom_TCV_Formula__c = tcvValue;
        
        charge.TCV_USD__c = String.valueOf(charge.Custom_TCV_Formula__c/conversionRate);
        system.debug('[TP]--> ' + charge.zqu__MRR__c);
        charge.MRR_USD__c = String.valueOf(charge.zqu__MRR__c/conversionRate);
        charge.ARR_USD__c = String.valueOf(Decimal.valueOf(charge.MRR_USD__c)*12);
        String acvUSD = '';
        if (charge.Product_Category__c == 'Services' || charge.Billing_Period__c == '' || charge.Billing_Period__c == null) {
            acvUSD = charge.TCV_USD__c;
            charge.ACV_USD__c = acvUSD;
        } else {
            acvUSD = calculateACV(charge);
            charge.ACV_USD__c = acvUSD;
        }
    }

    private String calculateACV(zqu__QuoteRatePlanCharge__c charge) {

        Decimal tcvUSD = Decimal.valueOf(charge.TCV_USD__c);

        Integer numOfMonths = 0;
        Decimal acvUSD = 0;

        if (charge.Subscription_Type__c == 'Renew Subscription') {
            numOfMonths = Integer.valueOf(charge.Renewal_Term_Formula__c);
            acvUSD = tcvUSD;
            if (numOfMonths > 12) {
                acvUSD = tcvUSD/numOfMonths*12.00;
            }
        } else if (charge.Subscription_Type__c == 'Amend Subscription') {
            //TODO figure out how to prorate the amend subscriptions
            System.debug('start date: '+charge.Start_Date_Formula__c+' end date: '+charge.SubscriptionTerm_End_Date_Formula__c);
            numOfMonths = charge.Start_Date_Formula__c.monthsBetween(charge.SubscriptionTerm_End_Date_Formula__c);
            System.debug('num of months: '+numOfMonths);
            Integer daysinMonth = Date.daysinMonth(charge.Start_Date_Formula__c.addMonths(numOfMonths).year(), charge.Start_Date_Formula__c.addMonths(numOfMonths).month());
            Integer remainingDays = charge.Start_Date_Formula__c.addMonths(numOfMonths).daysBetween(charge.SubscriptionTerm_End_Date_Formula__c);
            Decimal daysFraction = remainingDays/daysinMonth;
            System.debug('remainingDays: '+remainingDays);
            System.debug('daysinMonth: '+daysinMonth);
            System.debug('daysFraction: '+daysFraction);
            acvUSD = tcvUSD/(numOfMonths+daysFraction)*12.00;
        } else if (charge.Subscription_Type__c == 'New Subscription') {
            numOfMonths = Integer.valueOf(charge.Initial_Term__c);
            if(tcvUSD != null && numOfMonths != null) acvUSD = tcvUSD/numOfMonths*12.00;
        }


        return String.valueOf(acvUSD);
    }
}