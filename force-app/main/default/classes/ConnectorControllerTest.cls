@isTest
public with sharing class ConnectorControllerTest {

    @TestSetup
    static void makeData(){
        ConnectorType__c ct = new ConnectorType__c();
        ct.Name = 'Google Drive';
        ct.AuthorizationEndpoint__c = 'https://accounts.google.com/o/oauth2/auth';
        ct.TokenEndpoint__c = 'https://accounts.google.com/o/oauth2/token';
        ct.ClientId__c = '166550496015-h41c6c5pe3jtu799iefm6gidetre397c.apps.googleusercontent.com';
        ct.ClientSecret__c = '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';
        ct.RedirectUri__c = 'https://wirtschaftshaus.lightning.force.com/apex/connector';
        ct.ScopeRequired__c = true;
        ct.Scope__c = 'https://www.googleapis.com/auth/drive';
        ct.ExtraUrlParameters__c = 'access_type=offline';
        insert ct;

        Connector__c c = new Connector__c();
        c.Name = 'Google Drive';
        c.ConnectorType__c = ct.Id;
        insert c;
    }
    
    private static testMethod void testConnectorController() {
        Connector__c c = [SELECT Id FROM Connector__c];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PageReference pageRef = Page.Connector;
        pageRef.getParameters().put('id', c.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ApexPages.StandardController std = new ApexPages.StandardController(c);
        ConnectorController cc = new ConnectorController(std);
        cc.save();
        cc.cancel();
        cc.RequestAuthorizationCode();
        cc.error('test');
        cc.info('test');
        cc.isConfigured();
        cc.getServiceName();
        cc.getRecordName();
        cc.getIsAuthorized();
        cc.getIsDirty();
        cc.getisConfigured();
        Test.stopTest();
    }
    
    private static testMethod void testConnectorControllerExchangeAuthCode() {
        Connector__c c = [SELECT Id FROM Connector__c];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PageReference pageRef = Page.Connector;
        pageRef.getParameters().put('id', c.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ApexPages.StandardController std = new ApexPages.StandardController(c);
        ConnectorController cc = new ConnectorController(std);
        cc.exchangeAuthCode();
        Test.stopTest();
    }
    
    private static testMethod void testConnectorService() {
        Connector__c c = [SELECT c.TokenType__c, c.RefreshToken__c, c.RefreshTokenRequested__c, c.Name, c.Id, c.AccessToken__c, 
                       c.AccessTokenRequested__c, c.AccessTokenExpiry__c, c.Active__c, 
                       ConnectorType__r.TokenEndpoint__c, ConnectorType__r.Scope__c, ConnectorType__r.ScopeRequired__c, 
                       ConnectorType__r.RedirectUri__c, ConnectorType__r.Name, ConnectorType__r.Id, 
                       ConnectorType__r.ExtraUrlParameters__c, ConnectorType__r.DeveloperName__c, 
                       ConnectorType__r.ClientSecret__c, ConnectorType__r.ClientId__c, ConnectorType__r.CallbackURL__c, 
                       ConnectorType__r.AuthorizationEndpoint__c FROM Connector__c c];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        ConnectorService csViaId = new ConnectorService(c.Id);
        csViaId.retrieveConnector();
        csViaId.validateConnector();
        ConnectorService csViaRecord = new ConnectorService(c);
        csViaRecord.retrieveConnector();
        csViaRecord.validateConnector();
        csViaRecord.getAccessToken();
        csViaRecord.exchangeCode('a', false);
        csViaRecord.accessTokenExpired();
        
        Test.stopTest();
    }
}