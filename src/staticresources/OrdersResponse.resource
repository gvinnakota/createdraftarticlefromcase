{
  "orders" : [ {
    "orderNumber" : "O-00000242",
    "orderDate" : "2018-12-16",
    "createdDate" : "2018-12-16 21:12:20",
    "createdBy" : "2c92c0f961c1e5490161dd9a4c7b4320",
    "updatedDate" : "2018-12-16 21:12:21",
    "updatedBy" : "2c92c0f961c1e5490161dd9a4c7b4320",
    "existingAccountNumber" : "A00003171",
    "currency" : "USD",
    "status" : "Completed",
    "subscriptions" : [ {
      "subscriptionNumber" : "A-S00004514",
      "customFields" : {
        "Subscription_Type__c" : null,
        "Owner_Region__c" : null,
        "QuoteID__c" : null,
        "ChannelOrderID__c" : null,
        "SOW__c" : null,
        "Additional_Bill_To__c" : null,
        "Payment_Plan__c" : null,
        "SalesRep__c" : null,
        "PurchaseOrder__c" : null
      },
      "baseVersion" : null,
      "newVersion" : 1,
      "orderActions" : [ {
        "type" : "CreateSubscription",
        "sequence" : 0,
        "triggerDates" : [ {
          "triggerDate" : "2018-12-16",
          "name" : "ContractEffective"
        }, {
          "triggerDate" : "2018-12-16",
          "name" : "ServiceActivation"
        }, {
          "triggerDate" : "2018-12-16",
          "name" : "CustomerAcceptance"
        } ],
        "createSubscription" : {
          "subscriptionOwnerAccountNumber" : "A00003171",
          "terms" : {
            "autoRenew" : false,
            "renewalSetting" : "RENEW_WITH_SPECIFIC_TERM",
            "initialTerm" : {
              "startDate" : "2018-12-16",
              "period" : 12,
              "periodType" : "Month",
              "termType" : "TERMED"
            },
            "renewalTerms" : [ {
              "period" : 12,
              "periodType" : "Month"
            } ]
          },
          "invoiceSeparately" : null,
          "notes" : null,
          "subscribeToRatePlans" : [ {
            "productRatePlanId" : "2c92c0f865a8934b0165a9db0c3e12fd",
            "newRatePlanId" : "2c92c0f967a5766a0167ba944ff2609c",
            "uniqueToken" : "538ff940-01ba-11e9-be2b-0b3a25c51c37",
            "chargeOverrides" : [ {
              "description" : "",
              "chargeNumber" : "C-00073185",
              "productRateplanChargeId" : "2c92c0f9659e64ce0165a9dbcf5953f3",
              "uniqueToken" : "53902050-01ba-11e9-be2b-0b3a25c51c37",
              "revenueRecognitionRuleName" : null,
              "revRecCode" : null,
              "revRecTriggerCondition" : null,
              "pricing" : {
                "recurringPerUnit" : {
                  "listPrice" : 500.000000000,
                  "quantity" : 1.000000000,
                  "listPriceBase" : "Per_Billing_Period",
                  "priceChangeOption" : null,
                  "priceIncreasePercentage" : null
                }
              },
              "startDate" : {
                "triggerEvent" : "ServiceActivation",
                "specificTriggerDate" : null
              },
              "endDate" : {
                "endDateCondition" : "Subscription_End",
                "specificEndDate" : null,
                "upToPeriods" : null,
                "upToPeriodsType" : null
              },
              "billing" : {
                "billCycleDay" : null,
                "billingPeriod" : "Annual",
                "billCycleType" : "SubscriptionStartDay",
                "billingTiming" : "IN_ADVANCE",
                "billingPeriodAlignment" : "AlignToCharge",
                "specificBillingPeriod" : null,
                "weeklyBillCycleDay" : null
              },
              "customFields" : {
                "TCV_USD__c" : null,
                "ARR_USD__c" : null,
                "Listed_Price__c" : null,
                "RATE_USD__c" : null,
                "ACV_USD__c" : null,
                "OrderNumber__c" : null,
                "End_Date__c" : null,
                "Country_Uplift__c" : null,
                "PSAmount__c" : null,
                "Calculated_Discount__c" : null,
                "CustomerPO__c" : null,
                "Initial_Term__c" : null,
                "Rollup_Type__c" : null,
                "Listed_Total__c" : null,
                "Start_Date__c" : null,
                "MRR_USD__c" : null
              }
            } ],
            "customFields" : { }
          } ]
        },
        "customFields" : { },
        "orderItems" : [ {
          "id" : "2c92c0f967a5766a0167ba94503560a3",
          "startDate" : "2018-12-16",
          "endDate" : "2019-12-15",
          "quantity" : 1.000000000,
          "orderActionId" : "2c92c0f967a5766a0167ba944cf06091",
          "scId" : "2c92c0f967a5766a0167ba944ff2609d"
        } ],
        "orderMetrics" : [ {
          "productRatePlanChargeId" : "2c92c0f9659e64ce0165a9dbcf5953f3",
          "originRatePlanId" : "2c92c0f967a5766a0167ba944ff2609c",
          "tcb" : [ {
            "subscriptionOwner" : "A00003171",
            "invoiceOwner" : "A00003171",
            "amount" : 500.000000000,
            "endDate" : "2019-12-15",
            "orderItemId" : "2c92c0f967a5766a0167ba94503560a3",
            "termNumber" : 1,
            "tax" : 19.300000000,
            "generatedReason" : "Extension",
            "type" : "Regular",
            "startDate" : "2018-12-16"
          } ],
          "quantity" : [ {
            "subscriptionOwner" : "A00003171",
            "invoiceOwner" : "A00003171",
            "amount" : 1.000000000,
            "endDate" : "2019-12-15",
            "orderItemId" : "2c92c0f967a5766a0167ba94503560a3",
            "termNumber" : 1,
            "generatedReason" : "Extension",
            "startDate" : "2018-12-16"
          } ],
          "productRatePlanId" : "2c92c0f967a5766a0167ba944feb6099",
          "tcv" : [ {
            "subscriptionOwner" : "A00003171",
            "invoiceOwner" : "A00003171",
            "amount" : 500.000000000,
            "endDate" : "2019-12-15",
            "orderItemId" : "2c92c0f967a5766a0167ba94503560a3",
            "termNumber" : 1,
            "generatedReason" : "Extension",
            "type" : "Regular",
            "startDate" : "2018-12-16"
          } ],
          "chargeNumber" : "C-00073185",
          "elp" : [ {
            "subscriptionOwner" : "A00003171",
            "invoiceOwner" : "A00003171",
            "amount" : 500.000000000,
            "endDate" : "2019-12-15",
            "orderItemId" : "2c92c0f967a5766a0167ba94503560a3",
            "termNumber" : 1,
            "tax" : 19.300000000,
            "generatedReason" : "Extension",
            "type" : "Regular",
            "startDate" : "2018-12-16"
          } ],
          "mrr" : [ {
            "subscriptionOwner" : "A00003171",
            "invoiceOwner" : "A00003171",
            "amount" : 41.670000000,
            "endDate" : "2019-12-15",
            "orderItemId" : "2c92c0f967a5766a0167ba94503560a3",
            "termNumber" : 1,
            "generatedReason" : "Extension",
            "type" : "Regular",
            "startDate" : "2018-12-16"
          } ]
        } ]
      } ]
    } ],
    "customFields" : { }
  } ],
  "success" : true
}