public without sharing class DSAuftragsdatenverarbeitung {

    public static final String TEMPLATE_ID = '8b23cc54-d0dd-47cf-8193-ffb2a77dfd1b';
    public static final String DEFAULT_EMAIL_SUBJECT = 'Auftragsdatenverarbeitung';
    public static final String DEFAULT_EMAIL_BODY = 'Bitte prüfen und signieren.';

    public Id relatedRecordId;
    public String templateId;
    public String emailSubject;
    public String emailBody;
    public InteressentRole Interessent;
    public MaklerRole Makler;
    public PartnermanagerRole Partnermanager;

    public DSAuftragsdatenverarbeitung() {
        this.templateId = TEMPLATE_ID;
        this.emailSubject = DEFAULT_EMAIL_SUBJECT;
        this.emailBody = DEFAULT_EMAIL_BODY;
        this.Interessent = new InteressentRole();
        this.Makler = new MaklerRole();
        this.Partnermanager = new PartnermanagerRole();
    }

    public virtual class RecipientBase {
        public String Name;
        public String Email;
    }

    public class InteressentRole extends RecipientBase {
        public Id interessentenRecordId;
        public Id maklerRecordId;
        public Id partnermanagerRecordId;
    }

    public class MaklerRole extends RecipientBase {
    }

    // Intentionally matches the provided role spelling.
    public class PartnermanagerRole extends RecipientBase {
    }
}