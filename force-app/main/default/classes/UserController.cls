public with sharing class UserController {
    @AuraEnabled
    public static void saveUserSettings(User user, Id imgDocumentId, Id logoDocumentId) {
        if(imgDocumentId != null) {
            ContentDistribution cdImg = new ContentDistribution();
            cdImg.Name = 'Profile Photo Url';
            cdImg.ContentVersionId = imgDocumentId;
            cdImg.PreferencesAllowViewInBrowser= true;
            cdImg.PreferencesLinkLatestVersion=true;
            cdImg.PreferencesNotifyOnVisit=false;
            cdImg.PreferencesPasswordRequired=false;
            cdImg.PreferencesAllowOriginalDownload= true;
            insert cdImg;

            List<ContentDistribution> cdsImg = [SELECT ContentDownloadUrl FROM ContentDistribution WHERE Id = :cdImg.Id];
            if(cdsImg.size() > 0) {
                user.ImgUrl__c = cdsImg[0].ContentDownloadUrl;
            }
        }

        if(logoDocumentId != null) {
            ContentDistribution cdLogo = new ContentDistribution();
            cdLogo.Name = 'Logo Url';
            cdLogo.ContentVersionId = logoDocumentId;
            cdLogo.PreferencesAllowViewInBrowser= true;
            cdLogo.PreferencesLinkLatestVersion=true;
            cdLogo.PreferencesNotifyOnVisit=false;
            cdLogo.PreferencesPasswordRequired=false;
            cdLogo.PreferencesAllowOriginalDownload= true;
            insert cdLogo;

            List<ContentDistribution> cdsLogo = [SELECT ContentDownloadUrl FROM ContentDistribution WHERE Id = :cdLogo.Id];
            if(cdsLogo.size() > 0) {
                user.LogoUrl__c = cdsLogo[0].ContentDownloadUrl;
            }
        }

        update user;
    }
}