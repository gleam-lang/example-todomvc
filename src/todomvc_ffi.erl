-module(todomvc_ffi).

-export([configure_logger_backend/0]).

configure_logger_backend() ->
    ok = logger:set_primary_config(level, info),
    ok = logger:set_handler_config(default, formatter, {logger_formatter, #{
        template => [level, ": ", msg, "\n"]
    }}),
    ok = logger:set_application_level(stdlib, notice),
    nil.
