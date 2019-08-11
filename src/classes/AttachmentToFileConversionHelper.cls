public without sharing class AttachmentToFileConversionHelper {

    public  Boolean deleteAttachmentsUponConversion = true;

    public  void ConvertToFile( list < id > conid) {
        
        Boolean communitiesEnabled = ContentVersion.sObjectType.getDescribe().fields.getMap().containsKey( 'NetworkId' );
        Map<ID, attachment> attachmentToDelete = new Map<ID, attachment>();
        // the new files to try and save
        List<ContentVersion> newFileVersions = new List<ContentVersion>();

        for ( Attachment oldAttachment : [Select Body, Id, Name, parentId ,OwnerId, description, isPrivate From Attachment where parentId IN: conid] ) {

            ContentVersion newFileVersion = new ContentVersion(
                // data fields
                versionData = oldAttachment.body,
                title = oldAttachment.name,
                description = oldAttachment.description,
                pathOnClient = '/' + oldAttachment.name,
                firstPublishLocationId = oldAttachment.parentId,
                sharingPrivacy = ( oldAttachment.isPrivate ? 'P' : 'N' ),
                // audit fields
                ownerId = oldAttachment.ownerId // system requirement, owner and creator must be the same

            );

            // if communities are enabled then assign network id
            if ( communitiesEnabled ) {
                newFileVersion.put( 'NetworkId', Network.getNetworkId() );
            }

            newFileVersions.add( newFileVersion );
            attachmentToDelete.put( oldAttachment.id, new attachment(id=oldAttachment.id) );

        }

        if ( newFileVersions.size() > 0 ) {

            SavePoint sp = Database.setSavepoint();

            try {

                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.optAllOrNone = false;

                List<Database.SaveResult> saveResults = Database.insert( newFileVersions, dmo );
                system.debug('saveResults++'+saveResults);

                postProcessConversionResults( attachmentToDelete );

            } catch ( Exception e ) {

                Database.rollback( sp );
                throw e;

            }

        }
    }

    private void postProcessConversionResults( Map<ID, attachment>  mapOfAttachmentToDelete ) {

        // should we delete the converted attachments?
        if (deleteAttachmentsUponConversion ) {
            deleteConvertedAttachments( mapOfAttachmentToDelete );
        }

    }

    private void deleteConvertedAttachments( Map<ID, attachment>  attachmentsToDelete ) {
        if ( attachmentsToDelete.size() > 0 ) {
              delete attachmentsToDelete.values();
        }

    }
}