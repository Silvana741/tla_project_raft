------------------------------ MODULE raftInit ------------------------------

EXTENDS raftHelpers

InitHistoryVars == voterLog  = [i \in Server |-> [j \in {} |-> <<>>]]
InitServerVars == /\ currentTerm = [i \in Server |-> 1]
                  /\ state       = [i \in Server |-> Follower]
                  /\ votedFor    = [i \in Server |-> Nil]
InitCandidateVars == /\ votesResponded = [i \in Server |-> {}]
                     /\ votesGranted   = [i \in Server |-> {}]
\* The values nextIndex[i][i] and matchIndex[i][i] are never read, since the
\* leader does not send itself messages. It's still easier to include these
\* in the functions.
InitLeaderVars == /\ nextIndex  = [i \in Server |-> [j \in Server |-> 1]]
                  /\ matchIndex = [i \in Server |-> [j \in Server |-> 0]]
InitLogVars == /\ log          = [i \in Server |-> << >>]
               /\ commitIndex  = [i \in Server |-> 0]
Init == /\ messages = [m \in {} |-> 0]
        /\ InitHistoryVars
        /\ InitServerVars
        /\ InitCandidateVars
        /\ InitLeaderVars
        /\ InitLogVars
        /\ maxc = 0
        /\ leaderCount = [i \in Server |-> 0]
        /\ entryCommitStats = [ idx_term \in {} |-> [ sentCount |-> 0, ackCount |-> 0, committed |-> FALSE ] ] \* Initialize new variable


yInit ==
    LET ServerIds == CHOOSE ids \in [1..Cardinality(Server) -> Server] :  \A idx1, idx2 \in DOMAIN ids : (idx1 /= idx2 => ids[idx1] /= ids[idx2])
            r1_as_switch == ServerIds[1]
            r2_as_peer1  == ServerIds[2]
            r3_as_leader == ServerIds[3]
            r4_as_peer2  == ServerIds[4]
        \* Define who the Raft peers are in this specific Init scenario
        RaftPeersInThisInit == Server \ {r1_as_switch}
    IN
    /\ maxc = 0
    /\ messages = [m \in {} |-> 0]
    /\ switchIndex = r1_as_switch \* Set the variable that stores the Switch's ID
    /\ switchBuffer = [rid \in {} |-> [value |-> Nil, requestID |-> Nil]]
    /\ entryCommitStats = [tuple_key \in {} |-> [sentCount |-> 0, ackCount |-> 0, committed |-> FALSE]] \* Empty map

    /\ currentTerm = [n \in Server |->
                        IF n = r1_as_switch THEN 0
                        ELSE 2]
    /\ state       = [n \in Server |->
                        IF n = r1_as_switch THEN Switch
                        ELSE IF n = r3_as_leader THEN Leader
                        ELSE Follower]

    /\ votedFor    = [n \in Server |->
                        IF n = r1_as_switch THEN Nil
                        ELSE IF n = r3_as_leader THEN Nil
                        ELSE r3_as_leader]
    /\ log          = [n \in Server |-> << >>] \* Switch has empty log too
    /\ commitIndex  = [n \in Server |-> 0]   \* Switch has commitIndex 0
    /\ leaderCount  = [n \in Server |->
                        IF n = r1_as_switch THEN 0
                        ELSE IF n = r3_as_leader THEN 1
                        ELSE 0]

    /\ nextIndex    = [s \in Server |-> [t \in Server |-> 1]]
    /\ matchIndex   = [s \in Server |-> [t \in Server |-> 0]]
    /\ votesGranted = [s \in Server |->
                      IF s = r3_as_leader THEN {r2_as_peer1, r4_as_peer2}  \* Leader has votes from r2 and r4
                      ELSE {}]
    /\ votesResponded = [s \in Server |->
                        IF s = r3_as_leader THEN {r2_as_peer1, r4_as_peer2}
                        ELSE {}]
    /\ voterLog = [s \in Server |-> IF s = r3_as_leader THEN (r2_as_peer1 :> <<>> @@ r4_as_peer2 :> <<>>) ELSE <<>>]
    /\ unorderedRequests = [s \in RaftPeersInThisInit |-> {}]
    /\ switchSentRecord  = [s \in RaftPeersInThisInit |-> {}]

=============================================================================
\* Created by Ovidiu-Cristian Marcu
