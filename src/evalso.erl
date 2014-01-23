%TODO spec
-module(evalso).

-export([start/0, evaluate/2]).

start() ->
  Apps = [ibrowse, jsx, evalso],
  [application:start(App) || App <- Apps],
  ok.

evaluate(Lng, Text) ->
  Body = [
    {language, iolist_to_binary(io_lib:format("~p", [Lng]))},
    {code, iolist_to_binary(Text)}
  ],

  {ok, ApiHost} = application:get_env(evalso, api_host),
  EvaluateUrl = ApiHost ++ "/evaluate",
  case ibrowse:send_req(EvaluateUrl, [{"Content-Type", "application/json"}], post, jsx:encode(Body)) of
    {ok, _, _, Json} ->
      case jsx:is_json(Json) of
        false ->
          {error, "received body is not json"};
        true ->
          case jsx:decode(iolist_to_binary(Json)) of
            [{<<"stdout">>, Stdout}, {<<"stderr">>, Stderr}, _, {<<"exitCode">>, 0}] ->
              {ok, {success_exit, Stdout, Stderr}};
            [{<<"stdout">>, Stdout}, {<<"stderr">>, Stderr}, _, {<<"exitCode">>, 1}] ->
              {ok, {bad_exit, Stdout, Stderr}}
          end
      end;
    {error, Reason} -> {error, Reason}
  end.
