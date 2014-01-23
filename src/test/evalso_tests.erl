-module(evalso_tests).

-compile(export_all).

-include_lib("eunit/include/eunit.hrl").

%FIXME extract new and unload
evalso_test() ->
  meck:new(ibrowse),
  Func = fun(_Url, _Headers, post, _Body) ->
      Result = [
        {<<"stdout">>, <<"muha">>},
        {<<"stderr">>, <<"ehu">>},
        {<<"key">>, <<"value">>},
        {<<"exitCode">>, 0}],
    {ok, undefined, undefined, jsx:encode(Result)}
  end,
  meck:expect(ibrowse, send_req, Func),
  {ok, {success_exit, _Stdout, _Stderr}} = evalso:evaluate(ruby, "puts 1"),

  ?assert(meck:validate(ibrowse)),
  meck:unload(ibrowse),
  ok.

evalso_bad_response_test() ->
  meck:new(ibrowse),
  Func = fun(_Url, _Headers, post, _Body) ->
    {ok, undefined, undefined, "bad_request"}
  end,
  meck:expect(ibrowse, send_req, Func),
  {error, _Reason} = evalso:evaluate(ruby, "puts 1"),

  ?assert(meck:validate(ibrowse)),
  meck:unload(ibrowse),
  ok.
