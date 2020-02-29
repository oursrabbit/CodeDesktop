using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace QinAdmin_Win
{
    public enum ModelEditMode
    {
        Add, Delete, Edit, Search
    }
    public static class DatabaseHelper
    {
        public static String LeancloudAppid = "Tf0m64H1aEhwItMDiMH87pD7-gzGzoHsz";
        public static String LeancloudAppKey = "SWhko62oywljuSCkqRnNdjiM";
        public static String LeancloudAPIBaseURL = "https://tf0m64h1.lc-cn-n1-shared.com";
        public static String LeancloudIDHeader = "X-LC-Id";
        public static String LeancloudKeyHeader = "X-LC-Key";
        public static String HttpContentTypeHeader = "Content-Type";
        public static String HttpContentTypeJSONUTF8 = "application/json; charset=utf-8";

        public static bool LCGetExcelFile(String tableName, String saveTo)
        {
            try
            {
                var jsonDic = new Dictionary<String, Object>();
                jsonDic.Add("ForTableName", tableName);
                var jsonString = Newtonsoft.Json.JsonConvert.SerializeObject(jsonDic);

                var searchURL = LeancloudAPIBaseURL + @"/1.1/classes/Excel?where=" + System.Web.HttpUtility.UrlEncode(jsonString);
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(searchURL);
                request.Method = "GET";
                request.ContentType = "application/json; charset=UTF-8";
                request.Headers.Add(DatabaseHelper.LeancloudIDHeader, DatabaseHelper.LeancloudAppid);
                request.Headers.Add(DatabaseHelper.LeancloudKeyHeader, DatabaseHelper.LeancloudAppKey);

                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                if (response.StatusCode == HttpStatusCode.OK)
                {
                    Stream myResponseStream = response.GetResponseStream();
                    StreamReader myStreamReader = new StreamReader(myResponseStream, Encoding.UTF8);
                    string retString = myStreamReader.ReadToEnd();
                    var json = JsonConvert.DeserializeObject<Dictionary<String, Object>>(retString);
                    var results = (json["results"] as JArray).ToObject<List<Dictionary<String, Object>>>();
                    var excelFile = (results.First()["ExcelFile"] as JObject).ToObject<Dictionary<String, Object>>();
                    var fileURL = excelFile["url"] as String;
                    new WebClient().DownloadFile(fileURL, saveTo);
                    return true;
                }
                return false;
            }
            catch 
            {
                return false;
            }
        }

        public static Dictionary<String, Object> LCSearch(String searchURL)
        {
            try
            {
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(searchURL);
                request.Method = "GET";
                request.ContentType = "application/json; charset=UTF-8";
                request.Headers.Add(DatabaseHelper.LeancloudIDHeader, DatabaseHelper.LeancloudAppid);
                request.Headers.Add(DatabaseHelper.LeancloudKeyHeader, DatabaseHelper.LeancloudAppKey);

                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                if (response.StatusCode == HttpStatusCode.OK)
                {
                    Stream myResponseStream = response.GetResponseStream();
                    StreamReader myStreamReader = new StreamReader(myResponseStream, Encoding.UTF8);
                    string retString = myStreamReader.ReadToEnd();
                    return JsonConvert.DeserializeObject<Dictionary<String, Object>>(retString);
                }
                return null;
            }
            catch
            {
                return null;
            }
        }

        public static bool LCCreate(String createURL, String jsonString)
        {
            try
            {
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(createURL);
                request.Method = "POST";
                request.ContentType = "application/json; charset=UTF-8";
                request.Headers.Add(DatabaseHelper.LeancloudIDHeader, DatabaseHelper.LeancloudAppid);
                request.Headers.Add(DatabaseHelper.LeancloudKeyHeader, DatabaseHelper.LeancloudAppKey);
                using (var streamWriter = new StreamWriter(request.GetRequestStream()))
                {
                    streamWriter.Write(jsonString);
                }
                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                return response.StatusCode == HttpStatusCode.Created;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
                return false;
            }
        }

        public static bool LCUpdate(String updateURL, String jsonString )
        {
            try
            {
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(updateURL);
                request.Method = "PUT";
                request.ContentType = "application/json; charset=UTF-8";
                request.Headers.Add(DatabaseHelper.LeancloudIDHeader, DatabaseHelper.LeancloudAppid);
                request.Headers.Add(DatabaseHelper.LeancloudKeyHeader, DatabaseHelper.LeancloudAppKey);
                using (var streamWriter = new StreamWriter(request.GetRequestStream()))
                {
                    streamWriter.Write(jsonString);
                }
                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                return response.StatusCode == HttpStatusCode.OK;
            }
            catch
            {
                return false;
            }
        }

        public static bool LCDelete(String deleteURL)
        {
            try
            {
                HttpWebRequest request = (HttpWebRequest)WebRequest.Create(deleteURL);
                request.Method = "DELETE";
                request.ContentType = "application/json; charset=UTF-8";
                request.Headers.Add(DatabaseHelper.LeancloudIDHeader, DatabaseHelper.LeancloudAppid);
                request.Headers.Add(DatabaseHelper.LeancloudKeyHeader, DatabaseHelper.LeancloudAppKey);

                HttpWebResponse response = (HttpWebResponse)request.GetResponse();
                return response.StatusCode == HttpStatusCode.OK;
            }
            catch 
            {
                return false;
            }
        }
    }
}
