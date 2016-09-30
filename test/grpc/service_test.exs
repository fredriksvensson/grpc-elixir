defmodule GRPC.ServiceTest do
  use ExUnit.Case, async: true

  defmodule Routeguide do
    @external_resource Path.expand("../../priv/protos/route_guide.proto", __DIR__)
    use Protobuf, from: Path.expand("../../priv/protos/route_guide.proto", __DIR__)

    defmodule RouteGuide.Service do
      use GRPC.Service, name: "routeguide.RouteGuide"

      rpc :GetFeature, Routeguide.Point, Routeguide.Feature
      rpc :ListFeatures, Routeguide.Rectangle, stream(Routeguide.Feature)
      rpc :RecordRoute, stream(Routeguide.Point), Routeguide.RouteSummary
      rpc :RouteChat, stream(Routeguide.RouteNote), stream(Routeguide.RouteNote)
    end

    defmodule RouteGuide.Stub do
      use GRPC.Stub, service: RouteGuide.Service
    end

    defmodule RouteGuide.Server do
      use GRPC.Server, service: RouteGuide.Service

      def get_feature(point) do
        Routeguide.Feature.new(location: point, name: "#{point.latitude},#{point.longitude}")
      end
    end
  end

  test "Unary RPC works" do
    GRPC.Server.start(Routeguide.RouteGuide.Server, "localhost:50051", insecure: true)

    {:ok, channel} = GRPC.Channel.connect("localhost:50051", insecure: true)
    point = Routeguide.Point.new(latitude: 409_146_138, longitude: -746_188_906)
    feature = channel |> Routeguide.RouteGuide.Stub.get_feature(point)
    assert feature == Routeguide.Feature.new(location: point, name: "409146138,-746188906")
  end
end
