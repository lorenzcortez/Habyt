public class ContractSendMoveEmailsQueueable implements Queueable {
    public void execute(QueueableContext context) {
        CustomerContractService contractService = new CustomerContractService();

        Date moveInDate = System.today().addDays(CustomerContractService.MOVE_IN_DAYS);
        Date moveOutDate = System.today();
        Set<String> statusesMoveIn = new Set<String> {
            CustomerContractService.STATUS_SIGNED, 
            CustomerContractService.STATUS_ACTIVATED
        };
        Set<String> statusesMoveOut = new Set<String> {
            CustomerContractService.STATUS_TERMINATED
        };

        List<Contract> relevantMoveIn = contractsByStartDate(statusesMoveIn, moveInDate);
        relevantMoveIn = contractService.getNotTestContract(relevantMoveIn);
        relevantMoveIn = contractService.getWithRecordTypeIds(relevantMoveIn, new Set<Id>{CustomerContractService.RT_ID_RENT});
        relevantMoveIn = contractService.getWithoutMoveInDatetime(relevantMoveIn);

        List<Contract> relevantMoveOut = contractsByEndDate(statusesMoveOut, moveOutDate);
        relevantMoveOut = contractService.getNotTestContract(relevantMoveOut);
        relevantMoveOut = contractService.getWithRecordTypeIds(relevantMoveOut, new Set<Id>{CustomerContractService.RT_ID_RENT});
        relevantMoveOut = contractService.getWithoutMoveOutDatetime(relevantMoveOut);

        if (! relevantMoveIn.isEmpty()) {
            contractService.notifyMoveInContracts(relevantMoveIn);
        }

        if (! relevantMoveOut.isEmpty()) {
            contractService.notifyMoveOutContracts(relevantMoveOut);
        }
    }

    public List<Contract> contractsByEndDate(Set<String> relevantStatuses, Date endDate) {
        return (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ByEndDateAndStatus.class)
            .setParameter('dateValue', endDate)
            .setParameter('relevantStatuses', relevantStatuses)
            .query();
    }

    public List<Contract> contractsByStartDate(Set<String> relevantStatuses, Date startDate) {
        return (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ByStartDateAndStatus.class)
            .setParameter('dateValue', startDate)
            .setParameter('relevantStatuses', relevantStatuses)
            .query();
    }
}