# interpolate

An Erlang library to interpolate strings.

## Usage

Use the `interpolate:string/1` function or add the header `-include_lib("interpolate/include/interpolate.hrl").` to your module and the `?f` macro will be available to format your string.

## Example

In an Erlang module:

```erlang
module(math).

-export([sum/2]).

-include_lib("interpolate/include/interpolate.hrl").

sum(X, Y) ->
    ?f("The sum of ~p[X] and ~p[Y] is ~p[X+Y]").
```

The result of the function will be a UTF-8 binary:

```erlang
1> math:sum(1,2).
<<"The sum of 1 and 2 is 3">>
```

## How it works

This lib uses a `parse_transform` to expand the string to the `io_lib:format/2` function. The string should be written thinking in the `io_lib:format/2` syntax, but the arguments of the [control sequences](https://www.erlang.org/doc/man/io#format-2) must be written next to them inside closed brackets, as a list. All control sequences are auto-prefixed with the modifier `t` (Unicode translator) For example:

```
Foo = "😊",
<<"😊"/utf8>> = ?f("~s[Foo]").
```

The `?f("~s[Foo]")` is compiled to `interpolate:string("~s[Foo]")` and expanded to
```erlang
iolist_to_binary(io_lib:format(<<"~ts"/utf8>>, [Foo])).
```

See more examples in the `interpolate_test.erl` under the `test` folder.
