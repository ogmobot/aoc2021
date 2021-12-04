import java.io.*;
import java.util.Scanner;

public class BingoBoard {
    int vals[25];
    public BingoBoard(String lines[]) {
        int index = 0;
        for (String line : lines) {
            String[] valuesAsStrings = line.split(",", -1);
            for (String value : valuesAsStrings) {
                vals[index] = Integer.parseInt(value.trim());
                index ++;
            }
        }
    }
}

public class day04 {
    public static void main(String args[]) {
        int product = 1;
        try {
            File inputfile = new File("input.txt");
            Scanner sc = new Scanner(inputfile);
            sc.nextLine(); // discard first line
            while (sc.hasNextLine()) {
                int sum = 0;
                String[] valuesAsStrings = sc.nextLine().split(",", -1);
                for (String value : valuesAsStrings) {
                    sum += Integer.parseInt(value.trim());
                }
                product *= sum;
            }
            System.out.println(product);
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}
