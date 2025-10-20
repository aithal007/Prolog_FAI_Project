% ============================================================================
% Prolog Knowledge Base for Hybrid NL-to-Logic Translator
% ============================================================================

% Top-level sentence rule
sentence(Logic) -->
    noun_phrase(X, VP_Logic, Logic),
    verb_phrase(X, VP_Logic).

% Noun phrase: determiner + noun
noun_phrase(X, Restriction, Logic) -->
    det(Det, X, NounLogic, Restriction, Logic),
    noun(Noun, X, NounLogic).

% Verb phrase: verb + object noun phrase
verb_phrase(Subject, VP_Logic) -->
    verb(Verb, Subject, Object, VerbLogic),
    noun_phrase(Object, VerbLogic, VP_Logic).

% Determiners (quantifiers)
det(every, X, P1, P2, forall(X, (P1 => P2))) --> [every].
det(all, X, P1, P2, forall(X, (P1 => P2))) --> [all].
det(each, X, P1, P2, forall(X, (P1 => P2))) --> [each].
det(any, X, P1, P2, forall(X, (P1 => P2))) --> [any].

det(a, X, P1, P2, exists(X, (P1, P2))) --> [a].
det(an, X, P1, P2, exists(X, (P1, P2))) --> [an].
det(some, X, P1, P2, exists(X, (P1, P2))) --> [some].
det(one, X, P1, P2, exists(X, (P1, P2))) --> [one].

:- dynamic noun/3.
:- dynamic verb/4.

% Core nouns
noun(student, X, student(X)) --> [student].
noun(teacher, X, teacher(X)) --> [teacher].
noun(person, X, person(X)) --> [person].
noun(human, X, human(X)) --> [human].
noun(child, X, child(X)) --> [child].
noun(programmer, X, programmer(X)) --> [programmer].
noun(scientist, X, scientist(X)) --> [scientist].
noun(doctor, X, doctor(X)) --> [doctor].
noun(engineer, X, engineer(X)) --> [engineer].

% Animals
noun(cat, X, cat(X)) --> [cat].
noun(dog, X, dog(X)) --> [dog].
noun(bird, X, bird(X)) --> [bird].
noun(fish, X, fish(X)) --> [fish].

% Objects
noun(book, X, book(X)) --> [book].
noun(mat, X, mat(X)) --> [mat].
noun(car, X, car(X)) --> [car].
noun(house, X, house(X)) --> [house].
noun(phone, X, phone(X)) --> [phone].
noun(code, X, code(X)) --> [code].
noun(game, X, game(X)) --> [game].

% Verbs
verb(read, Subject, Object, read(Subject, Object)) --> [read].
verb(reads, Subject, Object, read(Subject, Object)) --> [reads].
verb(write, Subject, Object, write(Subject, Object)) --> [write].
verb(writes, Subject, Object, write(Subject, Object)) --> [writes].
verb(own, Subject, Object, own(Subject, Object)) --> [own].
verb(owns, Subject, Object, own(Subject, Object)) --> [owns].
verb(have, Subject, Object, have(Subject, Object)) --> [have].
verb(has, Subject, Object, have(Subject, Object)) --> [has].

verb(like, Subject, Object, like(Subject, Object)) --> [like].
verb(likes, Subject, Object, like(Subject, Object)) --> [likes].
verb(love, Subject, Object, love(Subject, Object)) --> [love].
verb(loves, Subject, Object, love(Subject, Object)) --> [loves].

verb(teach, Subject, Object, teach(Subject, Object)) --> [teach].
verb(teaches, Subject, Object, teach(Subject, Object)) --> [teaches].

verb(build, Subject, Object, build(Subject, Object)) --> [build].
verb(builds, Subject, Object, build(Subject, Object)) --> [builds].

verb(play, Subject, Object, play(Subject, Object)) --> [play].
verb(plays, Subject, Object, play(Subject, Object)) --> [plays].

% Helpers
add_noun(Word) :-
    atom(Word),
    \+ noun(Word, _, _),
    assertz((noun(Word, X, Pred) --> [Word])),
    assertz((noun(Word, X, Pred) :- Pred =.. [Word, X], true)).

add_verb(Word) :-
    atom(Word),
    \+ verb(Word, _, _, _),
    assertz((verb(Word, S, O, Pred) --> [Word])),
    assertz((verb(Word, S, O, Pred) :- Pred =.. [Word, S, O], true)).

can_parse(S) :- phrase(sentence(_), S).

show_logic(S) :- phrase(sentence(Logic), S), write(Logic), nl.
