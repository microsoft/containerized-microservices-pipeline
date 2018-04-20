using System.Collections.Generic;
using System.Net;
using Microsoft.VisualStudio.TestTools.WebTesting;
using MTApi;
using Newtonsoft.Json.Linq;
using WebAndLoadTests.Properties;

namespace WebAndLoadTests
{
    public class DeleteUserTest : WebTest
    {
        public string mtUrl = Settings.Default.MTUrl;
        public string adminUsername = Settings.Default.AdminUsername;
        public string adminPassword = Settings.Default.AdminPassword;
        public string username = "";
        public string password = "";
        public string email = "";
        public string userId = "";
        public string adminLoginToken = "";

        public DeleteUserTest()
        {
            this.PreAuthenticate = true;
            this.Proxy = "default";
            this.PreWebTest += SetUp;
        }

        private void SetUp(object sender, PreWebTestEventArgs e)
        {
            try
            {
                MTApiFunctionalities mtApi = new MTApiFunctionalities();
                JObject userInfo = mtApi.GenerateUserInfo();
                username = userInfo["username"].ToString();
                password = userInfo["password"].ToString();
                email = userInfo["email"].ToString();
                HttpWebResponse httpResCreate = mtApi.CreateUser(mtUrl, username, password, email); 
                httpResCreate.Close();
                HttpWebResponse httpResLogin = mtApi.LoginUser(mtUrl, username, password);
                JObject jsonResponseLogin = mtApi.JsonParseHttpRes(httpResLogin);
                userId = jsonResponseLogin["id"].ToString();
                httpResLogin.Close();
                HttpWebResponse httpResAdminLogin = mtApi.LoginUser(mtUrl, adminUsername, adminPassword);
                JObject jsonResponseAdminLogin = mtApi.JsonParseHttpRes(httpResAdminLogin);
                adminLoginToken = jsonResponseAdminLogin["token"].ToString();
                httpResAdminLogin.Close();
            }
            catch (WebException webExc)
            {
                Stop(); // Stop test on exception
                Outcome = Outcome.Fail; // Fail web test due to exception
                this.PostWebTest += TearDown; // Add TearDown to make sure if user exists, it gets deleted
            }
        }

        public override IEnumerator<WebTestRequest> GetRequestEnumerator()
        {
            MTApiFunctionalities mtApi = new MTApiFunctionalities();
            WebTestRequest requestDeleteUser = new WebTestRequest(mtUrl + mtApi.accountApiRoute + "/" + userId);
            requestDeleteUser.Method = "DELETE";
            requestDeleteUser.Headers.Add(new WebTestRequestHeader("Authorization", ("Bearer " + adminLoginToken)));
            yield return requestDeleteUser;
            requestDeleteUser = null;
        }

        private void TearDown(object sender, PostWebTestEventArgs e)
        {
            MTApiFunctionalities mtApi = new MTApiFunctionalities();
            if (string.IsNullOrEmpty(userId)) // When SetUp fails and didn't save userId
            {
                HttpWebResponse httpResLogin = mtApi.LoginUser(mtUrl, username, password);
                JObject jsonResponse = mtApi.JsonParseHttpRes(httpResLogin);
                userId = jsonResponse["id"].ToString();
                httpResLogin.Close();
            }
            HttpWebResponse httpResAdminLogin = mtApi.LoginUser(mtUrl, adminUsername, adminPassword); // Login as admin to get admin token to delete user
            JObject jsonResponseAdminLogin = mtApi.JsonParseHttpRes(httpResAdminLogin);
            adminLoginToken = jsonResponseAdminLogin["token"].ToString();
            httpResAdminLogin.Close();
            HttpWebResponse httpResDel = mtApi.DeleteUser(mtUrl, userId, adminLoginToken);
            httpResDel.Close();
        }
    }
}
