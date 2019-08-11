@IsTest
public with sharing class UserBuilder {
    private User usr;

    public UserBuilder() {
        usr = new User();
    }

    public UserBuilder withUsername(String username) {
        usr.Username = username;
        return this;
    }

    public UserBuilder withEmail(String email) {
        usr.Email = email;
        return this;
    }

    public UserBuilder withLastname(String lastname) {
        usr.LastName = lastname;
        return this;
    }

    public UserBuilder withFirstName(String firstName) {
        usr.FirstName= firstName;
        return this;
    }

    public UserBuilder withProfile(String profile) {
        usr.ProfileId = profileId(profile);
        return this;
    }

    public User buildWithoutSave() {
        usr.localeSidKey = 'en_US';
        usr.languageLocaleKey = 'en_US';
        usr.TimeZoneSidKey='GMT';
        usr.EmailEncodingKey='UTF-8';
        usr.Alias = 'utu';
        return usr;
    }

    public User build() {
        buildWithoutSave();
        insert usr;
        return usr;
    }

    /**** Profiles ****/
    // Get profile ID by Name
    static Map<String,String>profileIds = new Map<String,String>();
    public static ID profileId(String profileName) {
        if (profileIds.containsKey(profileName)) {
            return profileIds.get(profileName);
        }
        else {
            ID profileID = [SELECT Id, Name FROM Profile WHERE Name = :profileName LIMIT 1].Id;
            profileIds.put(profileName,profileID);
        }

        return profileIds.get(profileName);
    }
}