package fourrings;

import java.util.*;
import java.util.concurrent.ConcurrentLinkedQueue;

public class RingManager {

    private final String ringId;
    private final long hops;
    private final Coordinator coordinator;

    private final Queue<Token> queue = new ConcurrentLinkedQueue<>();

    private boolean busy = false;

    private RingNode firstNode;
    private List<RingNode> nodes = new ArrayList<>();

    public RingManager(String ringId, int n, long hops, Coordinator coordinator) {

        this.ringId = ringId;
        this.hops = hops;
        this.coordinator = coordinator;

        createRing(n);
    }

    private void createRing(int n) {

        for (int i = 0; i < n; i++) {

            RingNode node = new RingNode(ringId, this);
            nodes.add(node);
        }

        for (int i = 0; i < n; i++) {

            RingNode current = nodes.get(i);
            RingNode next = nodes.get((i + 1) % n);

            current.setNext(next);
        }

        firstNode = nodes.get(0);

        for (RingNode node : nodes) {
            node.start();
        }
    }

    public synchronized void submit(long tokenId, long input) {

        Token token = new Token(tokenId, ringId, input, hops);

        if (!busy) {

            busy = true;

            try {
                firstNode.send(token);
            } catch (Exception e) {}

        } else {

            queue.add(token);
        }
    }

    public synchronized void tokenFinished(Token token) {

        coordinator.reportCompletion(token);

        if (!queue.isEmpty()) {

            Token next = queue.poll();

            try {
                firstNode.send(next);
            } catch (Exception e) {}

        } else {

            busy = false;
        }
    }
}