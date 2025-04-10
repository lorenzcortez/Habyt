public without sharing class EmailTemplateSelectors {
    public virtual class FromTemplateNames extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, DeveloperName, Name, Body, BrandTemplateId, FolderId, HtmlValue, IsActive, Subject, ' + 
                   'TemplateStyle, TemplateType ' +
                   'FROM EmailTemplate';
        }

        protected virtual override String getWhereClause() {
            return 'Name in :names';
        }
    
        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<String> names = (Set<String>) queryParameters.get('names');

            return Database.query(query);
        }
    }

    public virtual class OrgWideAddressesByAddress extends Paua_Selector {
        protected virtual override String getBaseQuery() {
            return 'SELECT Id, Address ' + 
                'FROM OrgWideEmailAddress';
        }

        protected virtual override String getWhereClause() {
            return 'Address LIKE :addresses';
        }
    
        public virtual override List<sObject> query(Paua_Selector.QueryClauses clauses) {
            String query = buildQueryFromClauses(clauses);

            Set<String> addresses = (Set<String>) queryParameters.get('addresses');

            return Database.query(query);
        }
    }
}