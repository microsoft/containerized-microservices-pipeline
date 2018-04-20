using System.Collections.Generic;
using System.Net;
using Microsoft.VisualStudio.TestTools.WebTesting;
using MTApi;
using Newtonsoft.Json.Linq;
using WebAndLoadTests.Properties;

namespace WebAndLoadTests
{
    public class LoginUserTest : WebTest
    {
        public string mtUrl = Settings.Default.MTUrl;
        public string adminUsername = Settings.Default.AdminUsername;
        public string adminPassword = Settings.Default.AdminPassword;
        public string username = "";
        public string password = "";
        public string email = "";
        public string userId = "";

        public LoginUserTest()
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
                JObject userInfo = mtApi.GenerateUserInfo();
                username = userInfo["username"].ToString();
                password = userInfo["password"].ToString();
                email = userInfo["email"].ToString();
                HttpWebResponse httpResCreate = mtApi.CreateUser(mtUrl, username, password, email); 
                JObject jsonResponse = mtApi.JsonParseHttpRes(httpResCreate);
                userId = jsonResponse["id"].ToString();
                httpResCreate.Close();
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
            WebTestRequest requestLogin = new WebTestRequest(mtUrl + mtApi.loginApiRoute);
            requestLogin.Method = "POST";
            StringHttpBody requestLoginBody = new StringHttpBody();
            requestLoginBody.ContentType = "application/json";
            requestLoginBody.InsertByteOrderMark = false;
            requestLoginBody.BodyString = "{ \"userName\" : \"" + username + "\" , \"password\" : \"" + password + "\"}"; 
            requestLogin.Body = requestLoginBody;
            yield return requestLogin;
            requestLogin = null;
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
