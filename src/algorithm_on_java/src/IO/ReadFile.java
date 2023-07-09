package IO;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;

public class ReadFile {

    private static String readFileAsString(String fileName) throws IOException {
        return new String(Files.readAllBytes(Paths.get(fileName)));
    }


    public static String[] getStringValues(String fileName) throws IOException {
        String[] stringValues = readFileAsString(fileName).split("\n");
        if (stringValues.length <= 1) {
            stringValues = stringValues[0].split(",");
        }
        return stringValues;
    }

    public static ArrayList<Integer> getIntValues(String fileName) throws IOException {
        String[] stringValues = getStringValues(fileName);
        ArrayList<Integer> intValues = new ArrayList<>();

        for (String s : stringValues) {
            intValues.add(Integer.parseInt(s));
        }

        return intValues;
    }

}
