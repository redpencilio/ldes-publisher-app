defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ]
  ]

  @any %{}
  @json %{ accept: %{ json: true } }
  @html %{ accept: %{ html: true } }

  # In order to forward the 'themes' resource to the
  # resource service, use the following forward rule:
  #
  match "/people/*path", @json do
    Proxy.forward conn, path, "http://resource/people/"
  end



  match "/posts/*path", @json do
    Proxy.forward conn, path, "http://resource/posts/"
  end

  match "/files/*path", @any do
    forward conn, path, "http://file/files/"
  end

  match "/images/*path" do
    Proxy.forward conn, path, "http://imageservice/image/"
  end

  match "/sessions/*path", @any do
    Proxy.forward conn, path, "http://login/sessions/"
  end

  get "/accounts/*path", @json do
    Proxy.forward conn, path, "http://resource/accounts/"
  end

  post "/accounts/*path" do
    Proxy.forward conn, path, "http://registration/accounts/"
  end

  patch "/accounts/*path" do
    Proxy.forward conn, path, "http://registration/accounts/"
  end

  delete "/accounts/*path" do
    Proxy.forward conn, path, "http://registration/accounts/"
  end

  match "/websocket/*path" do
    ws(conn, "ws://socialplatformwsmicroservice:3000/")
  end



  match "/frontend/assets/*path", @any do
    forward conn, path, "http://frontend:4200/frontend/assets/"
  end

  match "/frontend/*_path", @html do
    # *_path allows a path to be supplied, but will not yield
    # an error that we don't use the path variable.
    forward conn, [], "http://frontend:4200/frontend/index.html"
  end


  match "/*_", %{ last_call: true } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end
end
