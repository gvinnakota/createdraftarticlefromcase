public class PivLP_Mock implements System.StubProvider {
    public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
        if(stubbedMethodName == 'getSubQuotesBeforeSplit'){
            throw new PivLP_Exception('testing exception');
        }
        if(stubbedMethodName == 'splitQuote'){
            throw new PivLP_Exception('testing exception');
        }
        if(stubbedMethodName == 'cleanSplit'){
            throw new PivLP_Exception('testing exception');
        }
        if(stubbedMethodName == 'findMasterQuote'){
            throw new PivLP_Exception('testing exception');
        }
        
        return null;
    }

}