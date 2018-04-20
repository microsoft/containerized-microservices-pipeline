﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Net;
using Microsoft.VisualStudio.TestTools.WebTesting;
using MTApi;
using Newtonsoft.Json.Linq;
using WebAndLoadTests.Properties;

namespace WebAndLoadTests
{
    public class CreateUserWebTest : WebTest
    {
        public string mtUrl = Settings.Default.MTUrl;
        public string adminUsername = Settings.Default.AdminUsername;
        public string adminPassword = Settings.Default.AdminPassword;
        public string username = ""; // TODO: Add username
        public string password = ""; // TODO: Add password
        public string email = ""; // TODO: Add email

        public CreateUserWebTest()
        {
            this.PreAuthenticate = true;
            this.Proxy = "default";
            this.PostWebTest += TearDown;
        }

        public override IEnumerator<WebTestRequest> GetRequestEnumerator()
        {
            MTApiFunctionalities mtApi = new MTApiFunctionalities();
            WebTestRequest requestCreateUser = new WebTestRequest(mtUrl + mtApi.accountApiRoute);
            requestCreateUser.Method = "POST";
            StringHttpBody requestCreateUserBody = new StringHttpBody();
            requestCreateUserBody.ContentType = "application/json";
            requestCreateUserBody.InsertByteOrderMark = false;
            requestCreateUserBody.BodyString = "{ \"userName\" : \"" + username + "\" , \"password\" : \"" + password + "\" , \"email\" : \"" + email + "\" }"; 
            requestCreateUser.Body = requestCreateUserBody;
            yield return requestCreateUser;
            requestCreateUser = null;
        }

        private void TearDown(object sender, PostWebTestEventArgs e)
        {
            MTApiFunctionalities mtApi = new MTApiFunctionalities();
            HttpWebResponse httpResLogin = mtApi.LoginUser(mtUrl, username, password); 
            JObject jsonResponse = mtApi.JsonParseHttpRes(httpResLogin);
            string userId = jsonResponse["id"].ToString();
            httpResLogin.Close();
            HttpWebResponse httpResAdminLogin = mtApi.LoginUser(mtUrl, adminUsername, adminPassword); // Login as admin to get admin token to delete user
            JObject jsonResponseAdminLogin = mtApi.JsonParseHttpRes(httpResAdminLogin);
            string adminLoginToken = jsonResponseAdminLogin["token"].ToString();
            httpResAdminLogin.Close();
            HttpWebResponse httpResDel = mtApi.DeleteUser(mtUrl, userId, adminLoginToken);
            httpResDel.Close();
        }
    }
}
