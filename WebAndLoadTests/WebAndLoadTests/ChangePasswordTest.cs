namespace WebAndLoadTests
{
    using System.Collections.Generic;
    using Microsoft.VisualStudio.TestTools.WebTesting;
    using MTApi;
    using Newtonsoft.Json.Linq;
    using WebAndLoadTests.Properties;

    public class ChangePasswordTest : WebTest
    {
        public string mtUrl = Settings.Default.MTUrl;
        public string loginApiRoute = "/api/login";
        public string accountApiRoute = "/api/account";
        public string _userId = "";
        public string _userLoginToken = "";

        public ChangePasswordTest()
        {
            this.PreAuthenticate = true;
            this.Proxy = "default";
            this.PreWebTest += SetUp;
            this.PostWebTest += TearDown;
        }

        private void SetUp(object sender, PreWebTestEventArgs e)
        {
            MTApiFunctionalities mtApi = new MTApiFunctionalities();
            JObject jsonResponseCreate = mtApi.CreateUser(mtUrl, "", "", ""); // TODO: Add username, password, and email for create user
            JObject jsonResponseLogin = mtApi.LoginUser(mtUrl, "", ""); // TODO: Add userName and Password for log in
            _userLoginToken = jsonResponseLogin["token"].ToString();
            _userId = jsonResponseLogin["id"].ToString();
        }

        public override IEnumerator<WebTestRequest> GetRequestEnumerator()
        {
            WebTestRequest requestChangePassword = new WebTestRequest(mtUrl + accountApiRoute);
            requestChangePassword.Method = "PUT";
            requestChangePassword.Headers.Add(new WebTestRequestHeader("Authorization", ("Bearer " + _userLoginToken)));
            StringHttpBody requestChangePasswordBody = new StringHttpBody();
            requestChangePasswordBody.ContentType = "application/json";
            requestChangePasswordBody.InsertByteOrderMark = false;
            requestChangePasswordBody.BodyString = ""; // TODO: Json body - example : { \"password\" : \"OLDPASSWORD\" , \"newPassword\" : \"NEWPASSWORD\" }
            requestChangePassword.Body = requestChangePasswordBody;
            yield return requestChangePassword;
            requestChangePassword = null;
        }

        private void TearDown(object sender, PostWebTestEventArgs e)
        {
            MTApiFunctionalities mtApi = new MTApiFunctionalities();
            mtApi.DeleteUser(mtUrl, _userId);
        }
    }
}
