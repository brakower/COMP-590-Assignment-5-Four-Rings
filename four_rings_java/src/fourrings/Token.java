package fourrings;

public class Token {

    public long tokenId;
    public String ringId;
    public long origInput;
    public long currentVal;
    public long remainingHops;
    public long startTime;

    public Token(long tokenId, String ringId, long input, long hops) {
        this.tokenId = tokenId;
        this.ringId = ringId;
        this.origInput = input;
        this.currentVal = input;
        this.remainingHops = hops;
        this.startTime = System.nanoTime();
    }
}