REBAR="./rebar"

compile:
	$(REBAR) compile

run: compile
	erl -pa ebin deps/*/ebin -s sync go -s evalso
