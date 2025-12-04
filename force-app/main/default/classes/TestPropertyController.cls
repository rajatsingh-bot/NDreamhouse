@isTest
private class TestPropertyController {

    private final static String MOCK_PICTURE_NAME = 'MockPictureName';

    // Utility method to create property records
    public static void createProperties(Integer amount) {
        List<Property__c> properties = new List<Property__c>();
        for (Integer i = 0; i < amount; i++) {
            properties.add(
                new Property__c(
                    Name = 'Name ' + i,
                    Price__c = 20000,
                    Beds__c = 3,
                    Baths__c = 3,
                    City__c = 'Delhi',
                    Tags__c = 'Test'
                )
            );
        }
        insert properties;
    }

    /*************************************************************
     * Test: getPagedPropertyList
     *************************************************************/
    @isTest
    static void testGetPagedPropertyList() {

        // Create a simple test user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser.dreamhouse@example.com'
        );
        insert testUser;

        // Insert test properties (run as admin)
        System.runAs(new User(Id = UserInfo.getUserId())) {
            TestPropertyController.createProperties(5);
        }

        // Run as test user
        System.runAs(testUser) {
            Test.startTest();
            PagedResult result = PropertyController.getPagedPropertyList(
                '',
                999999,
                0,
                0,
                10,
                1
            );
            Test.stopTest();

            System.assertEquals(5, result.records.size(), 'Should return 5 properties');
        }
    }

    /*************************************************************
     * Test: getPictures - No Results
     *************************************************************/
    @isTest
    static void testGetPicturesNoResults() {
        Property__c property = new Property__c(
            Name = 'Test Property',
            City__c = 'Delhi',
            Tags__c = 'Tag'
        );
        insert property;

        Test.startTest();
        List<ContentVersion> items = PropertyController.getPictures(property.Id);
        Test.stopTest();

        System.assertEquals(null, items, 'No pictures should return null');
    }

    /*************************************************************
     * Test: getPictures - With Results
     *************************************************************/
    @isTest
    static void testGetPicturesWithResults() {
        Property__c property = new Property__c(
            Name = 'Test Property',
            City__c = 'Delhi',
            Tags__c = 'Tag'
        );
        insert property;

        // Insert mock ContentVersion
        ContentVersion picture = new ContentVersion();
        picture.Title = MOCK_PICTURE_NAME;
        picture.PathOnClient = 'picture.png';
        picture.VersionData = EncodingUtil.base64Decode('MockValue');
        insert picture;

        // Fetch actual ContentDocument
        ContentDocument doc = [
            SELECT Id, LatestPublishedVersionId
            FROM ContentDocument
            WHERE LatestPublishedVersionId = :picture.Id
            LIMIT 1
        ];

        // Create link
        ContentDocumentLink link = new ContentDocumentLink();
        link.LinkedEntityId = property.Id;
        link.ContentDocumentId = doc.Id;
        link.ShareType = 'V';
        link.Visibility = 'AllUsers';
        insert link;

        Test.startTest();
        List<ContentVersion> items = PropertyController.getPictures(property.Id);
        Test.stopTest();

        System.assertEquals(1, items.size(), 'Should return 1 picture');
        System.assertEquals(MOCK_PICTURE_NAME, items[0].Title, 'Picture name should match');
    }
}
