package fourrings;

public class Math64 {

    public static long negTransform(long v) {
        return v * 3 + 1;
    }

    public static long zeroTransform(long v) {
        return v + 7;
    }

    public static long posEvenTransform(long v) {
        return v * 101;
    }

    public static long posOddTransform(long v) {
        return v * 101 + 1;
    }
}