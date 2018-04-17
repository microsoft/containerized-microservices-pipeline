using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace MTApi
{
    public class MTApiFunctionalities
    {
        public string loginApiRoute = "/api/login";
        public string accountApiRoute = "/api/account";

        public void deleteUser(string mtUrl, string userId)
        {
            // Delete user - uses log in token for user0 and the user id of the user to be deleted.
            HttpWebRequest requestDeleteUser = (HttpWebRequest)WebRequest.Create(mtUrl + accountApiRoute + "/" + userId);
            requestDeleteUser.Method = "DELETE";
            JObject jsonResponse = loginUser(mtUrl, "user0", "Password0");
            requestDeleteUser.Headers[HttpRequestHeader.Authorization] = "Bearer " + jsonResponse["token"];
            var httpResponseDeleteUser = (HttpWebResponse)requestDeleteUser.GetResponse();
        }

        public JObject loginUser(string mtUrl, string userName, string password)
        {
            // Login as user0 (needs the log in token to delete other users)
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
    }
}
