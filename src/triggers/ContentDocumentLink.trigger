// * Set Inferred permission. Share File Content Vetrsion to All Users. *//
trigger ContentDocumentLink on ContentDocumentLink(before insert) {
    list < string > lstofEntityId = new list < string > ();
   

    for (ContentDocumentLink cdLink: trigger.new) {
        string id = cdLink.LinkedEntityId;
        lstofEntityId.add(id);
    }

    list<string> ListId = ContentDocumentLinkHelper.ContentDocLink(lstofEntityId);

    for (ContentDocumentLink cdLink: trigger.new) {
      
       for(string checkListId :ListId ){
        if (lstofEntityId.contains(checkListId )) {
            system.debug('cdLink++' + cdLink);
            cdLink.Visibility = 'AllUsers';
            cdLink.ShareType = 'I';
        }
       } 

    }
}