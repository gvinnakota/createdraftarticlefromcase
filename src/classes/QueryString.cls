/**
 * Created by jwilkosz on 2018-05-25.
 */

public with sharing class QueryString {
    public String selectClause;
    public String fromClause;
    public String whereClause;
    public String orderByClause;
    public String limitClause;
    public String pageLimit;
    public String offset;

    public QueryString (){
        selectClause  = '';
        whereClause   = '';
        fromClause    = '';
        orderByClause = '';
        limitClause   = '';
        pageLimit     = '';
        offset        = '';
    }

    private final Set<String> keywords = new Set<String>{
        'select ', 'from ', 'where ', 'order by ', 'limit '
    };

    private Integer getFirstOccurrence(String q){
        Integer maxInt = q.length();
        for (String s : keywords){
            Integer pos = q.indexOf(s);
            if (pos > -1 && pos < maxInt){
                maxInt = pos;
            }
        }

        return maxInt;

    }

    public QueryString(String query){

        this();

        query = query.toLowerCase().trim();

        if (query.contains('where ')){
            this.addWhere(query.substring(query.indexOf('where ') + 6, query.indexOf('where ') + 6 + getFirstOccurrence(query.substringAfter('where '))));
        }
        if (query.contains('from ')){
            this.setFrom(query.substring(query.indexOf('from ') + 5, query.indexOf('from ') + 5 + getFirstOccurrence(query.substringAfter('from '))));
        }
        if (query.contains('select ')){
            this.addSelect(query.substring(query.indexOf('select ') + 7, query.indexOf('select ') + 7 + getFirstOccurrence(query.substringAfter('select '))));
        }
        if (query.contains('order by ')){
            this.addOrderBy(query.substring(query.indexOf('order by ') + 9, query.indexOf('order by ') + 9 + getFirstOccurrence(query.substringAfter('order by '))));
        }
        if (query.contains('limit ')){
            this.setLimit(query.substring(query.indexOf('limit ') + 6, query.indexOf('limit ') + 6 + getFirstOccurrence(query.substringAfter('limit '))));
        }
    }

    public QueryString (QueryString qString){
        this.selectClause  = qString.selectClause;
        this.fromClause    = qString.fromClause;
        this.whereClause   = qString.whereClause;
        this.orderByClause = qString.orderByClause;
        this.limitClause   = qString.limitClause;
        this.pageLimit     = qString.pageLimit;
        this.offset        = qString.offset;
    }

    public String getQuery() {
        String query = '';
        query += ' SELECT ' + selectClause;
        query += ' FROM '   + fromClause;
        query += String.isEmpty(whereClause)   ? '' : (' WHERE '    + whereClause);
        query += String.isEmpty(orderByClause) ? '' : (' ORDER BY ' + orderByClause);
        query += String.isEmpty(limitClause)   ? '' : (' LIMIT '    + limitClause);
        query += String.isEmpty(offset)        ? '' : (' OFFSET '   + offset);

        System.debug('getQUery: ' + query);
        return query;
    }

    public String getCountQuery() {
        return (
            ' SELECT '   + 'Count()'     +
                ' FROM '     + fromClause    +
                (String.isEmpty(whereClause)? '' : (' WHERE '    + whereClause))
        );
    }

    public QueryString addSelect(String addition) {
        if (!String.isEmpty(addition)){
            List<String> additions = new List<String>();
            for (String s : addition.split(',')){
                if (!selectClause.contains(s.trim())){
                    if (s.trim().startsWith('ConvertCurrency')){
                        additions.add(s.trim().replace('ConvertCurrency(', '').substringBeforeLast(')'));
                    } else {
                        additions.add(s.trim());
                    }
                }
            }

            selectClause += (String.isEmpty(selectClause) ? '' : ',') + String.join(additions, ',');
        }
        return this;
    }

    public QueryString addWhere(String addition) {
        if (!String.isEmpty(addition)) {
            whereClause += (String.isEmpty(whereClause) ? '(' : (' AND (')) + addition + ') ';
        }
        return this;
    }

    public QueryString setFrom(String fromString) {
        fromClause = fromString;
        return this;
    }

    public QueryString addOrderBy(String addition) {
        System.debug('addition: ' + addition);
        addition = addition.replace('nulls first', 'nulls last');
        System.debug('replaced addition: ' + addition);
        List<String> additions = addition.split(',');
        for (String a : additions){
            if (!String.isEmpty(a.trim())){
                orderByClause += (String.isEmpty(orderByClause) ? '' : ',') + addition;
            }
        }


        return this;
    }

    public QueryString setLimit(String limitString) {
        limitClause = limitString;
        return this;
    }

    public QueryString setOffset(String offsetString) {
        offset = offsetString;
        return this;
    }

    public String getSelectClause(){
        return this.selectClause;
    }

    public List<SObject> executeQuery(Set<String> myNames){
        return Database.query(this.getQuery());
    }
    public List<SObject> executeQuery(Set<Id> myNames){
        return Database.query(this.getQuery());
    }

}