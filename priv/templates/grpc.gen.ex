defmodule <%= top_mod %> do
  <%= if use_proto_path do %>
  @external_resource Path.expand("<%= proto_path %>", __DIR__)
  use Protobuf, from: Path.expand("<%= proto_path %>", __DIR__)
  <% end %>
  <%= Enum.map proto.services, fn(service) -> %>
  defmodule <%= service.name %>.Service do
    use GRPC.Service, name: "<%= service_prefix %><%= service.name %>",
                      marshal_function: :encode,
                      unmarshal_function: :decode

    <%= for rpc <- service.rpcs do %>
    rpc <%= inspect elem(rpc, 0) %>, <%= top_mod %>.<%= elem(rpc, 1) %>, <%= top_mod %>.<%= elem(rpc, 2) %>
    <% end %>
  end

  defmodule <%= service.name %>.Stub do
    use GRPC.Stub, service: <%= service.name %>.Service
  end
  <% end %>
  <%= if !use_proto_path do %>
  use Protobuf, """
  <%= proto_content %>
  """
  <% end %>

end
