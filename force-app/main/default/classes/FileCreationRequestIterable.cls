global class FileCreationRequestIterable implements Iterable<FileCreationRequest> {

    List<FileCreationRequest> requests;

    global FileCreationRequestIterable(List<FileCreationRequest> requests) {
        this.requests = requests;
    }

    global Iterator<FileCreationRequest> iterator() {
        return new FileCreationRequestIterator(this.requests);
    }
}
