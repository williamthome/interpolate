%%%-----------------------------------------------------------------------------
%%% @author William Fank Thomé [https://github.com/williamthome]
%%% @copyright 2023 William Fank Thomé
%%% @doc Interpolate test module.
%%% @end
%%%-----------------------------------------------------------------------------
-module(interpolate_test).

-include("interpolate.hrl").
-include_lib("eunit/include/eunit.hrl").

interpolate_test() ->
    X = 1,
    Y = 1,

    Map = #{a => a, b => b},

    Result0 = ?f("The sum of ~p[X] and ~p[Y] is ~p[X+Y]"),
    Result1 = ?f("~Kp[reversed, Map]"),
    Result2 = ?f("~p[[1,2,3]]"),
    Result3 = ?f("¥£€$¢₡₢₣₤₥₦₧₨₩₪₫₭₮₯₹"),
    Result4 = ?f("😊"),

    [
        ?assertEqual(<<"The sum of 1 and 1 is 2"/utf8>>, Result0),
        ?assertEqual(<<"#{b => b,a => a}"/utf8>>, Result1),
        ?assertEqual(<<"[1,2,3]"/utf8>>, Result2),
        ?assertEqual(<<"¥£€$¢₡₢₣₤₥₦₧₨₩₪₫₭₮₯₹"/utf8>>, Result3),
        ?assertEqual(<<"😊"/utf8>>, Result4)
    ].
