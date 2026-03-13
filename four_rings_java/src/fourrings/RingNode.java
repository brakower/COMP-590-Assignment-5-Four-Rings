package fourrings;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

public class RingNode extends Thread {

    private final String ringId;
    private final RingManager manager;

    private RingNode next;

    private final BlockingQueue<Token> mailbox = new LinkedBlockingQueue<>();

    public RingNode(String ringId, RingManager manager) {
        this.ringId = ringId;
        this.manager = manager;
    }

    public void setNext(RingNode next) {
        this.next = next;
    }

    public void send(Token token) throws InterruptedException {
        mailbox.put(token);
    }

    private long transform(long v) {

        switch (ringId) {

            case "NEG":
                return Math64.negTransform(v);

            case "ZERO":
                return Math64.zeroTransform(v);

            case "POS_EVEN":
                return Math64.posEvenTransform(v);

            default:
                return Math64.posOddTransform(v);
        }
    }

    public void run() {

        try {

            while (true) {

                Token token = mailbox.take();

                token.currentVal = transform(token.currentVal);

                token.remainingHops--;

                if (token.remainingHops > 0) {

                    next.send(token);

                } else {

                    manager.tokenFinished(token);
                }
            }

        } catch (InterruptedException e) {
            // shutdown
        }
    }
}