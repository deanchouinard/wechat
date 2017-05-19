defmodule Wx.AprsWx do
  use GenServer

  @name AW

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: AW] )
  end

  def get_weather(location) do
    GenServer.call(@name, {:location, location})
  end

  def get_stats do
    GenServer.call(@name, :get_stats)
  end

  def reset_stats do
    GenServer.cast(@name, :reset_stats)
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def terminate(reason, stats) do
    IO.puts "server terminated because of #{inspect reason}"
    inspect stats
    :ok
  end

  def handle_call({:location, location}, _from, stats) do
    #case temperature_of(location) do
    case weather_of(location) do
      {:ok, weather} ->
        #new_stats = update_stats(stats, location)
        {:reply, weather, stats}

      _ ->
        {:reply, :error, stats}
    end
  end

  def handle_call(:get_stats, _from, stats) do
    {:reply, stats, stats}
  end

  def handle_cast(:reset_stats, _stats) do
    {:noreply, %{}}
  end

  def handle_cast(:stop, stats) do
    {:stop, :normal, stats}
  end

  def handle_info(msg, stats) do
    IO.puts "received #{inspect msg}"
    {:noreply, stats}
  end

  ## Helper Functions

  defp weather_of(:file) do
    body = file_data()
    parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}})
  end

  defp weather_of(location) do
    url_for(location) |> IO.inspect |> HTTPoison.get |> parse_response
  end

  defp url_for(location) do
    "http://www.findu.com/cgi-bin/raw.cgi?call=DW4966&start=1&time=1"
    #  "http://api.openweathermap.org/data/2.5/weather?q=#{location}&APPID=#{apikey()}"
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}})
  #defp parse_response({:ok, body })
  do
    #body |> JSON.decode! |> process_weather
    IO.inspect body, label: "body:"
    body = Floki.parse(body) |> Floki.find("tt") |> Floki.text |>
      String.split("\n") |> Enum.filter(fn (x) -> x != "" end) |> List.last
    
    fields = [{:temp, 84..86}, {:humid, 100..101}, {:barom, 103..106}]
    
    fbody = for {f, r} <- fields, into: %{}, do: {f, String.slice(body, r)}
    #for {f, r} <- fields, into: %{}, do: {f, r}
    {:ok, fbody}
  end

  defp parse_response(_) do
    IO.puts "ERROR************"
    :error
  end

  defp process_weather(json) do
    IO.inspect json
    weather = %{}
    try do
      temp = (json["main"]["temp"] * 9/5 - 459.67) |> Float.round(1)
      weather = Map.put_new(weather, :temp, temp)
      humid = json["main"]["humidity"]
      weather = Map.put_new(weather, :humid, humid)
      {:ok, weather}
    rescue
      _ -> :error
    end
  end

  defp apikey do
    Application.get_env(:wechat, Wx.Worker)[:ow]
  end

  defp update_stats(old_stats, location) do
    case Map.has_key?(old_stats, location) do
      true ->
        Map.update!(old_stats, location, &(&1 + 1))
      false ->
        Map.put_new(old_stats, location, 1)
    end
  end

  defp file_data do
    {:ok, page} = File.read("test/RawDW4966.html")
    page
  end

end

