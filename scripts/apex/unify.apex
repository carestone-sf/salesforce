// Set stageSuffix to '.stage' for stage environment, or '' for production
String stageSuffix = '.stage'; // Change this to '' in production

// List of users to update
List<User> usersToUpdate = new List<User>();

// Example user data
List<String> aliasList = new List<String>{'hbakt', 'GSO', 'capi', 'aatos', 'ointe', 'dmigr', 'grd', 'A770901', 'A479436', 'A478725', 'guest', 'autoproc', 'platint', 'autocase', 'zinte', 'integ', 'sec', 'winte', 'A783381', 'EIS', 'cinte', 'A861414', 'Mitel IT', 'fivetran', 'A833166', 'ametz', 'rmorr', 'mhary', 'jtran', 'buser', 'fwitt', 'iuser', 'insights', 'stran', 'adura'};
List<String> emailList = new List<String>{'hossainzadeh.baktash.external@atos.net', 'wwso@atos.net', 'dl-git-talend-team@atos.net', 'noreply@atos.net', 'dl-otrs-admin@atos.net', 'dl-git-talend-team@atos.net', 'wwso@atos.net', 'anamala-sunil.kumar@atos.net', 'eddie.tan@mitel.com', 'bernd.busko@mitel.com', 'customloginsite@00d7q00000acoe6uad.org.force.com', 'rsandoval@00d7q00000acoe6uad', 'noreply@00d7q00000acoe6uad', 'automatedcase@00d7q00000acoe6uad.ext', 'anamala-sunil.kumar@atos.net', 'noreply@salesforce.com', 'noreply@salesforce.com', 'fulden.erkan@atos.net', 'teodora.slavcheva@mitel.com', 'francesca.naso@atos.net', 'cpq-administration@atos.net', 'sanjana.nalawade@eviden.com', 'andre.ebert@mitel.com', 'mark.woolever@mitel.com', 'kewal.hirudkar@mitel.com', 'amanda.metz@mitel.com', 'roxanne.morris@mitel.com', 'matt.harvey@mitel.com', 'james.tran@mitel.com', 'app-services-sfo@mitel.com', 'frederik.witte@witte-solutions.de', 'app-services-integrations@mitel.com', 'insightsintegration@00d7q00000acoe6uad.ext', 'app-services-sfo@mitel.com', 'allanzer.duran@mitel.com'};
List<String> usernameList = new List<String>{'hbakt@atos.net.unify' + stageSuffix, 'gso@atos.net.unify' + stageSuffix, 'cthapi@atos.fr.ucc', 'noreply@atos.net.ucc', 'otrsinterface@atos.net.ucc', 'datamigration@atos.fr.ucc', 'grdmigration@atos.fr.ucc', 'a770901@atos.net.ucc', 'a479436@atos.net.ucc', 'a478725@atos.net.ucc', 'customloginsite@00d7q00000acoe6uad.org.force.com', 'autoproc@00d7q00000acoe6uad', 'cloud@00d7q00000acoe6uad', 'automatedcase@00d7q00000acoe6uad.ext', 'zinfi.integration@atos.net.ucc', 'integration@00d7q00000acoe6uad.com', 'insightssecurity@00d7q00000acoe6uad.com', 'wordpress_integration@atos.net.ucc', 'a783381@atos.net.ucc', 'eis@atos.net.ucc', 'cpq.integration@atos.net.ucc', 'a861414@eviden.com', 'andre.ebert@atos.net.unify' + stageSuffix, 'fivetran@atos.net.ucc', 'a833166@atos.net.unify' + stageSuffix, 'amanda.metz@mitel.com.unify' + stageSuffix, 'roxanne.morris@mitel.com.unify' + stageSuffix, 'matt.harvey@mitel.com.unify' + stageSuffix, 'james.tran@mitel.com.unify' + stageSuffix, 'backupuser@mitel.com.sfu', 'fwitte@atos.net.unify' + stageSuffix, 'appconnect.etl1@mitelucc.com', 'insightsintegration@00d7q00000acoe6uad.ext', 'app-services-sfo@mitel.com.ucc', 'allanzer.duran@mitel.com.prod'};

List<User> foundUsers = [SELECT Id, Alias, Email, Username FROM User WHERE Alias IN :aliasList OR Email IN :emailList OR Username IN :usernameList];

for (User u : foundUsers) {
    u.IntegrationAdminUser__c = true; // Set field value to TRUE
    usersToUpdate.add(u);
}

// Perform the update
if (!usersToUpdate.isEmpty()) {
    Database.update(usersToUpdate, false);
}
