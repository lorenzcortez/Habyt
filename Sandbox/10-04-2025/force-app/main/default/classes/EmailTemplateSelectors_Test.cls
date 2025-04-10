@IsTest
public class EmailTemplateSelectors_Test {
    @TestSetup
    static void setupTest(){
        EmailTemplate emailTemplate = new EmailTemplate(
            DeveloperName = 'Test_EmailName_12345', 
            FolderId = UserInfo.getUserId(), 
            TemplateType='Text', 
            Name = 'Test_EmailName'
        );
        insert emailTemplate;
    }

    @IsTest
    static void FromTemplateNames_UnitTest() {
        String templateName = 'Test_EmailName';
        Integer expected = [SELECT COUNT() FROM EmailTemplate WHERE Name = :templateName];

        Test.startTest();
        List<EmailTemplate> queried = (List<EmailTemplate>) Paua_SelectorHandler.getSelector(EmailTemplateSelectors.FromTemplateNames.class)
                                                    .setParameter('names', new Set<String> {templateName})
                                                    .query();
        Test.stopTest();

        System.assertEquals(expected, queried.size(), 'Email templates list size mismatch');
    }
}