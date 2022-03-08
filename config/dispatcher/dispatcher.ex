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
  #
  # Run `docker-compose restart dispatcher` after updating
  # this file.

  # match "/library/*path", @any do
  #   Proxy.forward conn, path, "http://booksservice/"
  # end

  # match "/library/query/*path", @any do
  #   Proxy.forward conn, path, "http://booksservice/query/"
  # end

  match "/*_", %{ last_call: true } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end
end
