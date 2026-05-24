-module(gakudan_tickets_SUITE).
-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").

-export([all/0]).
-export([
    fetch_dispatches/1,
    search_dispatches/1,
    post_comment_dispatches/1,
    apply_labels_dispatches/1,
    transition_dispatches/1,
    fetch_error_passes_through/1
]).

%% A mock adapter that implements the behaviour by recording every call into
%% the process dictionary and returning canned data.
-export([fetch/2, search/2, post_comment/3, apply_labels/3, transition/3]).

all() ->
    [
        fetch_dispatches,
        search_dispatches,
        post_comment_dispatches,
        apply_labels_dispatches,
        transition_dispatches,
        fetch_error_passes_through
    ].

fetch_dispatches(_Config) ->
    put(fetch_arg, none),
    {ok, Ticket} = gakudan_tickets:fetch(?MODULE, my_ref, ~"42"),
    ?assertEqual({my_ref, ~"42"}, get(fetch_arg)),
    ?assertEqual(~"42", maps:get(id, Ticket)),
    ?assertEqual(mock, maps:get(source, Ticket)).

search_dispatches(_Config) ->
    put(search_arg, none),
    {ok, Tickets} = gakudan_tickets:search(?MODULE, my_ref, ~"is:open"),
    ?assertEqual({my_ref, ~"is:open"}, get(search_arg)),
    ?assert(is_list(Tickets)).

post_comment_dispatches(_Config) ->
    put(comment_arg, none),
    ok = gakudan_tickets:post_comment(?MODULE, my_ref, ~"42", ~"thanks for reporting"),
    ?assertEqual({my_ref, ~"42", ~"thanks for reporting"}, get(comment_arg)).

apply_labels_dispatches(_Config) ->
    put(labels_arg, none),
    ok = gakudan_tickets:apply_labels(?MODULE, my_ref, ~"42", [~"bug", ~"triaged"]),
    ?assertEqual({my_ref, ~"42", [~"bug", ~"triaged"]}, get(labels_arg)).

transition_dispatches(_Config) ->
    put(transition_arg, none),
    ok = gakudan_tickets:transition(?MODULE, my_ref, ~"42", closed),
    ?assertEqual({my_ref, ~"42", closed}, get(transition_arg)).

fetch_error_passes_through(_Config) ->
    {error, not_found} = gakudan_tickets:fetch(?MODULE, my_ref, ~"missing").

%% --- mock adapter callbacks ---

fetch(_Ref, ~"missing") ->
    {error, not_found};
fetch(Ref, Id) ->
    put(fetch_arg, {Ref, Id}),
    {ok, #{
        id => Id,
        title => ~"mock title",
        body => ~"mock body",
        author => ~"mockuser",
        labels => [],
        created_at => 0,
        source => mock,
        raw => #{}
    }}.

search(Ref, Query) ->
    put(search_arg, {Ref, Query}),
    {ok, []}.

post_comment(Ref, Id, Body) ->
    put(comment_arg, {Ref, Id, Body}),
    ok.

apply_labels(Ref, Id, Labels) ->
    put(labels_arg, {Ref, Id, Labels}),
    ok.

transition(Ref, Id, State) ->
    put(transition_arg, {Ref, Id, State}),
    ok.
