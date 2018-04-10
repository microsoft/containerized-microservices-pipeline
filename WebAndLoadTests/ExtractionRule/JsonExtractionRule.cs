using System;
using System.ComponentModel;
using Microsoft.VisualStudio.TestTools.WebTesting;
using Newtonsoft.Json.Linq;

namespace JSONExtractionRule
{
    [DisplayName("JSON Extraction Rule")]
    [Description("Rule for extraction values from specified Tokens from a Response.")]
    public class JsonExtractionRule : ExtractionRule
    {
        public String Name { get; set; }
        public override void Extract(object sender, ExtractionEventArgs e)
        {
            var jsonReturnedInResponse = e.Response.BodyString;
            var json = JToken.Parse(jsonReturnedInResponse);
            if (json == null)
            {
                e.Success = false;
                e.Message = "Not a JSON Format.";
            }
            else
            {
                HandleJson(e, json);
            }
        }

        private void HandleJson(ExtractionEventArgs e, JToken json)
        {
            JToken jToken = json.SelectToken(Name);

            if (jToken == null)
            {
                JEnumerable<JToken> childElements = json.Children();
                jToken = CheckChildElementsForToken(childElements);
            }

            if (jToken == null)
            {
                e.Success = false;
                e.Message = String.Format("The token {0} was not found in the response.", Name);
            }
            else
            {
                e.Success = true;
                e.WebTest.Context.Add(ContextParameterName, jToken.ToString());
            }
        }

        private JToken CheckChildElementsForToken(JEnumerable<JToken> childElements)
        {
            foreach (var childToken in childElements)
            {
                var newToken = childToken.SelectToken(Name);
                JToken jToken = newToken;
                if (jToken != null)
                {
                    return jToken;
                }
            }
            return null;
        }
    }
}