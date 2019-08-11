@IsTest
public with sharing class TestCsvPACBuilder {

    private Document f;
    private List<PACWrp> pacs = new List<PACWrp>();

    public TestCsvPACBuilder() {
        f = new Document();
    }

    public TestCsvPACBuilder add(PACWrp pac) {
        this.pacs.add(pac);
        return this;
    }

    public TestCsvPACBuilder addAll(List<PACWrp> pacs) {
        this.pacs.addAll(pacs);
        return this;
    }

    public TestCsvPACBuilder withName(String name) {
        f.Name = name;
        return this;
    }

    public Document buildWithoutSave() {
        f.FolderId = UserInfo.getUserId();
        f.Body = Blob.valueOf(buildFileBody());
        return f;
    }

    public Document build() {
        buildWithoutSave();
        insert f;
        return f;
    }

    public String buildFileBody() {
        List<String> lines = new List<String>();
        List<String> codes = new List<String>();
        List<String> names = new List<String>();
        List<String> subscriptions = new List<String>();
        List<String> quantities = new List<String>();
        List<List<String>> products = new List<List<String>>();
        for (PACWrp pac : pacs) {
            codes.add(pac.code);
            names.add(pac.name);
            subscriptions.add(pac.subscription);
            quantities.add(pac.quantity);
            products.add(pac.products);
        }
        lines.add(String.join(codes, ','));
        lines.add(String.join(names, ','));
        lines.add(String.join(subscriptions, ','));
        lines.add(String.join(quantities, ','));
        lines.addAll(getStringFromProductsOfList(products));
        String csv = String.join(lines, '\n') + '\n';
        System.debug('CSV: ' + csv);
        return csv;
    }

    private List<String> getStringFromProductsOfList(List<List<String>> productsList) {
        System.debug('getStringFromProductsOfList productsList: ' + productsList);
        Boolean reachedMax = false;
        Integer idxElemInTable = 0;
        List<String> prodLines = new List<String>();
        while (!reachedMax) {
            Boolean wasProduct = false;
            List<String> line = new List<String>();
            for (List<String> products : productsList) {
                System.debug('getStringFromProductsOfList products: ' + products);
                if (products.size()-1 >= idxElemInTable) {
                    wasProduct = true;
                    line.add(products[idxElemInTable]);
                } else {
                    line.add('');
                }
            }
            if (wasProduct) {
                prodLines.add(String.join(line, ','));
            } else {
                reachedMax = true;
            }
            idxElemInTable++;
        }
        return prodLines;
    }

    public class PACWrp {
        public String code;
        public String name;
        public String subscription;
        public String quantity;
        public List<String> products;

        public PACWrp withCode(String code) {
            this.code = code;
            return this;
        }

        public PACWrp withName(String name) {
            this.name = name;
            return this;
        }

        public PACWrp withSubscription(String subscription) {
            this.subscription = subscription;
            return this;
        }

        public PACWrp withQuantity(String quantity) {
            this.quantity = quantity;
            return this;
        }

        public PACWrp withProducts(List<String> products) {
            this.products = products;
            return this;
        }

        public PACWrp build() {
            if (String.isBlank(quantity)) {
                quantity = String.valueOf(products.size());
            }
            return this;
        }
    }
}