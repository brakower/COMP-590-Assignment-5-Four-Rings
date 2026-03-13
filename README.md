# Four Rings

**Bennett Rakower, Tracy Dang, Megha Thumma*

## System Architecture

The system has three main components:

1. **Coordinator**
2. **Ring Managers**
3. **Ring Nodes**

The Coordinator:
- Reads integer inputs from the user
- Determines which ring the input should go to
- Sends the request to the correct ring
- Prints the final result when processing finishes

There are four independent rings:
- NEG
- ZERO
- POS_EVEN
- POS_ODD

Each ring contains N nodes connected in a directed cycle.  
A token moves from node to node for H hops, and each node applies a transformation to the value.
Each ring processes only one token at a time, but the four rings can run concurrently.

## Elixir Implementation

The Elixir version uses BEAM processes, which follow the actor model.

- Each ring node is implemented as a lightweight process
- Nodes communicate by sending messages
- Each process has its own mailbox for incoming messages

When a node receives a token message, it performs the computation and sends the token to the next node in the ring.
The BEAM virtual machine handles scheduling and allows the program to run many processes efficiently.


## Java Implementation

The Java version uses threads to implement concurrency.

- Each ring node is represented by a thread
- Nodes are connected logically to form a circular ring
- Tokens move from one node to the next during processing
- A RingManager controls when tokens enter the ring

To ensure that only one token is active in a ring at a time, each ring maintains a FIFO queue of tokens.  
When the current token finishes processing, the next token in the queue is injected into the ring.
Java relies on the thread scheduler and synchronization to manage concurrent execution.

## Concurrency Design

Both implementations follow the same concurrency rules:
- The system contains four independent rings
- Each ring processes one token at a time
- Additional tokens are stored in a FIFO queue
- The four rings can run simultaneously

This means the system can process up to four tokens concurrently, one in each ring.


