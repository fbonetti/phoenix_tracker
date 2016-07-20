defmodule Mix.Tasks.FetchGpsData do
  use Mix.Task
  alias PhoenixTracker.Location
  alias PhoenixTracker.Repo
  require HTTPotion
  
  def run(_args) do
    Repo.start_link

    epoch = :calendar.datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}})

    Enum.each(get_messages, fn(message) ->
      if Repo.get(Location, message["id"]) do
        IO.puts "location with ID: #{message["id"]} already exists"
      else
        fields = %{
          id: message["id"],
          latitude: message["latitude"],
          longitude: message["longitude"],
          recorded_at: :calendar.gregorian_seconds_to_datetime(message["unixTime"] + epoch),
          battery_state: message["batteryState"],
          message_type: message["messageType"],
          message_content: message["messageContent"]
        }

        changeset = Location.changeset(%Location{}, fields)
        

        case Repo.insert(changeset) do
          {:ok, _location} ->
            IO.puts "success"
          {:error, changes} ->
            IO.inspect changes
        end
      end
    end)
  end

  def get_messages do
    key = Application.fetch_env!(:phoenix_tracker, :spot_api_key)
    url = "https://api.findmespot.com/spot-main-web/consumer/rest-api/2.0/public/feed/#{key}/message.json"
    HTTPotion.start

    response = HTTPotion.get url

    {:ok, %{"response" =>
      %{"feedMessageResponse" =>
        %{"messages" =>
          %{"message" => messages}}}}} = Poison.decode response.body

    messages
  end
end