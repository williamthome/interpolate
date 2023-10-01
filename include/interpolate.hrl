%%%-----------------------------------------------------------------------------
%%% @author William Fank Thomé [https://github.com/williamthome]
%%% @copyright 2023 William Fank Thomé
%%% @doc Interpolate macros.
%%% @end
%%%-----------------------------------------------------------------------------
-compile({parse_transform, interpolate}).

-define(f(String), interpolate:string(String)).
