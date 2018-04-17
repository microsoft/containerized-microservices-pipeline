using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
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

        public CreateUserWebTest()
        {
            this.PreAuthenticate = true;
            this.Proxy = "default";
            this.PostWebTest += TearDown;
        }


        public override IEnumerator<WebTestRequest> GetRequestEnumerator()
        {
            // Create user test
            WebTestRequest request1 = new WebTestRequest(mtUrl + accountApiRoute);
            request1.Method = "POST";
            StringHttpBody request1Body = new StringHttpBody();
            request1Body.ContentType = "application/json";
            request1Body.InsertByteOrderMark = false;
            request1Body.BodyString = ""; // TODO: Json body - example : { \"userName\" : \"USERNAME\" , \"password\" : \"PASSWORD\" , \"email\" : \"EMAIL\" }
            request1.Body = request1Body;
            yield return request1;
            request1 = null;
        }


        private void TearDown(object sender, PostWebTestEventArgs e)
        {
            MTApiFunctionalities mtApi = new MTApiFunctionalities();
            JObject jsonResponse = mtApi.loginUser(mtUrl, "user1x", "Password1x");
            mtApi.deleteUser(mtUrl, jsonResponse["id"].ToString());
        }


    }
}
