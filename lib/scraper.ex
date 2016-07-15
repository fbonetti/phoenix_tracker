defmodule Scraper do
  alias PhoenixTracker.Location
  alias PhoenixTracker.Repo

  def fetch_data do
    key = "0GbguunS8LnHtdnrO6132nvJJqZhY4qo3"
    url = "https://api.findmespot.com/spot-main-web/consumer/rest-api/2.0/public/feed/#{key}/message.json"
    response = HTTPotion.get url
    {:ok, %{"response" =>
      %{"feedMessageResponse" =>
        %{"messages" =>
          %{"message" => messages}}}}} = Poison.decode response.body

    epoch = :calendar.datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}})

    Enum.each(messages, fn(message) ->
      fields = %{
        latitude: message["latitude"],
        longitude: message["longitude"],
        recorded_at: :calendar.gregorian_seconds_to_datetime(message["unixTime"] + epoch)
      }

      changeset = Location.changeset(%Location{}, fields)
      case Repo.insert(changeset) do
        {:ok, _location} ->
          IO.puts "success"
        {:error, changes} ->
          IO.inspect changes
      end
    end)
  end

end