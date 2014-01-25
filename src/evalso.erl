%TODO spec
-module(evalso).

-export([start/0, evaluate/2]).

start() ->
  Apps = [ibrowse, jsx, evalso],
  [application:start(App) || App <- Apps],
  ok.

evaluate(RawLng, Text) ->
  Lng = if
    is_binary(RawLng) -> RawLng;
    true -> iolist_to_binary(io_lib:format("~p", [RawLng]))
  end,
  Body = [
    {language, Lng},
    {code, iolist_to_binary(Text)}
  ],

  {ok, ApiHost} = application:get_env(evalso, api_host),
  EvaluateUrl = ApiHost ++ "/evaluate",
  case ibrowse:send_req(EvaluateUrl, [{"Content-Type", "application/json"}], post, jsx:encode(Body)) of
    {ok, _, _, RespBody} ->
      BinBody = iolist_to_binary(RespBody),
      case jsx:is_json(BinBody) of
        false ->
          {error, "received body is not json"};
        true ->
          case jsx:decode(BinBody) of
            [{<<"stdout">>, Stdout}, {<<"stderr">>, Stderr}, _, {<<"exitCode">>, ExitCode}] ->
              {ok, {ExitCode, Stdout, Stderr}}
          end
      end;
    {error, Reason} -> {error, Reason}
  end.
