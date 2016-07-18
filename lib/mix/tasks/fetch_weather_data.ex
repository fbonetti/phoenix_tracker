defmodule Mix.Tasks.FetchWeatherData do
  use Mix.Task
  alias PhoenixTracker.Location
  alias PhoenixTracker.Repo
  require HTTPotion
  require Ecto.Query
  
  def run(_args) do
    Repo.start_link

    query = Ecto.Query.from l in Location, where: is_nil(l.summary)
    locations = Repo.all(query)

    Enum.each(locations, fn(location) ->
      weather_info = get_weather_info(location)

      fields = %{
        summary: weather_info["summary"],
        icon: weather_info["icon"],
        temperature: weather_info["temperature"],
        humidity: weather_info["humidity"],
        visibility: weather_info["visibility"],
        wind_bearing: weather_info["windBearing"],
        wind_speed: weather_info["windSpeed"]
      }

      changeset = Location.changeset(location, fields)      

      case Repo.update(changeset) do
        {:ok, _location} ->
          IO.puts "success"
        {:error, changes} ->
          IO.inspect changes
      end
    end)
  end

  def get_weather_info(%Location{latitude: latitude, longitude: longitude, recorded_at: recorded_at}) do
    epoch = :calendar.datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}})
    timestamp = recorded_at
      |> Ecto.DateTime.to_erl
      |> :calendar.datetime_to_gregorian_seconds
      |> -(epoch)
    key = Application.fetch_env!(:phoenix_tracker, :forecast_io_api_key)
    url = "https://api.forecast.io/forecast/#{key}/#{latitude},#{longitude},#{timestamp}"
    HTTPotion.start
    response = HTTPotion.get url
    {:ok, %{"currently" => data}} = Poison.decode response.body
    data
  end
end