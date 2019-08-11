public with sharing class PACProvider {

    public List<PAC__c> pacs;
    public List<PAC__c> pacsToInsert;
    public Map<Boolean, List<PACHelper.PACWrapper>> pacWrappersDuplicateMap { get; private set; }
    private static final Pattern DURATION_REGEX = Pattern.compile('([0-9]*)yr.*');

    public PACProvider(String fileBody) {
        initializeCollections();
        reloadRecords(fileBody);
    }

    public void reloadRecords(String body) {
        List<String> lines = safeSplit(body, '\n');
        List<String> codes = lines[0].split(',');
        List<String> names = lines[1].split(',');
        List<String> quantityStrings = lines[3].split(',');
        Set<String> uniqueKeys = new Set<String>();
        Set<String> uniqueProducts = new Set<String>();

        Integer temp = 0;

        for (Integer i = 0; i < codes.size(); ++i) {
            String code = codes[i];
            List<String> codeSplit = code.split('-');
            String product = codeSplit[2];

            Matcher durationMatcher = DURATION_REGEX.matcher(codeSplit[4]);
            durationMatcher.find();
            Integer duration = Integer.valueOf(durationMatcher.group(1));

            Integer quantity = Integer.valueOf(codeSplit[5].trim());

            for (Integer j = 0; j < Integer.valueOf(quantityStrings[i].trim()); ++j) {
                String key = lines[j + 4].split(',')[i].trim();
                uniqueKeys.add(key.toUpperCase());
                uniqueProducts.add(product);
                pacs.add(new PAC__c(
                        Code__c = code,
                        Product__c = product,
                        Duration__c = duration,
                        Quantity__c = quantity,
                        Key__c = key));
            }
        }
        checkDuplicates(uniqueKeys);
        populateGroupingField();
    }

    public Boolean containsDuplicates() {
        return !pacWrappersDuplicateMap.get(true).isEmpty();
    }

    public List<PACHelper.PACWrapper> getAllPACWrappers() {
        List<PACHelper.PACWrapper> resultList = new List<PACHelper.PACWrapper>();
        if (pacWrappersDuplicateMap != null) {
            resultList.addAll(pacWrappersDuplicateMap.get(false));
            resultList.addAll(pacWrappersDuplicateMap.get(true));
        }
        System.debug('resultList: ' + resultList);
        return resultList;
    }

    private void populateGroupingField(){
        for(PAC__c pac: pacsToInsert){
            pac.Grouping_Field__c = PACHelper.getPACGroupingFieldValue(pac);
        }
    }

    private void checkDuplicates(Set<String> uniqueKeys) {
        Set<String> existingKeys = PACHelper.findPacKeysByKeys(uniqueKeys);
        for (PAC__c pac : pacs) {
            Boolean isDuplicate = existingKeys.contains(pac.Key__c.toUpperCase());
            pacWrappersDuplicateMap.get(isDuplicate).add(new PACHelper.PACWrapper(pac, isDuplicate));
            if (!isDuplicate) {
                pacsToInsert.add(pac);
            }
        }
    }

    private void initializeCollections() {
        pacs = new List<PAC__c>();
        pacsToInsert = new List<PAC__c>();
        pacWrappersDuplicateMap = new Map<Boolean, List<PACHelper.PACWrapper>>();
        pacWrappersDuplicateMap.put(true, new List<PACHelper.PACWrapper>());
        pacWrappersDuplicateMap.put(false, new List<PACHelper.PACWrapper>());
    }

    public void saveRecords() {
        if (!pacsToInsert.isEmpty()) {
            List<Database.SaveResult> results = Database.insert(pacsToInsert, false);
        }
    }

    private List<String> safeSplit(String inStr, String delim) {
        Integer regexFindLimit = 100;
        Integer regexFindCount = 0;

        List<String> output = new List<String>();

        Matcher m = Pattern.compile(delim).matcher(inStr);

        Integer lastEnd = 0;

        while (!m.hitEnd()) {
            while (regexFindCount < regexFindLimit && !m.hitEnd()) {
                if (m.find()) {
                    output.add(inStr.substring(lastEnd, m.start()));
                    lastEnd = m.end();
                } else {
                    output.add(inStr.substring(lastEnd));
                    lastEnd = inStr.length();
                }

                regexFindCount++;
            }

            m.reset(inStr);
            m.region(lastEnd, m.regionEnd());

            regexFindCount = 0;
        }

        return output;
    }
}