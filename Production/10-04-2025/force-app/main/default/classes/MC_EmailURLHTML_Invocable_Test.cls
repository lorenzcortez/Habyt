@isTest
private class MC_EmailURLHTML_Invocable_Test {

    @isTest
    static void testGetHTMLFromURL() {
        // Positive test case
        List<String> emailURLs = new List<String>{'https://example.com'};
        Test.startTest();
        List<String> result = MC_EmailURLHTML_Invocable.getHTMLFromURL(emailURLs);
    }
}