
customer(appleton).
customer(gross).
customer(knight).
customer(mcevoy).
customer(parnell).

subject(english).
subject(gym).
subject(history).
subject(math).
subject(science).

state(california).
state(florida).
state(maine).
state(oregon).
state(virginia).

activity(antiquing).
activity(camping).
activity(sightseeing).
activity(spelunking).
activity(sking).
/**
 *
 *  
 *
 */
solve :-
    subject(AppletonSubject), subject(GrossSubject), subject(KnightSubject), subject(McevoySubject), subject(ParnellSubject),
    all_different([AppletonSubject, GrossSubject, KnightSubject, McevoySubject, ParnellSubject]),

    state(AppletonState), state(GrossState), state(KnightState), state(McevoyState), state(ParnellState),
    all_different([AppletonState, GrossState, KnightState, McevoyState, ParnellState]),

    activity(AppletonActivity), activity(GrossActivity), activity(KnightActivity), activity(McevoyActivity), activity(ParnellActivity),
    all_different([AppletonActivity, GrossActivity, KnightActivity, McevoyActivity, ParnellActivity]),

    Peeps = [
        [appleton, AppletonActivity, AppletonState, AppletonSubject],
        [gross, GrossActivity, GrossState, GrossSubject],
        [knight, KnightActivity, KnightState, KnightSubject],
        [mcevoy, McevoyActivity, McevoyState, McevoySubject],
        [parnell, ParnellActivity, ParnellState, ParnellSubject]
    ],
    %
    ( member([gross, _, _, math], Peeps) ; member([gross, _, _, science], Peeps) ),
    ( member([gross, antiquing, _, _], Peeps) -> member([gross, antiquing, florida, _], Peeps) ; member([gross, _, california, _], Peeps) ),
    %
    ( member([_, sking, california, science], Peeps) ; member([_, sking, florida, science], Peeps) ),
    member([mcevoy, _, _, history], Peeps),
    ( member([mcevoy, _, maine, _], Peeps) ; member([mcevoy, _, oregon, _], Peeps) ),
    %
    member([parnell, spelunking, _, _], Peeps),
    ( member([_, _, virginia, english], Peeps) -> member([appleton, _, virginia, english], Peeps ) ; member([parnell, spelunking, virginia, _], Peeps)),

    \+ member([mcevoy, _, virginia, _], Peeps),
    \+ member([knight, _, virginia, _], Peeps),

    %
    \+ member([_, _, maine, gym], Peeps),
    \+ member([_, sightseeing, maine, _], Peeps),

    %
    \+ member([mcevoy, camping, _, _], Peeps),
    \+ member([knight, camping, _, _], Peeps),
    \+ member([gross, camping, _, _], Peeps),
    ( member([gross, antiquing, _, _], Peeps) ; member([appleton, antiquing, _, _], Peeps) ; member([parnell, antiquing, _, _], Peeps) ),

    answer(appleton, AppletonActivity, AppletonState, AppletonSubject),
    answer(gross, GrossActivity, GrossState, GrossSubject),
    answer(knight, KnightActivity, KnightState, KnightSubject),
    answer(mcevoy, McevoyActivity, McevoyState, McevoySubject),
    answer(parnell, ParnellActivity, ParnellState, ParnellSubject).

% Succeeds if all elements of the argument list are bound and different.
% Fails if any elements are unbound or equal to some other element.


answer(W, X, Y, Z) :-
    write(W), write(' teaches '), write(Z), write(' and visited '), write(Y),write(' where they '), write(X), write('.'), nl.


all_different([H | T]) :- member(H, T), !, fail.
all_different([_ | T]) :- all_different(T).
all_different([_]).

:- initialization(main).
main :- solve(), halt.