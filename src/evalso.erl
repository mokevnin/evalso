-module(evalso).

-export([evaluate/2]).

evaluate(Lng, Text) ->
  Body = [
    {language, iolist_to_binary(io_lib:format("~p", [Lng]))},
    {code, iolist_to_binary(Text)}
  ],

  case ibrowse:send_req("http://eval.so/api/evaluate",
      [{"Content-Type", "application/json"}], post, jsx:encode(Body)) of
    {ok, _, _, Json} ->
      case jsx:decode(iolist_to_binary(Json)) of
        [{<<"stdout">>, Stdout}, {<<"stderr">>, Stderr}, _, {<<"exitCode">>, 0}] ->
          {ok, success_exit, Stdout, Stderr};
        [{<<"stdout">>, Stdout}, {<<"stderr">>, Stderr}, _, {<<"exitCode">>, 1}] ->
          {ok, bad_exit, Stdout, Stderr}
      end;
    {error, Reason} -> {error, Reason}
  end.
