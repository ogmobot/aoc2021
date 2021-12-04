import java.io.*;
import java.util.ArrayList;
import java.util.Scanner;

public class day04 {
    static class BingoBoard {
        // nested classes is bad practice ;)
        int[] vals;
        ArrayList<Integer> numsSoFar;
        public boolean deleteMe;

        public BingoBoard(ArrayList<String> lines) {
            vals = new int [25];
            int index = 0;
            for (String line : lines) {
                String[] valuesAsStrings = line.trim().split(" ", -1);
                for (String value : valuesAsStrings) {
                    if (value.trim().length() > 0) {
                        vals[index] = (Integer.parseInt(value.trim()));
                        index ++;
                    }
                }
            }
            numsSoFar = new ArrayList<Integer>();
            deleteMe = false;
        }
        public void callNum(int val) {
            numsSoFar.add(val);
        }
        public boolean hasBingo() {
            // check rows
            boolean flag;
            for (int i = 0; i < 5; i++) {
                flag = true;
                for (int j = 0; j < 5; j++) {
                    if (!numsSoFar.contains(vals[5*i + j])) {
                        flag = false;
                    }
                }
                if (flag) { return true; }
            }
            // check columns
            flag = true;
            for (int i = 0; i < 5; i++) {
                flag = true;
                for (int j = 0; j < 5; j++) {
                    if (!numsSoFar.contains(vals[i + 5*j])) {
                        flag = false;
                    }
                }
                if (flag) { return true; }
            }
            // diagonals don't count
            return false;
        }
        private int sumOfAllUnmarkedNumbers() {
            int sum = 0;
            for (int i = 0; i < 25; i++) {
                if (!numsSoFar.contains(vals[i])) {
                    sum += vals[i];
                }
            }
            return sum;
        }
        public int score() {
            return sumOfAllUnmarkedNumbers() * numsSoFar.get(numsSoFar.size() - 1);
        }
    }


    public static void main(String args[]) {
        try {
            File inputfile = new File("input04.txt");
            Scanner sc = new Scanner(inputfile);

            String[] numListAsStrings = sc.nextLine().split(",", -1);
            int indexOfNumListAsStrings = 0;
            // read all bingo boards
            ArrayList<BingoBoard> bingoBoards = new ArrayList<BingoBoard>();
            ArrayList<String> buffer = new ArrayList<String>();
            while (sc.hasNextLine()) {
                sc.nextLine(); // discard first line
                for (int i = 0; i < 5; i++) {
                    buffer.add(sc.nextLine());
                }
                bingoBoards.add(new BingoBoard(buffer));
                buffer = new ArrayList<String>();
            }
            // call out numbers
            boolean firstBingoCalled = false;
            while (indexOfNumListAsStrings < numListAsStrings.length) {
                for (BingoBoard bingoBoard : bingoBoards) {
                    bingoBoard.callNum(Integer.parseInt(numListAsStrings[indexOfNumListAsStrings].trim()));
                    if (bingoBoard.hasBingo()) {
                        // part 1
                        if (!firstBingoCalled) {
                            System.out.println(bingoBoard.score());
                            firstBingoCalled = true;
                        }
                        bingoBoard.deleteMe = true;
                    }
                }
                // part 2
                if (bingoBoards.size() == 1 && bingoBoards.get(0).deleteMe) {
                    System.out.println(bingoBoards.get(0).score());
                }
                bingoBoards.removeIf(bb -> bb.deleteMe);
                indexOfNumListAsStrings ++;
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
}

/*
 * Java wasn't quite as overly annoying as I remember -- it was nice to be able
 * to write a lambda expression in List.removeIf(). I tried to be as UnnecessarilyVerboseAsPossible
 * as this seems to be a PreferredDesignPatternOfChoice in the standard library.
 */
