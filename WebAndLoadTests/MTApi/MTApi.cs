using System;
using System.IO;
using System.Net;
using Newtonsoft.Json.Linq;

namespace MTApi
{
    public class MTApiFunctionalities
    {
        public string loginApiRoute = "/api/login";
        public string accountApiRoute = "/api/account";

        public JObject CreateUser(string mtUrl, string userName, string password, string email)
        {
            HttpWebRequest requestCreateUser = (HttpWebRequest)WebRequest.Create(mtUrl + accountApiRoute);
            requestCreateUser.Method = "POST";
            requestCreateUser.ContentType = "application/json";
            using (var streamWriter1 = new StreamWriter(requestCreateUser.GetRequestStream()))
            {
                string json = "{\"userName\":\"" + userName + "\", \"password\":\"" + password + "\", \"email\":\"" + email + "\"}";

                streamWriter1.Write(json);
                streamWriter1.Flush();
                streamWriter1.Close();
            }

            var httpResponseCreateUser = (HttpWebResponse)requestCreateUser.GetResponse();

            using (var streamReader = new StreamReader(httpResponseCreateUser.GetResponseStream()))
            {
                var result = streamReader.ReadToEnd();
                Console.WriteLine(result);
                JObject json = JObject.Parse(result);
                return json;
            }
        }

        public JObject LoginUser(string mtUrl, string userName, string password)
        {
            HttpWebRequest requestLogin = (HttpWebRequest)WebRequest.Create(mtUrl + loginApiRoute);
            requestLogin.Method = "POST";
            requestLogin.ContentType = "application/json";
            using (var streamWriter1 = new StreamWriter(requestLogin.GetRequestStream()))
            {
                string json = "{\"userName\":\"" + userName + "\", \"password\":\"" + password + "\"}";

                streamWriter1.Write(json);
                streamWriter1.Flush();
                streamWriter1.Close();
            }

            var httpResponseLogin = (HttpWebResponse)requestLogin.GetResponse();

            using (var streamReader = new StreamReader(httpResponseLogin.GetResponseStream()))
            {
                var result = streamReader.ReadToEnd();
                Console.WriteLine(result);
                JObject json = JObject.Parse(result);
                return json;
            }
        }

        public void DeleteUser(string mtUrl, string userId)
        {
            HttpWebRequest requestDeleteUser = (HttpWebRequest)WebRequest.Create(mtUrl + accountApiRoute + "/" + userId);
            requestDeleteUser.Method = "DELETE"; 
            JObject jsonResponse = LoginUser(mtUrl, "", ""); // Uses admin log in token to delete. TODO: Add admin username and password 
            requestDeleteUser.Headers[HttpRequestHeader.Authorization] = "Bearer " + jsonResponse["token"];
            var httpResponseDeleteUser = (HttpWebResponse)requestDeleteUser.GetResponse();
        }
    }
}
