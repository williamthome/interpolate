-module(interpolate).

-export([string/1]).
-export([parse_transform/2]).

-record(state, {string = [] :: string(), args = [] :: list()}).

% This function is just to make the compiler happy.
string(String) -> String.

parse_transform(Forms, _Options) ->
    deepmap(fun transform/1, Forms).

transform({call, _, {remote, _, {atom, _, interpolate}, {atom, _, string}}, [{string, _, String}]}) ->
    State = interpolate(String, #state{}),
    Args = lists:join($,, lists:reverse(State#state.args)),
    RawString = lists:reverse(State#state.string),
    FormatFun = lists:flatten([
        "iolist_to_binary(io_lib:format("
            "<<\"", RawString, "\"/utf8>>, [", Args, "]"
        "))."
    ]),
    {ok, Tokens, _} = erl_scan:string(FormatFun),
    {ok, [Form]} = erl_parse:parse_exprs(Tokens),
    Form;
transform(Form) ->
    Form.

interpolate([$~ | T0], State) ->
    {T1, CS} = collect_control_sequence(T0, [$t, $~]),
    {T, Args} = collect_arguments(T1, 0, []),
    interpolate(T, State#state{
        string = [lists:reverse(CS) | State#state.string],
        args = [lists:reverse(Args) | State#state.args]
    });
interpolate([H | T], State) ->
    interpolate(T, State#state{string = [H | State#state.string]});
interpolate([], State) ->
    State.

collect_control_sequence([$[ |  T], Acc) ->
    {T, Acc};
collect_control_sequence([H | T], Acc) ->
    collect_control_sequence(T, [H | Acc]).

collect_arguments([$] | T], 0, Acc) ->
    {T, Acc};
collect_arguments([$] | T], BC, Acc) ->
    collect_arguments(T, BC-1, [$] | Acc]);
collect_arguments([$[ | T], BC, Acc) ->
    collect_arguments(T, BC+1, [$[ | Acc]);
collect_arguments([H | T], BC, Acc) ->
    collect_arguments(T, BC, [H | Acc]).

deepmap(Fun, Forms) when is_function(Fun, 1), is_list(Forms) ->
    do_deepmap(Forms, Fun).

do_deepmap({match, Pos, A, B}, F) ->
    F({match, Pos, do_deepmap(A, F), do_deepmap(B, F)});
do_deepmap({call, Pos, Fun, Args}, F) ->
    F({call, Pos, Fun, do_deepmap(Args, F)});
do_deepmap({clause, CPos, CPattern, CGuards, CBody}, F) ->
    F({clause, CPos, do_deepmap(CPattern, F), do_deepmap(CGuards, F), do_deepmap(CBody, F)});
do_deepmap({function, Pos, Name, Arity, Clauses}, F) ->
    F({function, Pos, Name, Arity, do_deepmap(Clauses, F)});
do_deepmap({'case', Pos, Cond, Clauses}, F) ->
    F({'case', Pos, do_deepmap(Cond, F), do_deepmap(Clauses, F)});
do_deepmap({'if', Pos, Clauses}, F) ->
    F({'if', Pos, do_deepmap(Clauses, F)});
do_deepmap(Forms, F) when is_list(Forms) ->
    lists:map(fun(Form) -> do_deepmap(Form, F) end, Forms);
do_deepmap(Form, F) ->
    F(Form).
