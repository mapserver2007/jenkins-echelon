using SampleApp;
using Xunit;

namespace sample_app_test
{
    public class HogeTest
    {
        [Fact]    
        public void TestName()
        {
            var hoge = new Hoge();
            Assert.Equal(hoge.GetName(), "hoge");
        }
    }
}
