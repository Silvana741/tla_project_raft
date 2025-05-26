**23 April 2025** 

The highlights from the papers:

**DCRuntime: Toward Efficiently Sharing CPU-GPU Architectures**
Processing engines typically deploy pipelines of
operators, including source, sink, and shuffle operators.
Source operators -  get/fetch data with a pull-based approach
Sink operators - write data to storage using a pull-based approach 
Shuffle operators - redistribute data based on partitioning, implemented at application level


**Raft initial algorithm explanation**
The set Quorum is defined as the collection of all subsets of servers (i) where the number of servers in that subset (i) is strictly greater than half the total number of servers in the entire system (Server).

**22 May 2025**

**HovercRaft: Achieving Scalability and Fault-tolerance for microsecond-scale Datacenter Services**

SMR -  State Machine Replication 
    - used for fault tolerance and scalability 
    -  helps in managing complex systems efficiently 
    - the goal is to use less roundtrips for communication in multi-node systems and have good results and synchronization

RPC - Remote Procedure Call 
    -  software communication protocol that one program uses to request a service from another program located on another computer/network, without having to understand the network's details

R2P2 protocol 
    - a transport protocol specifically designed for in-network policy enforcement over remote procedure calls (RPC) inside a datacenter 
    - provides a way to uniquely identify an RPC based on a 3-tuple (req_id, src_port, src_ip)


Consensus algorithms (i.e. Paxos, Raft etc.) 
    - 2 phases - leader election and normal operation 
    - all replicas need to behave as a single machine 
    -  Raft has a strong leader, uses a replicated log between the followers and provides an in-order commit mechanism 
    - main bottlenecks:
        - IO bottleneck - the leader has to send everything to the followers and it is not scalable (request replication) 
        -  CPU bottleneck

HovercRaft:
    - introduces IP multicast to solve IO bottleneck - instead of targeting a specific server, clients inside the datacenter send their requests to a multicast group that includes the leader and the followers 
    - IP multicast does not guarantee ordering or delivery, that's why ordering needs to be handled by the leader 
    - bounded queues used to deal with node failures 
    - steps:
        (1) the leader inserts entries at log_idx, the head of the log without determining yet which node will send the reply;
        (2) the leader selects the node in charge of replying to the client and updates the announced_idx accordingly; 
        (3) the commit_idx represents the point upon which consensus has been reached; 
        (4) the applied_idx represents the point upon which operations have been applied to the state machine. Each follower also has its own set of applied_idx, commit_idx, and log_idx indices on its local log. Announced_idx is relevant only for the leader. Followers communicate their applied_idx to the leader as part of the append_entries reply.
    
