using ArbitraryAspNetCoreWebApi;

namespace ArbitraryAspNetCoreWebApiTests
{
    public class WeatherForecastTests
    {
        [Theory]
        [InlineData(0, 32)]
        [InlineData(100, 212)]

        public void TemperatureF_ForTemperatureC_ReturnsExpectedValue(int temperatureC, int expectedResultInF)
        {
            // Arrange
            var weatherForecast = new WeatherForecast
            {
                TemperatureC = temperatureC
            };

            // Act
            var temperatureF = weatherForecast.TemperatureF;
            
            // Assert
            Assert.Equal(expectedResultInF, temperatureF);
        }
    }
}
