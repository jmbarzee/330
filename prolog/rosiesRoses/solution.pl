
customer(hugh).
customer(stella).
customer(ida).
customer(leroy).
customer(jeremy).

event(anniversary).
event(auction).
event(retirement).
event(prom).
event(wedding).

addOn(balloons).
addOn(candles).
addOn(chocolates).
addOn(placecards).
addOn(streamers).

rose(cottagebeauty).
rose(goldensunset).
rose(mountainbloom).
rose(pinkparadise).
rose(sweetdreams).
/**
 *
 *  ROSIE'S ROSES
 *  Rosie owns a small flower shop in town where she sells her prize-winning
 *  homegrown roses. She helped five customers this morning, each of whom chose
 *  a different variety of rose (including Golden Sunset) for a different event.
 *  While there, each person (including Ida) also selected a different
 *  additional item for the gathering (one person bought place cards). With all
 *  of this business, the future of Rosie's flower shop looks rosy! From the
 *  information provided, determine the type of rose each customer chose, his
 *  or her event, and the additional item he or she ordered.
 *
 */
solve :-
    event(HughEvent), event(StellaEvent), event(IdaEvent), event(LeroyEvent), event(JeremyEvent),
    all_different([HughEvent, StellaEvent, IdaEvent, LeroyEvent, JeremyEvent]),

    addOn(HughAddOn), addOn(StellaAddOn), addOn(IdaAddOn), addOn(LeroyAddOn), addOn(JeremyAddOn),
    all_different([HughAddOn, StellaAddOn, IdaAddOn, LeroyAddOn, JeremyAddOn]),

    rose(HughRose), rose(StellaRose), rose(IdaRose), rose(LeroyRose), rose(JeremyRose),
    all_different([HughRose, StellaRose, IdaRose, LeroyRose, JeremyRose]),

    Peeps = [
        [hugh, HughRose, HughAddOn, HughEvent],
        [stella, StellaRose, StellaAddOn, StellaEvent],
        [ida, IdaRose, IdaAddOn, IdaEvent],
        [leroy, LeroyRose, LeroyAddOn, LeroyEvent],
        [jeremy, JeremyRose, JeremyAddOn, JeremyEvent]
    ],
    % 1. Jeremy made a purchase for the senior prom. Stella (who didn't choose
    % flowers for a wedding) picked the Cottage Beauty variety.
    member([jeremy, _, _, prom], Peeps),
    \+ member([stella, _, _, wedding], Peeps),
    member([stella, cottagebeauty, _, _], Peeps),
    % 2. Hugh (who selected the Pink Paradise blooms) didn't choose flowers for
    % either the charity auction or the wedding.
    member([hugh, pinkparadise, _, _], Peeps),
    \+ member([hugh, _, _, auction], Peeps),
    \+ member([hugh, _, _, wedding], Peeps),
    % 3. The customwer who picked roses for an anniversary party also bought
    % streamers. The one shopping for a wedding chose the balloons.
    member([_, _, streamers, anniversary], Peeps),
    member([_, _, balloons, wedding], Peeps),
    % 4. The customer who bought the Sweet Dreams variety also bough gourmet
    % chocolates. Jeremy didn't pick the Mountain Bloom variety.
    member([_, sweetdreams, chocolates, _], Peeps),
    \+ member([jeremy, mountainbloom, _, _], Peeps),
    % 5. Leroy was shopping for the retirement banquet. The customer in charge
    % of decorating the senior prom also bought the candles.
    member([leroy, _, _, retirement], Peeps),
    member([_, _, candles, prom], Peeps),

    answer(hugh, HughRose, HughAddOn, HughEvent),
    answer(stella, StellaRose, StellaAddOn, StellaEvent),
    answer(ida, IdaRose, IdaAddOn, IdaEvent),
    answer(leroy, LeroyRose, LeroyAddOn, LeroyEvent),
    answer(jeremy, JeremyRose, JeremyAddOn, JeremyEvent).

% Succeeds if all elements of the argument list are bound and different.
% Fails if any elements are unbound or equal to some other element.


answer(W, X, Y, Z) :-
    write(W), write(' bought '), write(X), write(' for '), write(Z), write('.'), 
    write(' They also bought '), write(Y), write('.'), nl.


all_different([H | T]) :- member(H, T), !, fail.
all_different([_ | T]) :- all_different(T).
all_different([_]).

:- initialization(main).
main :- solve(), halt.