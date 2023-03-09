public abstract with sharing class Selector {

    private String query;
    private String orderBy;
    private String condition;

    public List<String> subqueries = new List<String>();
    
    public List<Schema.SObjectField> fields;

    public Selector() {
        this.fields = getSObjectFieldList();
    }

    abstract Schema.SObjectType getSObjectType();
    
    abstract List<Schema.SObjectField> getSObjectFieldList();

    public virtual void setFields(List<Schema.SObjectField> fields) {
        this.fields = fields;
    }

    public virtual Selector setCondition(String condition) {
        this.condition = condition;
        return this;
    }

    public virtual Selector setOrder(String fieldName, String direction) {
        if(direction.toUpperCase() == 'ASC' || direction.toUpperCase() == 'DESC') {
            this.orderBy = 'ORDER BY ' + fieldName + ' ' + direction;
        } else {
            throw new QueryException('Invalid direction: ' + direction);
        }
        return this;
    }

    public virtual List<SObject> query() {
        this.query = 'SELECT ' + concatFields(fields); 
        for(String subquery : subqueries) {
            this.query += ',' + subquery;
        }
        this.query += ' FROM ' + getSObjectType().getDescribe().getName();
        if(this.condition != null) {
            this.query += ' WHERE ' + this.condition + ' ';
        }
        this.query += ' WITH SECURITY_ENFORCED ';
        if(this.orderBy != null) {
            this.query += this.orderBy;
        }
        return Database.query(this.query);
    }

    public virtual Selector addSubquery(String childRelationship, List<Schema.SObjectField> fields, String whereCondition) {
        String subquery = '(SELECT ' + concatFields(fields) + ' FROM ' + childRelationship;
        if(whereCondition != null) {
            subquery += ' ' + whereCondition;
        }
        subquery += ' ORDER BY Name ASC)';
        this.subqueries.add(subquery);
        return this;
    }

    private static String concatFields(List<Schema.SObjectField> fields) {
        String fieldsString = '';
        for(Schema.SObjectField field : fields) {
            fieldsString += (field.getDescribe().getName() + ', ');
        }
        return fieldsString.removeEnd(', ');
    }

    public class QueryException extends Exception {}
}
