using System;
using System.IO;
using System.Net;
using System.Web.Security;
using Newtonsoft.Json.Linq;

namespace MTApi
{
    public class MTApiFunctionalities
    {
        public string loginApiRoute = "/api/login";
        public string accountApiRoute = "/api/account";

        public JObject GenerateUserInfo()
        {
            dynamic userInfo = new JObject();
            Guid guid = Guid.NewGuid();
            userInfo.username = guid.ToString();
            userInfo.password = GenerateNewPassword();
            userInfo.email = guid.ToString() + "@test.com";
            return userInfo;
        }

        public string GenerateNewPassword()
        {
            return Membership.GeneratePassword(12, 0);
        }

        public HttpWebResponse CreateUser(string mtUrl, string username, string password, string email)
        {
            HttpWebRequest requestCreateUser = (HttpWebRequest)WebRequest.Create(mtUrl + accountApiRoute);
            requestCreateUser.Method = "POST";
            requestCreateUser.ContentType = "application/json";
            using (var streamWriter1 = new StreamWriter(requestCreateUser.GetRequestStream()))
            {
                string json = "{\"userName\":\"" + username + "\", \"password\":\"" + password + "\", \"email\":\"" + email + "\"}";

                streamWriter1.Write(json);
                streamWriter1.Flush();
                streamWriter1.Close();
            }
            HttpWebResponse httpResponseCreateUser = (HttpWebResponse)requestCreateUser.GetResponse();
                return httpResponseCreateUser;
        }

        public HttpWebResponse LoginUser(string mtUrl, string username, string password)
        {
            HttpWebRequest requestLogin = (HttpWebRequest)WebRequest.Create(mtUrl + loginApiRoute);
            requestLogin.Method = "POST";
            requestLogin.ContentType = "application/json";
            using (var streamWriter1 = new StreamWriter(requestLogin.GetRequestStream()))
            {
                string json = "{\"userName\":\"" + username + "\", \"password\":\"" + password + "\"}";

                streamWriter1.Write(json);
                streamWriter1.Flush();
                streamWriter1.Close();
            }
            HttpWebResponse httpResponseLogin = (HttpWebResponse)requestLogin.GetResponse();
            return httpResponseLogin;
        }

        public HttpWebResponse DeleteUser(string mtUrl, string userId, string adminLoginToken)
        {
            HttpWebRequest requestDeleteUser = (HttpWebRequest)WebRequest.Create(mtUrl + accountApiRoute + "/" + userId);
            requestDeleteUser.Method = "DELETE";
            requestDeleteUser.Headers[HttpRequestHeader.Authorization] = "Bearer " + adminLoginToken;
            HttpWebResponse httpResponseDeleteUser = (HttpWebResponse)requestDeleteUser.GetResponse();
            return httpResponseDeleteUser;
        }

        public JObject JsonParseHttpRes (HttpWebResponse httpWebRes)
        {
            using (var streamReader = new StreamReader(httpWebRes.GetResponseStream()))
            {
                var result = streamReader.ReadToEnd();
                Console.WriteLine(result);
                JObject json = JObject.Parse(result);
                return json;
            }
        }
    }
}
