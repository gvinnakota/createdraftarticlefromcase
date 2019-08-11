/*Descirption: Numerical Sorting for version formats.*/
public class VersionSortUtil
{
    public static integer iterate = 0;
    public static list<string> FinalsortLst = new  list<string>();
    public static set<integer> booleanSet = new  set<integer>();
    public static map<string, list<string>> mapOFSplitVal = new  map<string, list<string>>();
  
    public static list<string> GetSorted(list<string> sortLst, string sortOrder)
    {
        list<string> finalSortedVersionLst = new  list<string>();
        FinalsortLst.addAll(checkSecondDigit(sortLst, 0));
        if(sortOrder == 'DESC')
        {
           //Descending order format
            for(Integer i = FinalsortLst.size() - 1; i >= 0; i--)
            
            {
                finalSortedVersionLst.add(FinalsortLst.get(i));
            }
        }
      
       //Ascending order format
        if(sortOrder == 'ASC')
        {
            finalSortedVersionLst = FinalsortLst;
        }
        list<string> alphStringLst = new  list<string>();
      
       //Descending order and put character values in last
        if(sortOrder == 'DESC-ALPH-END')
        {
            for(Integer i = FinalsortLst.size() - 1; i >= 0; i--)
            {
                string WithOutSapce = FinalsortLst.get(i).remove(' ');
                if(WithOutSapce.isAlphaNumeric())
                {
                    alphStringLst.add(FinalsortLst.get(i));
                }
                else
                {
                    finalSortedVersionLst.add(FinalsortLst.get(i));
                }
            }
            finalSortedVersionLst.addAll(alphStringLst);
        }
        list<string> alphStrgAsc = new  list<string>();
      
       //Ascending order and put character values in last
        if(sortOrder == 'ASC-ALPH-END')
        
        {
            for(Integer i = 0; i < FinalsortLst.size(); i++)
            {
                string WithOutSapceAsc = FinalsortLst.get(i).remove(' ');
                if(WithOutSapceAsc.isAlphaNumeric()||!WithOutSapceAsc.isNumeric())
                {
                    alphStrgAsc.add(FinalsortLst.get(i));
                }
                else
                {
                    finalSortedVersionLst.add(FinalsortLst.get(i));
                }
            }
            finalSortedVersionLst.addAll(alphStrgAsc);
        }
        system.debug('finalSortedVersionLst++' + finalSortedVersionLst);
        return finalSortedVersionLst;
    }
 
    public static list<string> checkSecondDigit(list<string> srtLst, integer j)
    {
        list<string> FinalsortLst2 = new  list<string>();
        list<integer> sortLst = new  list<integer>();
        set<integer> ActualSort = new  set<integer>();
        map<integer, list<string>> mapOfVal = new  map<integer, list<string>>();
        for(integer i = 0; i < srtLst.size(); i++)
        {
            list<string> spltLSt = new  list<string>();
            if(!mapOFSplitVal.containsKey(srtLst[i]))
            {
                spltLSt = srtLst[i].split('\\.');
                mapOFSplitVal.put(srtLst[i], spltLSt);
            }
            for(string ss: new list<string>{srtLst[i]})
            {
                if(mapOFSplitVal.get(srtLst[i]).size() > j)// comparing srtLst size is greaterthan J value it do regular process or else store that value in Finalsortversion
                
                {
                    string val = mapOFSplitVal.get(srtLst[i])[j];
                    //system.debug('val++'+val);
                    integer b = 0;
                    if(val.isNumeric()){
                        b= integer.valueOf(val);
                    }else{ //(val.isAlpha()|| val.isAlphaSpace() || val.isAlphaNumeric() && !val.isNumeric()){
                        for(integer k = 0; k < val.length(); k++)
                        {
                            b = b + integer.valueOf(val.charAt(k));//Returns the any value of the character at the specified index.ex:a,alp,1,2...
                        }
                    }
                    sortLst.add(b);
                    if(mapOfVal.containsKey(b))
                    {
                        mapOfVal.get(b).add(srtLst[i]);
                    }
                    else
                    {
                        mapOfVal.put(b, new list<string>{srtLst[i]});//compare to put map for srtLst value equal to value of the character at the specified index.
                    }
                }
                else
                {
                    FinalsortLst2.addAll(new list<string>{srtLst[i]});
                }
            }
        }
        sortLst.sort();
        actualSort.addAll(sortLst);
        //system.debug('actualSort++'+actualSort);
        for(integer a: actualSort)//sorting values comparing
        
        {
            list<string> getSrtLst = mapOfVal.get(a);
            set<string> getSrtSet = new  set<string>();
            getSrtSet.addAll(getSrtLst);
            if(getSrtSet.size() == 1 && !booleanSet.contains(a))//duplicate values allow here
            
            {
                FinalsortLst2.addAll(mapOfVal.get(a));
                booleanSet.add(a);
                continue;
            }
            if(getSrtLst.size() > 1)
            {
                iterate = iterate + 1;
                FinalsortLst2.addAll(checkSecondDigit(getSrtLst, iterate));// comparing values size and after iterating
                iterate = 0;
                booleanSet.add(a);
            }
            else
            {
                FinalsortLst2.addAll(mapOfVal.get(a));//finally all sorted values stored here.
                iterate = 0;
            }
        }
        return FinalsortLst2;
    }
    
    
}