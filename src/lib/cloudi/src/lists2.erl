%%% -*- coding: utf-8; Mode: erlang; tab-width: 4; c-basic-offset: 4; indent-tabs-mode: nil -*-
%%% ex: set softtabstop=4 tabstop=4 shiftwidth=4 expandtab fileencoding=utf-8:
%%%
%%%------------------------------------------------------------------------
%%% @doc
%%% ==List operations==
%%% @end
%%%
%%% BSD LICENSE
%%% 
%%% Copyright (c) 2009-2011, Michael Truog <mjtruog at gmail dot com>
%%% All rights reserved.
%%% 
%%% Redistribution and use in source and binary forms, with or without
%%% modification, are permitted provided that the following conditions are met:
%%% 
%%%     * Redistributions of source code must retain the above copyright
%%%       notice, this list of conditions and the following disclaimer.
%%%     * Redistributions in binary form must reproduce the above copyright
%%%       notice, this list of conditions and the following disclaimer in
%%%       the documentation and/or other materials provided with the
%%%       distribution.
%%%     * All advertising materials mentioning features or use of this
%%%       software must display the following acknowledgment:
%%%         This product includes software developed by Michael Truog
%%%     * The name of the author may not be used to endorse or promote
%%%       products derived from this software without specific prior
%%%       written permission
%%% 
%%% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
%%% CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
%%% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
%%% OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%%% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
%%% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
%%% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
%%% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%%% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%%% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
%%% WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
%%% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%%% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
%%% DAMAGE.
%%%
%%% @author Michael Truog <mjtruog [at] gmail (dot) com>
%%% @copyright 2009-2011 Michael Truog
%%% @version 0.1.2 {@date} {@time}
%%%------------------------------------------------------------------------

-module(lists2).
-author('mjtruog [at] gmail (dot) com').

%% external interface
-export([iter/3,
         itera/3, itera2/4, itera3/5,
         delete_checked/2, delete_all/2,
         nth_take/2,
         keyptake/3, keypttake/4,
         sort/1, keysort/2,
         rsort/1, keyrsort/2,
         middle/1, middle/2]).

%%%------------------------------------------------------------------------
%%% External interface functions
%%%------------------------------------------------------------------------

%%-------------------------------------------------------------------------
%% @doc
%% ===Iterate on elements of a list.===
%% @end
%%-------------------------------------------------------------------------

-spec iter(F :: fun((any(), fun(() -> any())) -> any()),
           D :: any(),
           list()) -> any().

iter(_, D, []) ->
    D;
iter(F, D, [H]) ->
    F(H, fun() -> D end);
iter(F, D, [H | T]) ->
    F(H, fun() -> iter(F, D, T) end).

%%-------------------------------------------------------------------------
%% @doc
%% ===Iterate on elements of a list with an accumulator.===
%% @end
%%-------------------------------------------------------------------------

-spec itera(F :: fun((any(), any(), fun((any()) -> any())) -> any()),
            Acc :: any(),
            list()) -> any().

itera(_, Acc, []) ->
    Acc;
itera(F, Acc, [H]) ->
    F(H, Acc, fun(V) -> V end);
itera(F, Acc, [H | T]) ->
    F(H, Acc, fun(V) -> itera(F, V, T) end).

%%-------------------------------------------------------------------------
%% @doc
%% ===Iterate on elements of a list with two accumulators.===
%% @end
%%-------------------------------------------------------------------------

-spec itera2(F :: fun((any(), any(), any(),
                       fun((any(), any()) -> {any(), any()})) ->
                      {any(), any()}),
             Acc0 :: any(),
             Acc1 :: any(),
             list()) -> any().

itera2(_, Acc0, Acc1, []) ->
    {Acc0, Acc1};
itera2(F, Acc0, Acc1, [H]) ->
    F(H, Acc0, Acc1, fun(V0, V1) -> {V0, V1} end);
itera2(F, Acc0, Acc1, [H | T]) ->
    F(H, Acc0, Acc1, fun(V0, V1) -> itera2(F, V0, V1, T) end).

%%-------------------------------------------------------------------------
%% @doc
%% ===Iterate on elements of a list with three accumulators.===
%% @end
%%-------------------------------------------------------------------------

-spec itera3(F :: fun((any(), any(), any(), any(),
                       fun((any(), any(), any()) -> {any(), any(), any()})) ->
                      {any(), any(), any()}),
             Acc0 :: any(),
             Acc1 :: any(),
             Acc2 :: any(),
             list()) -> any().

itera3(_, Acc0, Acc1, Acc2, []) ->
    {Acc0, Acc1, Acc2};
itera3(F, Acc0, Acc1, Acc2, [H]) ->
    F(H, Acc0, Acc1, Acc2, fun(V0, V1, V2) -> {V0, V1, V2} end);
itera3(F, Acc0, Acc1, Acc2, [H | T]) ->
    F(H, Acc0, Acc1, Acc2, fun(V0, V1, V2) -> itera3(F, V0, V1, V2, T) end).

%%-------------------------------------------------------------------------
%% @doc
%% ===lists:delete/2 functionality, but returns false when an element is not deleted.===
%% @end
%%-------------------------------------------------------------------------

-spec delete_checked(Elem :: any(), List :: list()) ->
    list() |
    'false'.

delete_checked(Elem, List) when is_list(List) ->
    delete_checked(Elem, [], List).
delete_checked(Elem, L, [Elem | T]) ->
    lists:reverse(L) ++ T;
delete_checked(Elem, L, [H | T]) ->
    delete_checked(Elem, [H | L], T);
delete_checked(_, _, []) ->
    false.

%%-------------------------------------------------------------------------
%% @doc
%% ===lists:delete/2 functionality, but all instances are deleted.===
%% @end
%%-------------------------------------------------------------------------

-spec delete_all(Elem :: any(), List :: list()) ->
    list().

delete_all(Elem, List) when is_list(List) ->
    delete_all(Elem, [], List).
delete_all(Elem, L, [Elem | T]) ->
    delete_all(Elem, L, T);
delete_all(Elem, L, [H | T]) ->
    delete_all(Elem, [H | L], T);
delete_all(_, L, []) ->
    lists:reverse(L).

%%-------------------------------------------------------------------------
%% @doc
%% ===lists:nth/2 functionality, but removes the element.===
%% @end
%%-------------------------------------------------------------------------

-spec nth_take(I :: pos_integer(), L :: list()) ->
    {value, any(), list()} | false.

nth_take(I, L)
    when is_integer(I) ->
    nth_take(1, [], I, L).
nth_take(_, _, _, []) ->
    false;
nth_take(I, NewL, I, [H | T]) ->
    {value, H, lists:reverse(NewL) ++ T};
nth_take(Count, NewL, I, [H | T]) ->
    nth_take(Count + 1, [H | NewL], I, T).

%%-------------------------------------------------------------------------
%% @doc
%% ===lists:keytake/3 with the position index returned in the value tuple if the key is found.===
%% @end
%%-------------------------------------------------------------------------

-spec keyptake(any(), pos_integer(), list()) ->
    {'value', non_neg_integer(), tuple(), list()} |
    'false'.

keyptake(Key, N, L) when is_integer(N), N > 0 ->
    keyptake(Key, N, L, 0, []).

keyptake(Key, N, [H | T], I, L) when element(N, H) == Key ->
    {value, I, H, lists:reverse(L) ++ T};
keyptake(Key, N, [H | T], I, L) ->
    keyptake(Key, N, T, I + 1, [H | L]);
keyptake(_K, _N, [], _I, _L) ->
    false.

%%-------------------------------------------------------------------------
%% @doc
%% ===lists:keyptake/3 with a positional tuple match.===
%% @end
%%-------------------------------------------------------------------------

-spec keypttake(any(), pos_integer(), pos_integer(), list()) ->
    {'value', non_neg_integer(), tuple(), list()} |
    'false'.

keypttake(Key, N, Match, L) when is_integer(N), N > 0 ->
    keypttake(Key, N, Match, L, 0, []).

keypttake(Key, N, Match, [H | T], I, L) ->
    case tuple2:match(element(N, H), Key, Match) of
        true ->
            {value, I, H, lists:reverse(L) ++ T};
        false ->
            keypttake(Key, N, Match, T, I + 1, [H | L])
    end;
keypttake(_K, _N, _Match, [], _I, _L) ->
    false.

%%-------------------------------------------------------------------------
%% @doc
%% ===Sort a list in ascending order.===
%% @end
%%-------------------------------------------------------------------------

-spec sort(list()) -> list().

sort([]) ->
    [];
sort([_] = L) ->
    L;
sort([_|_] = L) ->
    quicksort(L).

%%-------------------------------------------------------------------------
%% @doc
%% ===Sort a list (in reverse) in descending order.===
%% @end
%%-------------------------------------------------------------------------

-spec rsort(list()) -> list().

rsort([]) ->
    [];
rsort([_] = L) ->
    L;
rsort([_|_] = L) ->
    rquicksort(L).

%%-------------------------------------------------------------------------
%% @doc
%% ===Sort a list of tuples based on an element (key) in the tuple in ascending order.===
%% @end
%%-------------------------------------------------------------------------

-spec keysort(pos_integer(), list()) -> list().

keysort(_, []) ->
    [];
keysort(_, [_] = L) ->
    L;
keysort(I, [_|_] = L) when is_integer(I), I > 0 ->
    key_quicksort(I, L).

%%-------------------------------------------------------------------------
%% @doc
%% ===Sort a list of tuples based on an element (key) in the tuple (in reverse) in descending order.===
%% @end
%%-------------------------------------------------------------------------

-spec keyrsort(pos_integer(), list()) -> list().

keyrsort(_, []) ->
    [];
keyrsort(_, [_] = L) ->
    L;
keyrsort(I, [_|_] = L) when is_integer(I), I > 0 ->
    key_rquicksort(I, L).

%%-------------------------------------------------------------------------
%% @doc
%% ===Find the middle element of a list.===
%% @end
%%-------------------------------------------------------------------------

middle([E]) ->
    E;
middle(L) when is_list(L) ->
    middle_element(L, 1, erlang:round(erlang:length(L) / 2)).
middle_element([H | _], Middle, Middle) ->
    H;
middle_element([_ | L], Index, Middle) ->
    middle_element(L, Index + 1, Middle).

%%-------------------------------------------------------------------------
%% @doc
%% ===Find the middle segment of a list.===
%% @end
%%-------------------------------------------------------------------------

middle(L, N) when is_list(L), is_integer(N) ->
    Length = erlang:length(L),
    if
        Length =< N ->
            L;
        true ->
            Middle = erlang:round((Length - N) / 2),
            middle_list([], L, 0, Middle, Middle + N)
    end.    
middle_list(M, _, Middle1, _, Middle1) ->
    lists:reverse(M);
middle_list(M, [H | L], Index, Middle0, Middle1)
    when Index >= Middle0, Index < Middle1 ->
    middle_list([H | M], L, Index + 1, Middle0, Middle1);
middle_list(M, [_ | L], Index, Middle0, Middle1) ->
    middle_list(M, L, Index + 1, Middle0, Middle1).

%%%------------------------------------------------------------------------
%%% Private functions
%%%------------------------------------------------------------------------

% quick sort implementation taken from
% http://en.literateprograms.org/Quicksort_(Erlang)
quicksort(List) ->
    quicksort_accumulator(List, []).
quicksort_accumulator([], Acc) ->
    Acc;
quicksort_accumulator([H | T], Acc) ->
    quicksort_accumulator_part(H, T, [], [H], [], Acc).
quicksort_accumulator_part(_, [], L, E, G, Acc) ->
    quicksort_accumulator(L, E ++ quicksort_accumulator(G, Acc));
quicksort_accumulator_part(E2, [H | _] = Rest, L, E, G, Acc) ->
    quicksort_accumulator_part_if(H, E2, Rest, L, E, G, Acc).
quicksort_accumulator_part_if(E1, E2, [H | T], L, E, G, Acc) ->
    if
        E1 < E2 ->
            quicksort_accumulator_part(E2, T, [H | L], E, G, Acc);
        E1 > E2 ->
            quicksort_accumulator_part(E2, T, L, E, [H | G], Acc);
        true ->
            quicksort_accumulator_part(E2, T, L, [H | E], G, Acc)
    end.

% quicksort modified to reverse the order
rquicksort(List) ->
    rquicksort_accumulator(List, []).
rquicksort_accumulator([], Acc) ->
    Acc;
rquicksort_accumulator([H | T], Acc) ->
    rquicksort_accumulator_part(H, T, [], [H], [], Acc).
rquicksort_accumulator_part(_, [], L, E, G, Acc) ->
    rquicksort_accumulator(L, E ++ rquicksort_accumulator(G, Acc));
rquicksort_accumulator_part(E2, [H | _] = Rest, L, E, G, Acc) ->
    rquicksort_accumulator_part_if(H, E2, Rest, L, E, G, Acc).
rquicksort_accumulator_part_if(E1, E2, [H | T], L, E, G, Acc) ->
    if
        E1 > E2 ->
            rquicksort_accumulator_part(E2, T, [H | L], E, G, Acc);
        E1 < E2 ->
            rquicksort_accumulator_part(E2, T, L, E, [H | G], Acc);
        true ->
            rquicksort_accumulator_part(E2, T, L, [H | E], G, Acc)
    end.

% quicksort modified for a list of tuples
key_quicksort(Index, List) ->
    key_quicksort_accumulator(List, [], Index).
key_quicksort_accumulator([], Acc, _) ->
    Acc;
key_quicksort_accumulator([H | T], Acc, I) ->
    key_quicksort_accumulator_part(element(I, H), T, [], [H], [], Acc, I).
key_quicksort_accumulator_part(_, [], L, E, G, Acc, I) ->
    key_quicksort_accumulator(
        L, E ++ key_quicksort_accumulator(G, Acc, I), I);
key_quicksort_accumulator_part(E2, [H | _] = Rest, L, E, G, Acc, I) ->
    key_quicksort_accumulator_part_if(
        element(I, H), E2, Rest, L, E, G, Acc, I).
key_quicksort_accumulator_part_if(E1, E2, [H | T], L, E, G, Acc, I) ->
    if
        E1 < E2 ->
            key_quicksort_accumulator_part(E2, T, [H | L], E, G, Acc, I);
        E1 > E2 ->
            key_quicksort_accumulator_part(E2, T, L, E, [H | G], Acc, I);
        true ->
            key_quicksort_accumulator_part(E2, T, L, [H | E], G, Acc, I)
    end.

% quicksort modified for a list of tuples in reverse order
key_rquicksort(Index, List) ->
    key_rquicksort_accumulator(List, [], Index).
key_rquicksort_accumulator([], Acc, _) ->
    Acc;
key_rquicksort_accumulator([H | T], Acc, I) ->
    key_rquicksort_accumulator_part(element(I, H), T, [], [H], [], Acc, I).
key_rquicksort_accumulator_part(_, [], L, E, G, Acc, I) ->
    key_rquicksort_accumulator(
        L, E ++ key_rquicksort_accumulator(G, Acc, I), I);
key_rquicksort_accumulator_part(E2, [H | _] = Rest, L, E, G, Acc, I) ->
    key_rquicksort_accumulator_part_if(
        element(I, H), E2, Rest, L, E, G, Acc, I).
key_rquicksort_accumulator_part_if(E1, E2, [H | T], L, E, G, Acc, I) ->
    if
        E1 > E2 ->
            key_rquicksort_accumulator_part(E2, T, [H | L], E, G, Acc, I);
        E1 < E2 ->
            key_rquicksort_accumulator_part(E2, T, L, E, [H | G], Acc, I);
        true ->
            key_rquicksort_accumulator_part(E2, T, L, [H | E], G, Acc, I)
    end.

