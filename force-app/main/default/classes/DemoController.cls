/*****
 * *Name: salesforce development branch
 * Author : shadow of master branch
 * date: 11th november
 * 
 ************/
public with sharing class DemoController {
    public DemoController() {}

    public DemoController(ApexPages.StandardController controller) {
        String lastName = ApexPages.currentPage().getParameters().get('lastName');
        if (lastName != null) {
            Contact theContact = [SELECT Id FROM Contact WHERE LastName = :lastName LIMIT 1];
            ApexPages.currentPage().getParameters().put('id', theContact.Id);
        }
    }

    public String getAppVersion() {
        return '1.0.0';
    }

    public String sayHello() {
        return 'Hello from DemoController!';
    }

    public String sayHello(String name) {
        return 'Hello, ' + name + '! Welcome from DemoController.';
    }

    public class Calculator {
        public Integer add(Integer a, Integer b) {
            return a + b;
        }

        // ✅ fixed: renamed variable from "number" to "num"
        public Integer square(Integer num) {
            return num * num;
        }
    }
}