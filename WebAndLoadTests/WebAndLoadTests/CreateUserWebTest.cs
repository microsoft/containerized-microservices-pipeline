using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using Microsoft.VisualStudio.TestTools.WebTesting;
using Newtonsoft.Json.Linq;
using WebAndLoadTests.Properties;

namespace WebAndLoadTests
{
    public class CreateUserWebTest : WebTest
    {
        public string MTUrl = Settings.Default.MTUrl;
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
            WebTestRequest request1 = new WebTestRequest(MTUrl + accountApiRoute);
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
            HttpWebRequest requestLogin = (HttpWebRequest)WebRequest.Create(MTUrl + loginApiRoute);
            requestLogin.Method = "POST";
            requestLogin.ContentType = "application/json";
            using (var streamWriter = new StreamWriter(requestLogin.GetRequestStream()))
            {
                string json = ""; // TODO: Json body - example : "{\"userName\":\"USERNAME\", \"password\":\"PASSWORD\"}";

                streamWriter.Write(json);
                streamWriter.Flush();
                streamWriter.Close();
            }

            var httpResponseLogin = (HttpWebResponse)requestLogin.GetResponse();
            JToken token;
            JToken userId;

            using (var streamReader = new StreamReader(httpResponseLogin.GetResponseStream()))
            {
                var result = streamReader.ReadToEnd();
                Console.WriteLine(result);
                JObject json = JObject.Parse(result);
                token = json["token"];
                userId = json["id"];
            }

            // Login as user0 (needs the log in token to delete other users)
            HttpWebRequest requestLoginUser0 = (HttpWebRequest)WebRequest.Create(MTUrl + loginApiRoute);
            requestLoginUser0.Method = "POST";
            requestLoginUser0.ContentType = "application/json";
            using (var streamWriter1 = new StreamWriter(requestLoginUser0.GetRequestStream()))
            {
                string json = "{\"userName\":\"user0\", \"password\":\"Password0\"}";

                streamWriter1.Write(json);
                streamWriter1.Flush();
                streamWriter1.Close();
            }

            var httpResponseLoginUser0 = (HttpWebResponse)requestLoginUser0.GetResponse();
            JToken user0Token;
            
            using (var streamReader = new StreamReader(httpResponseLoginUser0.GetResponseStream()))
            {
                var result = streamReader.ReadToEnd();
                Console.WriteLine(result);
                JObject json = JObject.Parse(result);
                user0Token = json["token"];
            }

            // Delete user - uses log in token for user0 and the user id of the user to be deleted.
            HttpWebRequest requestDeleteUser = (HttpWebRequest)WebRequest.Create(MTUrl + accountApiRoute + "/" + userId);
            requestDeleteUser.Method = "DELETE";
            requestDeleteUser.Headers[HttpRequestHeader.Authorization] = "Bearer " + user0Token;
            var httpResponseDeleteUser = (HttpWebResponse)requestDeleteUser.GetResponse();
        }


    }
}
