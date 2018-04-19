namespace WebAndLoadTests
{
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Net;
    using Microsoft.VisualStudio.TestTools.WebTesting;
    using MTApi;
    using Newtonsoft.Json.Linq;
    using WebAndLoadTests.Properties;

    public class ChangePasswordTest : WebTest
    {
        public string mtUrl = Settings.Default.MTUrl;
        public string adminUsername = Settings.Default.AdminUsername;
        public string adminPassword = Settings.Default.AdminPassword;
        public string username = ""; // TODO: Add username
        public string password = ""; // TODO: Add password
        public string newPassword = ""; // TODO: Add newPassword
        public string email = ""; // TODO: Add email
        public string userId = "";
        public string userLoginToken = "";

        public ChangePasswordTest()
        {
            this.PreAuthenticate = true;
            this.Proxy = "default";
            this.PreWebTest += SetUp;
            this.PostWebTest += TearDown;
        }

        private void SetUp(object sender, PreWebTestEventArgs e)
        {
            try
            {
                MTApiFunctionalities mtApi = new MTApiFunctionalities();
                HttpWebResponse httpResCreate = mtApi.CreateUser(mtUrl, username, password, email); 
                httpResCreate.Close();
                HttpWebResponse httpResLogin = mtApi.LoginUser(mtUrl, username, password); 
                JObject jsonResponseLogin = mtApi.JsonParseHttpRes(httpResLogin);
                userLoginToken = jsonResponseLogin["token"].ToString();
                userId = jsonResponseLogin["id"].ToString();
                httpResLogin.Close();
            }
            catch (WebException webExc)
            {
                Stop(); // Stop test on exception
                Outcome = Outcome.Fail; // Fail web test due to exception
            }
        }

        public override IEnumerator<WebTestRequest> GetRequestEnumerator()
        {
            MTApiFunctionalities mtApi = new MTApiFunctionalities();
            WebTestRequest requestChangePassword = new WebTestRequest(mtUrl + mtApi.accountApiRoute);
            requestChangePassword.Method = "PUT";
            requestChangePassword.Headers.Add(new WebTestRequestHeader("Authorization", ("Bearer " + userLoginToken)));
            StringHttpBody requestChangePasswordBody = new StringHttpBody();
            requestChangePasswordBody.ContentType = "application/json";
            requestChangePasswordBody.InsertByteOrderMark = false;
            requestChangePasswordBody.BodyString = "{ \"password\" : \"" + password + "\" , \"newPassword\" : \"" + newPassword + "\" }"; 
            requestChangePassword.Body = requestChangePasswordBody;
            yield return requestChangePassword;
            requestChangePassword = null;
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
            string adminLoginToken = jsonResponseAdminLogin["token"].ToString();
            httpResAdminLogin.Close();
            HttpWebResponse httpResDel = mtApi.DeleteUser(mtUrl, userId, adminLoginToken);
            httpResDel.Close();
        }
    }
}
