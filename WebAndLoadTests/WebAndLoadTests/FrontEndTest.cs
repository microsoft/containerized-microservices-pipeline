namespace WebAndLoadTests
{
    using System;
    using System.Collections.Generic;
    using System.Text;
    using Microsoft.VisualStudio.TestTools.WebTesting;
    using WebAndLoadTests.Properties;

    public class FrontEndTest : WebTest
    {

        public FrontEndTest()
        {
            this.PreAuthenticate = true;
            this.Proxy = "default";
        }

        public override IEnumerator<WebTestRequest> GetRequestEnumerator()
        {
            string baseUrl = Settings.Default.AppUrl;

            WebTestRequest request1 = new WebTestRequest(baseUrl);
            request1.Encoding = System.Text.Encoding.GetEncoding("utf-8");
            yield return request1;
            request1 = null;
        }
    }
}
