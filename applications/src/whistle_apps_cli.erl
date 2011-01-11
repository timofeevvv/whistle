%%%-------------------------------------------------------------------
%%% @author James Aimonetti <james@2600hz.org>
%%% @copyright (C) 2010, James Aimonetti
%%% @doc
%%% CLI interface to Whistle Apps (whapps) Container
%%% @end
%%% Created : 10 Jan 2011 by James Aimonetti <james@2600hz.org>
%%%-------------------------------------------------------------------
-module(whistle_apps_cli).

-export([help/2, set_amqp_host/2, set_couch_host/2, start_app/2, stop_app/2]).

-include_lib("../../lib/erlctl/lib/erlctl-0.3/include/erlctl.hrl").

help(always,_) ->
  lists:foreach(
    fun({E,D}) ->
	    format(E ++ "~n", D);
       (E) ->
	    format(E ++ "~n", [])
    end, usage()),
  ok.

usage() ->
    Opts = erlctl:get_opts(),
    App = proplists:get_value(app,Opts),
    Script = proplists:get_value(script,Opts),
    [
     {"Usage for ~s:",[App]}
     ,{" ~s <command> ...",[Script]}
     ,""
     ,"Commands:"
     ,{" set_amqp_host <host>  Set the amqp host (e.g. ~p)", [net_adm:localhost()]}
     ,{" set_couch_host <host>  Set the amqp host (e.g. ~p)", [net_adm:localhost()]}
     ," start_app <whapp>  Start (if not already) the whapp"
     ," stop_app <whapp>  Stop (if started) the whapp"
     ," running_apps  List of whapps currently running"
    ].

set_amqp_host(always, [Host]=Arg) ->
    Node = list_to_atom(lists:flatten(["whistle_apps@", net_adm:localhost()])),
    format("Setting AMQP host to ~p on ~p~n", [Host, Node]),
    case rpc_call(Node, whistle_controller, set_amqp_host, Arg) of
	{ok, ok} ->
	    {ok, "Set whistle controller's amqp host to ~p", [Host]};
	{ok, Other} ->
	    {ok, "Something unexpected happened while setting the amqp host: ~p", [Other]}
    end.

set_couch_host(always, [Host]=Arg) ->
    Node = list_to_atom(lists:flatten(["whistle_apps@", net_adm:localhost()])),
    format("Setting CouchDB Host to ~p on ~p~n", [Host, Node]),
    case rpc_call(Node, whistle_controller, set_couch_host, Arg) of
	{ok, ok} ->
	    {ok, "Set whistle controller's couch host to ~p", [Host]};
	{ok, Other} ->
	    {ok, "Something unexpected happened while setting the couch host: ~p", [Other]}
    end.

start_app(always, [Whapp]=Arg) ->
    Node = list_to_atom(lists:flatten(["whistle_apps@", net_adm:localhost()])),
    format("Starting whapp ~p on ~p~n", [Whapp, Node]),
    case rpc_call(Node, whistle_controller, start_app, Arg) of
	{ok, ok} ->
	    {ok, "~p started successfully", [Whapp]};
	{ok, Other} ->
	    {ok, "Something unexpected happened while starting ~p: ~p", [Whapp, Other]}
    end.

stop_app(always, [Whapp]=Arg) ->
    Node = list_to_atom(lists:flatten(["whistle_apps@", net_adm:localhost()])),
    format("Stopping whapp ~p on ~p~n", [Whapp, Node]),
    case rpc_call(Node, whistle_controller, start_app, Arg) of
	{ok, ok} ->
	    {ok, "~p stopped successfully", [Whapp]};
	{ok, Other} ->
	    {ok, "Something unexpected happened while stopping ~p: ~p", [Whapp, Other]}
    end.

rpc_call(Node, M, F, A) ->
    case net_adm:ping(Node) of
	pong ->
	    {ok, rpc:call(Node, M, F, A)};
	pang ->
	    {ok, "~p not reachable", [Node]}
    end.