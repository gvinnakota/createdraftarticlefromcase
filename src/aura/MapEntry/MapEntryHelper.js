({
	readFromObject:  function(dataObj, keyString){
        var value = null;
        if(!dataObj || !keyString){
            console.log('Warning>>>>>> Invalid data or key for Hyperlink');
            return '';
        }
        var keyToks = keyString.split('.');
        if(keyToks.length == 1){
            value = dataObj[keyToks[0]];
        }else if(keyToks.length == 2){
            var innerMap = dataObj[keyToks[0]];
            if(innerMap) value = innerMap[keyToks[1]];
        }else if(keyToks.length == 3){
            var innerMap = dataObj[keyToks[0]];
            if(innerMap) {
                var innerInnerMap = innerMap[keyToks[1]];
                if(innerInnerMap) value = innerInnerMap[keyToks[2]];
            }
        }
        return value;
    }
})