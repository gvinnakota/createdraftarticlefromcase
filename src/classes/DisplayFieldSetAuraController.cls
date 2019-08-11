public class DisplayFieldSetAuraController {

    @AuraEnabled
    public static List<Field> getFields(Map<String,Object> sobj, String sobjectType, String fieldSetName){
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(sobjectType).getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        
		List<Field> fields = new List<Field>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            Field f = new Field(fsm);
            f.value = sobj.get(f.apiName);
            fields.add(f);
        }

        return fields;
    }

	public class Field {
        @AuraEnabled
        public String apiName;

        @AuraEnabled
        public String label;

        @AuraEnabled
        public String fieldType;

        @AuraEnabled
        public Object value;

        @AuraEnabled
        public Object refName;

        public Field(Schema.FieldSetMember f) {
            this.apiName = f.fieldPath;
            this.label = f.label;
            this.fieldType = String.valueOf(f.getType());
            if(fieldType == 'REFERENCE') {
                refName = this.apiName.replace('__c', '__r') + '.Name';
            }
        }
    }
}