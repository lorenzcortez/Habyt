public class L16MemberApplication {

    public class Variables {
        public String property_id;
        public String originating_source_lead_id;
        public String leasing_agent_id;
        public List<Applicants> applicants;
        public String move_in_date;
        public Double min_budget;
        public Double max_budget;
    }

    public String operation;
    public Variables variables;

    public class Applicants {
        public Boolean lead_applicant;
        public String first_name;
        public String last_name;
        public String phone;
        public String email;
    }

    
    public static L16MemberApplication parse(String json) {
        return (L16MemberApplication) System.JSON.deserialize(json, L16MemberApplication.class);
    }
}