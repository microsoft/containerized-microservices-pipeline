namespace WebAndLoadTests
{
    using System;
    using System.Collections.Generic;
    using System.Text;
    using JSONExtractionRule;
    using Microsoft.VisualStudio.TestTools.WebTesting;
    using WebAndLoadTests.Properties;

    /* TODO: Add reference to get data for username, password, and email. */

    public class MTWebTest : WebTest
    {

        public MTWebTest()
        {
            this.PreAuthenticate = true;
            this.Proxy = "default";
        }

        public override IEnumerator<WebTestRequest> GetRequestEnumerator()
        {
            var baseUrl = Settings.Default.MTUrl;

            // Create user test
            WebTestRequest request1 = new WebTestRequest(baseUrl + "/api/account");
            request1.Method = "POST";
            StringHttpBody request1Body = new StringHttpBody();
            request1Body.ContentType = "application/json";
            request1Body.InsertByteOrderMark = false;
            request1Body.BodyString = ""; // TODO: Json body - example : { \"userName\" : \"USERNAME\" , \"password\" : \"PASSWORD\" , \"email\" : \"EMAIL\" }
            request1.Body = request1Body;
            yield return request1;
            request1 = null;

            // Login test for user
            WebTestRequest request2 = new WebTestRequest(baseUrl + "/api/login");
            request2.Method = "POST";
            StringHttpBody request2Body = new StringHttpBody();
            request2Body.ContentType = "application/json";
            request2Body.InsertByteOrderMark = false;
            request2Body.BodyString = ""; // TODO: Json body - example : { \"userName\" : \"USERNAME\" , \"password\" : \"PASSWORD\"}"
            request2.Body = request2Body;
            JsonExtractionRule extractionRule1 = new JsonExtractionRule();
            extractionRule1.Name = "token";
            extractionRule1.ContextParameterName = "loginToken";
            request2.ExtractValues += new EventHandler<ExtractionEventArgs>(extractionRule1.Extract);
            JsonExtractionRule extractionRule2 = new JsonExtractionRule();
            extractionRule2.Name = "id";
            extractionRule2.ContextParameterName = "userId";
            request2.ExtractValues += new EventHandler<ExtractionEventArgs>(extractionRule2.Extract);
            yield return request2;
            request2 = null;

            // Change password test for user
            WebTestRequest request3 = new WebTestRequest(baseUrl + "/api/account");
            request3.Method = "PUT";
            request3.Headers.Add(new WebTestRequestHeader("Authorization", ("Bearer " + this.Context["loginToken"].ToString())));
            StringHttpBody request3Body = new StringHttpBody();
            request3Body.ContentType = "application/json";
            request3Body.InsertByteOrderMark = false;
            request3Body.BodyString = ""; // TODO: Json body - example : { \"password\" : \"OLDPASSWORD\" , \"newPassword\" : \"NEWPASSWORD\" }
            request3.Body = request3Body;
            yield return request3;
            request3 = null;
            
            // Login test for user0 (needs the log in token to delete any user in the following test)
            WebTestRequest request5 = new WebTestRequest(baseUrl + "/api/login");
            request5.Method = "POST";
            StringHttpBody request5Body = new StringHttpBody();
            request5Body.ContentType = "application/json";
            request5Body.InsertByteOrderMark = false;
            request5Body.BodyString = "{ \"userName\" : \"user0\" , \"password\" : \"Password0\"}"; // Login information for user0
            request5.Body = request5Body;
            JsonExtractionRule extractionRule3 = new JsonExtractionRule();
            extractionRule3.Name = "token";
            extractionRule3.ContextParameterName = "user0LoginToken";
            request5.ExtractValues += new EventHandler<ExtractionEventArgs>(extractionRule3.Extract);
            JsonExtractionRule extractionRule4 = new JsonExtractionRule();
            extractionRule4.Name = "id";
            extractionRule4.ContextParameterName = "user0UserId";
            request5.ExtractValues += new EventHandler<ExtractionEventArgs>(extractionRule4.Extract);
            yield return request5;
            request5 = null;

            // Delete user test - uses log in token for user0 and the user id of the user to be deleted.
            WebTestRequest request6 = new WebTestRequest(baseUrl + "/api/account" + "/" + this.Context["userId"].ToString());
            request6.Method = "DELETE";
            request6.Headers.Add(new WebTestRequestHeader("Authorization", ("Bearer " + this.Context["user0LoginToken"].ToString())));
            yield return request6;
            request6 = null;
        }
    }
}
