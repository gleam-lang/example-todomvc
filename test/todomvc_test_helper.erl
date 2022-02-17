-module(todomvc_test_helper).

-export([ensure/2]).

ensure(Task, Cleanup) ->
    try
        Task()
    after
        Cleanup()
    end.
