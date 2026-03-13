package fourrings;

public class Coordinator {

    private RingManager neg;
    private RingManager zero;
    private RingManager posEven;
    private RingManager posOdd;

    private long nextTokenId = 1;

    public Coordinator(int n, long h) {

        neg = new RingManager("NEG", n, h, this);
        zero = new RingManager("ZERO", n, h, this);
        posEven = new RingManager("POS_EVEN", n, h, this);
        posOdd = new RingManager("POS_ODD", n, h, this);
    }

    public void submit(long value) {

        long id = nextTokenId++;

        if (value < 0) {

            neg.submit(id, value);

        } else if (value == 0) {

            zero.submit(id, value);

        } else if (value % 2 == 0) {

            posEven.submit(id, value);

        } else {

            posOdd.submit(id, value);
        }
    }

    public void reportCompletion(Token token) {

        long latency =
                (System.nanoTime() - token.startTime) / 1_000_000;

        System.out.println(
                "[DONE] token=" + token.tokenId +
                " ring=" + token.ringId +
                " input=" + token.origInput +
                " final=" + token.currentVal +
                " latencyMs=" + latency
        );
    }
}