namespace WebAndLoadTests
{
    using System.Collections.Generic;
    using Microsoft.VisualStudio.TestTools.WebTesting;
    using MTApi;
    using Newtonsoft.Json.Linq;
    using WebAndLoadTests.Properties;

    public class LoginUserTest : WebTest
    {
        public string mtUrl = Settings.Default.MTUrl;
        public string loginApiRoute = "/api/login";
        public string accountApiRoute = "/api/account";
        public string _userId = "";

        public LoginUserTest()
        {
            this.PreAuthenticate = true;
            this.Proxy = "default";
            this.PreWebTest += SetUp;
            this.PostWebTest += TearDown;
        }

        private void SetUp(object sender, PreWebTestEventArgs e)
        {
            MTApiFunctionalities mtApi = new MTApiFunctionalities();
            JObject jsonResponse = mtApi.CreateUser(mtUrl, "", "", ""); // TODO: Add username, password, and email for create user
            _userId = jsonResponse["id"].ToString();
        }

        public override IEnumerator<WebTestRequest> GetRequestEnumerator()
        {
            WebTestRequest requestLogin = new WebTestRequest(mtUrl + loginApiRoute);
            requestLogin.Method = "POST";
            StringHttpBody requestLoginBody = new StringHttpBody();
            requestLoginBody.ContentType = "application/json";
            requestLoginBody.InsertByteOrderMark = false;
            requestLoginBody.BodyString = ""; // TODO: Json body - example : { \"userName\" : \"USERNAME\" , \"password\" : \"PASSWORD\"}"
            requestLogin.Body = requestLoginBody;
            yield return requestLogin;
            requestLogin = null;
        }

        private void TearDown(object sender, PostWebTestEventArgs e)
        {
            MTApiFunctionalities mtApi = new MTApiFunctionalities();
            mtApi.DeleteUser(mtUrl, _userId);
        }
    }
}
