public class ContentDocumentLinkHelper {


    public static list < string > ContentDocLink(list < string > lstofEntityId) {


        list < string > sobj = new list < string > ();
        string acc = label.ContentDocumentObjects.replace(' ','');
        for (string str: acc.split(',')) {
            sobj.add(str);
        }

        list < string > EntityIdLst = new list < string > ();
        list < string > LstObjectname = new list < string > ();

        map < string, string > listPrefixObj = new map < string, string > ();
        Map < String, Schema.SObjectType > gd = Schema.getGlobalDescribe();
        for (Schema.SObjectType stype: gd.values()) {
            Schema.DescribeSObjectResult r = stype.getDescribe();
            String prefix = r.getKeyPrefix();
            string objectName = r.getName();
            listPrefixObj.put(prefix, objectName);
        }

        for (string cdLink: lstofEntityId) {
            string id = cdLink;
            String objPrefix = String.valueOf(id).substring(0, 3);
            string objName = listPrefixObj.get(objPrefix);
            if (sobj.contains(objName)) {
                EntityIdLst.add(cdLink);
            }
        }
        return EntityIdLst;

    }

}