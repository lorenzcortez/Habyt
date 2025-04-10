public class ContentSelectors {
    public virtual class ContentDocumentLinkByLinkedEntity extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id, LinkedEntityId, ShareType, ' +
                'ContentDocumentId, ContentDocument.LatestPublishedVersionId ' +
            'FROM ContentDocumentLink';
        }

        protected virtual override String getWhereClause() {
            return 'LinkedEntityId IN :idSet';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> idSet = (Set<Id>) queryParameters.get('idSet');

            return Database.query(query);
        }
    }

    public virtual class ContentDocumentLinkByDocument extends ContentDocumentLinkByLinkedEntity {
        protected virtual override String getWhereClause() {
            return 'ContentDocumentId IN :idSet';
        }
    }

    public virtual class DownloadableContent extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id, ContentDownloadUrl, ContentDocumentId, ContentVersionId, ' + 
                'ContentVersion.ContentSize, DistributionPublicUrl ' +
            'FROM ContentDistribution';
        }

        protected override String getWhereClause() {
            return 'ContentVersionId IN :idSet';
        }

        public override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> idSet = (Set<Id>) queryParameters.get('idSet');

            return Database.query(query);
        }
    }


    public virtual class ContentVersionByDocumentAndTitle extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id ' +
                'FROM ContentVersion';
        }

        protected virtual override String getWhereClause() {
            return 'Title = :title AND ContentDocumentId IN: docIds';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            String title = (String) queryParameters.get('title');
            Set<Id> docIds = (Set<Id>) queryParameters.get('docIds');

            return Database.query(query);
        }
    }

    public virtual class ById extends Paua_Selector {
        protected override String getBaseQuery() {
            return 'SELECT Id, ContentDocumentId FROM ContentVersion';
        }

        protected override String getWhereClause() {
            return 'Id IN :idSet';
        }

        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<Id> idSet = (Set<Id>) queryParameters.get('idSet');

            return Database.query(query);
        }
    }
}