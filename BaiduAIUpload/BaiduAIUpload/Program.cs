using System;
using com.baidu.ai;

namespace BaiduAIUpload
{
    class MainClass
    {
        public static void Main(string[] args)
        {
            AccessToken.getAccessToken();
            AccessToken.add();
        }
    }
}
