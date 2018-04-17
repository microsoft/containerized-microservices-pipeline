namespace WebAndLoadTests
{
    using System.Collections.Generic;
    using Microsoft.VisualStudio.TestTools.WebTesting;
    using MTApi;
    using Newtonsoft.Json.Linq;
    using WebAndLoadTests.Properties;
    
    public class DeleteUserTest : WebTest
    {
        public string mtUrl = Settings.Default.MTUrl;
        public string loginApiRoute = "/api/login";
        public string accountApiRoute = "/api/account";
        public string _userId = "";
        public string _adminLoginToken = "";

        public DeleteUserTest()
        {
            this.PreAuthenticate = true;
            this.Proxy = "default";
            this.PreWebTest += SetUp;
        }

        private void SetUp(object sender, PreWebTestEventArgs e)
        {
            MTApiFunctionalities mtApi = new MTApiFunctionalities();
            JObject jsonResponseCreate = mtApi.CreateUser(mtUrl, "", "", ""); // TODO: Add username, password, and email for create user
            JObject jsonResponseLogin = mtApi.LoginUser(mtUrl, "", ""); // TODO: Add userName and Password for log in
            _userId = jsonResponseLogin["id"].ToString();
            JObject jsonResponseAdminLogin = mtApi.LoginUser(mtUrl, "", ""); // TODO: Add admin userName and Password for admin log in (to get token)
            _adminLoginToken = jsonResponseAdminLogin["token"].ToString();
        }

        public override IEnumerator<WebTestRequest> GetRequestEnumerator()
        {
            WebTestRequest requestDeleteUser = new WebTestRequest(mtUrl + accountApiRoute + "/" + _userId);
            requestDeleteUser.Method = "DELETE";
            requestDeleteUser.Headers.Add(new WebTestRequestHeader("Authorization", ("Bearer " + _adminLoginToken)));
            yield return requestDeleteUser;
            requestDeleteUser = null;
        }
    }
}
