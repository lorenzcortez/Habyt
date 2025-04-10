public class SendGridError {

    public class Errors {
        public String message;
        public String field;
        public String help;
    }

    public List<Errors> errors;

    
    public static SendGridError parse(String json) {
        return (SendGridError) System.JSON.deserialize(json, SendGridError.class);
    }
}