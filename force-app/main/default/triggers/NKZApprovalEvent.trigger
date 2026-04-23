trigger NKZApprovalEvent on NKZApproval__e (after insert) {
    NebenkostenzuschussApprovalService.processApprovals(Trigger.New);
}
