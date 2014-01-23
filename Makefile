REBAR="./rebar"

compile:
	$(REBAR) compile

run: compile
	erl -config $(CURDIR)/sys -pa ebin deps/*/ebin -s sync go -s evalso
