@IsTest
public with sharing class TestUtils {

    public static final String PROFILE_SYSTEM_ADMINISTRATOR = 'System Administrator';
    private static Integer userCounter = 1;

    //create sample User
    public static User createUser(String uName, String profileName, Boolean doDML) {
        ++userCounter;
        UserBuilder builder = new UserBuilder()
                .withUsername(String.isEmpty(uName) ? '' : uName + userCounter + '@test.com')
                .withEmail('test123456789QW' + userCounter + '@test.com')
                .withProfile(profileName)
                .withLastname('test' + userCounter);
        if(doDML) {
            return builder.build();
        }

        return builder.buildWithoutSave();
    }

    public static User findUser(String uName) {
        String likeName = '%' + uName + '%';
        return [SELECT Id, Username, Name, Email FROM User WHERE username LIKE :likeName LIMIT 1];
    }
}