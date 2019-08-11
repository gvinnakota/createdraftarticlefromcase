/**
 * Created on 18/03/2019.
 */
@IsTest
public with sharing class QueryStringTest {

    @IsTest
    static void testBehaviour(){
        Test.startTest();
        QueryString qString = new QueryString();
        qString.addSelect('Test');
        qString.addWhere('Test');
        qString.setFrom('Test');
        qString.addOrderBy('Test');
        qString.setLimit('100');
        qString.getSelectClause();
        qString.setOffset('200');
        qString = new QueryString(qString);
        qString = new QueryString('SELECT Id FROM Account');
        Test.stopTest();
        System.assertNotEquals(null, qString.getQuery());
    }

}