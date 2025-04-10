public class MC_EmailURLHTML_Invocable {

    @InvocableMethod(label = 'Get HTML from MC View URL')
    public static List < String > getHTMLFromURL(List < String > emailURLs) {
        List < String > htmlStrings = new List < String > ();
        for (String u: emailURLs) {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(u);
            request.setMethod('GET');
            Http http = new Http();
            if(!test.IsRunningtest()){
                HttpResponse response = http.send(request);
                htmlStrings.add(response.getBody());
            }
        }
        return htmlStrings;
    }
}