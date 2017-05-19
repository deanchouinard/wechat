defmodule Wechat.Web.WxController do
  use Wechat.Web, :controller

  def index(conn, _params) do
  weather = Wx.Worker.get_weather("Somerset, MA")
  #aweather = Wx.AprsWx.get_weather("Somerset, MA")
  aweather = Wx.AprsWx.get_weather(:file)
    render conn, "index.html", weather: weather, aweather: aweather
  end
end
