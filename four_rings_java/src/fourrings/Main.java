package fourrings;

import java.util.Scanner;

public class Main {

    public static void main(String[] args) {

        if (args.length != 2) {

            System.out.println("Usage: java Main N H");
            return;
        }

        int N = Integer.parseInt(args[0]);
        long H = Long.parseLong(args[1]);

        Coordinator coordinator = new Coordinator(N, H);

        Scanner scanner = new Scanner(System.in);

        while (true) {

            System.out.print("Enter integer or 'done': ");

            String line = scanner.nextLine();

            if (line.equalsIgnoreCase("done")) {
                System.out.println("Finishing...");
                break;
            }

            try {

                long value = Long.parseLong(line);

                coordinator.submit(value);

            } catch (Exception e) {

                System.out.println("Invalid input.");
            }
        }
    }
}