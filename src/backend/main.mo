import Text "mo:base/Text";
import Routes "routes";
import Blob "mo:base/Blob";
import Http "mo:certified-cache/Http";
import Frontend "../frontend/__html__";


shared ({ caller = creator }) actor class () = this {

  stable let routesState = Routes.init();
  let routes_storage = Routes.RoutesStorage(routesState);

  public shared ({ caller }) func add_protected_route(path : Text) : async () {
    assert (caller == creator);
    ignore routes_storage.addProtectedRoute(path);
  };

  public shared ({ caller }) func update_route_cmacs(path : Text, new_cmacs : [Text]) : async () {
    assert (caller == creator);
    ignore routes_storage.updateRouteCmacs(path, new_cmacs);
  };

  public shared ({ caller }) func append_route_cmacs(path : Text, new_cmacs : [Text]) : async () {
    assert (caller == creator);
    ignore routes_storage.appendRouteCmacs(path, new_cmacs);
  };

  public query func get_route_protection(path : Text) : async ?Routes.ProtectedRoute {
    routes_storage.getRoute(path);
  };

  public query func get_route_cmacs(path : Text) : async [Text] {
    routes_storage.getRouteCmacs(path);
  };

  type HttpRequest = Frontend.Request;
  type HttpResponse = Frontend.Response;

  public query func http_request(req : Http.HttpRequest) : async Http.HttpResponse {

    if (routes_storage.isProtectedRoute(req.url)) {
      return {
        status_code = 426;
        headers = [];
        body = Blob.fromArray([]);
        streaming_strategy = null;
        upgrade = ?true;
      };
    };
     let res = Frontend.get_html(req);
        return {
            body = res.body;
            headers = res.headers;
            status_code = res.status_code;
            streaming_strategy = null;
            upgrade = ?false;
        };

  
  };

  public func http_request_update(req : Frontend.Request) : async Frontend.Response {
    let routes_array = routes_storage.listProtectedRoutes();
    for ((path, protection) in routes_array.vals()) {
      if (Text.contains(req.url, #text path)) {
        let hasAccess = routes_storage.verifyRouteAccess(path, req.url);
        let new_request = {
          url = if (hasAccess) {
            "/" # path;
          } else {
            "/";
          };
          method = req.method;
          body = req.body;
          headers = req.headers;
        };
        return (Frontend.get_html(new_request));
      };
    };

return (Frontend.get_html(req));
  };

 
};
