%
% Copyright (c) 2016-2017 Petr Gotthard <petr.gotthard@centrum.cz>
% All rights reserved.
% Distributed under the terms of the MIT License. See the LICENSE file.
%
-module(lorawan_admin_servers).

-export([init/2]).
-export([is_authorized/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([resource_exists/2]).

-export([get_stats/2]).

init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

is_authorized(Req, State) ->
    lorawan_admin:handle_authorization(Req, State).

allowed_methods(Req, State) ->
    {[<<"OPTIONS">>, <<"GET">>], Req, State}.

content_types_provided(Req, State) ->
    {[
        {{<<"application">>, <<"json">>, []}, get_stats}
    ], Req, State}.

get_stats(Req, State) ->
    {jsx:encode([[{node, node()},
        {modules, get_modules()},
        {memory, memsup:get_system_memory_data()},
        {disk, get_disk_data()}]]), Req, State}.

get_modules() ->
    lists:map(
        fun({App, _Desc, Vsn}) ->
            {App, list_to_binary(Vsn)}
        end,
        application:which_applications()).

get_disk_data() ->
    lists:map(
        fun({Id, KByte, Capacity}) ->
            [{id, list_to_binary(Id)}, {size_kb, KByte}, {percent_used, Capacity}]
        end,
        disksup:get_disk_data()).

resource_exists(Req, State) ->
    {true, Req, State}.

% end of file
