module Result.Utils exposing (unify)


unify : (x -> msg) -> (a -> msg) -> Result x a -> msg
unify onError onSuccess result =
    case result of
        Ok ok ->
            onSuccess ok

        Err err ->
            onError err
