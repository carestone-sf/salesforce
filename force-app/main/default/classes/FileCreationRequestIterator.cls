public class FileCreationRequestIterator implements Iterator<FileCreationRequest> {

    public FileCreationRequestIterator(List<FileCreationRequest> requests) {
        this.requests = requests;
    }

    Integer counter = 0;

    List<FileCreationRequest> requests;

    
    public FileCreationRequest next() {
        return this.requests[counter++];
    }
    
    public Boolean hasNext() {
        return counter < this.requests.size();
    }
}
