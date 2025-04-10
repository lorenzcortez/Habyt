/*
 * @who     : Jorge Valdes <jorge.valdes@empaua.com>
 * @when    : 16 Jul 2021
 * @what    : This class implements a Batch for ContentDocument to create a ContentDistribution if its related to a room,
 *            an apartment or a property
 */
public class CreateContentDistributionBatch implements Database.Batchable<sObject>{
	public static final String SBOBJECTTYPE_ROOM = 'Room__c';
	public static final String SBOBJECTTYPE_APARTMENT = 'Apartment__c';
	public static final String SBOBJECTTYPE_PROPERTY = 'Property__c';
	public CreateContentDistributionBatch(){
	}

	public Database.QueryLocator start(Database.BatchableContext BC){
		String query = 'SELECT Id, LatestPublishedVersionId FROM ContentDocument';
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<ContentDocument> scope){
		if (scope.isEmpty()){
			System.debug('+++ Empty scope, no records to process on this job.');
			return;
		}

		Map<Id, ContentDocument> mapId_ContentDoc = new Map<Id, ContentDocument>(scope);
        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
		Set<Id> setRelevantContentVersionIds = new Set<Id>();
		Set<Id> setCVWithContentDistrib = new Set<Id>();
		ContentService service = new ContentService();
		String objType;

		// Get all ContentDocumentLink related to the ContentDocuments without a ContentDistribution
		List<ContentDocumentLink> lstContentDocLink = [SELECT Id, LinkedEntityId, ContentDocumentId
		                                               FROM ContentDocumentLink
		                                               WHERE ContentDocumentId IN :mapId_ContentDoc.keySet() AND LinkedEntityId != null];
		System.debug('+++ lstContentDocLink size: ' + lstContentDocLink.size());

		// Get all ContentDocument Ids from the ContentDocumentLink related to a Room, an Apartment or a Property
		for (ContentDocumentLink iContentDocumentLink : lstContentDocLink){
			objType = iContentDocumentLink.LinkedEntityId.getSObjectType().getDescribe().getName();

			if (objType == SBOBJECTTYPE_ROOM || objType == SBOBJECTTYPE_APARTMENT || objType == SBOBJECTTYPE_PROPERTY){
				setRelevantContentVersionIds.add(mapId_ContentDoc.get(iContentDocumentLink.ContentDocumentId).LatestPublishedVersionId);
			}
		}
		System.debug('+++ setRelevantContentVersionIds size: ' + setRelevantContentVersionIds.size());

		for (ContentDistribution iContentDist : [SELECT Id, ContentVersionId
		                                         FROM ContentDistribution
		                                         WHERE ContentVersionId IN :setRelevantContentVersionIds]){
			setCVWithContentDistrib.add(iContentDist.ContentVersionId);
		}
		System.debug('+++ setCVWithContentDistrib size: ' + setCVWithContentDistrib.size());

		// Get all ContentVersions related to the relevant ContentDocuments
		if (!setRelevantContentVersionIds.isEmpty()){
			for (ContentVersion iContentVersion : [SELECT Id, ContentDocumentId
			                                       FROM ContentVersion
			                                       WHERE Id IN :setRelevantContentVersionIds]){
                // Filter out all Content Versions that already has a Content Distribution
                if (!setCVWithContentDistrib.contains(iContentVersion.Id)) {
                    lstContentVersion.add(iContentVersion);
                }
			}
			System.debug('+++ lstContentVersion size: ' + lstContentVersion.size());
			service.createContentDistributions(lstContentVersion);
		} else{
			System.debug('+++ All Documents related to a Room, an Apartment or a Property has their own Content Distribution created.');
		}
	}

	public void finish(Database.BatchableContext BC){
	}
}