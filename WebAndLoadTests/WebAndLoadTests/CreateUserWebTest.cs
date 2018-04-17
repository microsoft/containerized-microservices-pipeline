using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.WebTesting;
using MTApi;
using Newtonsoft.Json.Linq;
using WebAndLoadTests.Properties;

namespace WebAndLoadTests
{
    public class CreateUserWebTest : WebTest
    {
        public string mtUrl = Settings.Default.MTUrl;
        public string loginApiRoute = "/api/login";
        public string accountApiRoute = "/api/account";
        public string _userId = "";

        public CreateUserWebTest()
        {
            this.PreAuthenticate = true;
            this.Proxy = "default";
            this.PostWebTest += TearDown;
        }

        public override IEnumerator<WebTestRequest> GetRequestEnumerator()
        {
            // Create user test
            WebTestRequest requestCreateUser = new WebTestRequest(mtUrl + accountApiRoute);
            requestCreateUser.Method = "POST";
            StringHttpBody requestCreateUserBody = new StringHttpBody();
            requestCreateUserBody.ContentType = "application/json";
            requestCreateUserBody.InsertByteOrderMark = false;
            requestCreateUserBody.BodyString = ""; // TODO: Json body - example : { \"userName\" : \"USERNAME\" , \"password\" : \"PASSWORD\" , \"email\" : \"EMAIL\" }
            requestCreateUser.Body = requestCreateUserBody;
            yield return requestCreateUser;
            requestCreateUser = null;
        }

        private void TearDown(object sender, PostWebTestEventArgs e)
        {
            MTApiFunctionalities mtApi = new MTApiFunctionalities();
            JObject jsonResponse = mtApi.LoginUser(mtUrl, "", ""); // TODO: Add userName and Password for log in
            _userId = jsonResponse["id"].ToString();
            mtApi.DeleteUser(mtUrl, _userId);
        }


    }
}
