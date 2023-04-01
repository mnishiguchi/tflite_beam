%% @moduledoc
%% Runs end-to-end tokenization.
%%
%% Related link: https://github.com/tensorflow/examples/blob/master/lite/examples/bert_qa/ios/BertQACore/Models/Tokenizers/FullTokenizer.swift

-module(tflite_beam_full_tokenizer).
-export([
    tokenize/3,
    convert_to_id/2
]).

%% @doc
%% End-to-end tokenization.
-spec tokenize(binary() | list(), boolean(), map()) -> list(binary()).
tokenize(Text, IsCaseInsensitive, Vocab) when (is_binary(Text) or is_list(Text)) and is_boolean(IsCaseInsensitive) and is_map(Vocab) ->
    lists:flatten(
        lists:map(
            fun(E) ->
                tflite_beam_wordpiece_tokenizer:tokenize(E, Vocab)
            end,
            tflite_beam_basic_tokenizer:tokenize(Text, IsCaseInsensitive)
        )
    ).

%% @doc
%% Convert to ID in the vocab
-spec convert_to_id(list(binary()), map()) -> {ok, list(integer())} | {error, binary()}.
convert_to_id(Tokens, Vocab) ->
    MappedResults = 
        lists:map(
            fun(Token) ->
                case maps:is_key(Token, Vocab) of
                    true ->
                        maps:get(Token, Vocab);
                    false ->
                        Reason = io:format("Cannot found token `~ts` in the given vocabulary map", [Token]),
                        unicode:characters_to_binary(Reason)
                end
            end,
            Tokens
        ),
    FilteredResults = 
        lists:filter(
            fun(R) ->
                is_binary(R)
            end,
            MappedResults
        ),
    if 
        length(FilteredResults) > 0 ->
            {error, binary:join(";  \n", FilteredResults)};
        true ->
            {ok, MappedResults}
    end.
