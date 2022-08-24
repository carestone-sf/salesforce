trigger ContentDocumentLink on ContentDocumentLink (after insert) {
    TriggerFactory.createHandler(ContentDocumentLink.getSObjectType());
}