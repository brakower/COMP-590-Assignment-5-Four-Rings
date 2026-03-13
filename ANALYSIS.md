# Four Rings – Analysis

**Bennett Rakower, Tracy Dang, Megha Thumma**

## Machine Used
All experiments were run on the following machine:
- Computer: MacBook Air  
- Chip: M2
- Cores: 8 CPU cores  
- RAM: 8 GB  
- Operating System: macOS Sonoma
Both the Java version and the Elixir version were run on the same machine so that the results would be comparable.

## What We Chose to Measure

For this project we focused on three main things:

1. Token latency – how long it takes for a token to finish processing after it is entered.
2. Scalability with larger rings – how the system behaves when the number of nodes (N) increases.
3. Effect of hop count – how increasing the number of hops (H) changes the runtime.


## Why We Chose These Metrics

These metrics were chosen because they directly relate to how the system is designed.
- Latency shows how quickly each token can move through the ring.
- Scalability with N shows how well the system handles creating and managing many nodes.
- Hop count (H) increases the amount of computation, which helps show how the system behaves when the CPU is doing more work.

## Trials Performed

Several test configurations were used with different values of N (ring size) and H (number of hops).

Trial 1  
N = 5  
H = 10  
Purpose: Small test to verify the program works correctly and that tokens move through the ring as we thought they would.

Trial 2  
N = 100  
H = 1000  
Purpose: A bigger sized workload to observe system behavior with a larger number of nodes and more hops.

Trial 3  
N = 5000  
H = 10000  
Purpose: A even larger test to increase both the number of nodes and the amount of computation done by each token.

Trial 4  
N = 20000  
H = 10000  
Purpose: To see how well the system scales with a very large ring size.


## Patterns Observed

We observed several different patteners as we tested:

### Effect of Increasing N
When the ring size (N) increased, the startup time increased because more nodes needed to be created. This effect was more noticeable in the Java version because each node is represented by a thread.
In the Elixir version, increasing N did not slow things down as much because BEAM processes are lightweight.

### Effect of Increasing H
Increasing H increased the amount of work each token had to do. This caused tokens to take longer to finish, but the system itself remained stable. Higher H values kept the CPU busy performing calculations instead of switching between threads or processes.

### Concurrent Rings
Because the system has four independent rings, tokens in different rings were processed at the same time. This could be seen in the output where completion messages from different rings appeared in mixed order.


## Java Threads vs BEAM Processes

The biggest difference between the two implementations was how they handle concurrency.

### Java
Java uses threads, which are heavier and managed by the operating system. Creating a very large number of threads can add overhead and use more memory.

For smaller ring sizes, Java performed well and processed tokens quickly. However, when the ring size became very large, thread management started to add more overhead.

### Elixir
Elixir runs on the BEAM virtual machine, which uses lightweight processes. These processes are much cheaper to create and manage compared to threads.

Because of this, the Elixir version handled large ring sizes more smoothly and scaled better when the number of nodes increased.

## What Surprised Us

One thing that surprised us was how efficiently Elixir handled large numbers of processes. Even when the ring size became very large, the program still ran smoothly. Another interesting observation was that both versions behaved very similarly for smaller workloads. The differences between Java and Elixir were noticeable when the system size increased.
