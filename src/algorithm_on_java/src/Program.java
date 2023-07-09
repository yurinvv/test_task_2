import IO.ReadFile;
import algorithm.SisoAlgorithm;

import java.io.IOException;
import java.util.ArrayList;

public class Program {

    // Reference patterns
    static String PATH_TO_extrinsic_512 = "patterns/ref_patterns/extrinsic_512.txt";
    static String PATH_TO_extrinsic_6144 = "patterns/ref_patterns/extrinsic_6144.txt";
    static String PATH_TO_LLR_512 = "patterns/ref_patterns/LLR_512.txt";
    static String PATH_TO_LLR_6144 = "patterns/ref_patterns/LLR_6144.txt";
    static String PATH_TO_in_512 = "patterns/stimuli/in_512.txt";
    static String PATH_TO_in_6144 = "patterns/stimuli/in_6144.txt";


    public static void main(String[] args) throws IOException {

        SisoAlgorithm decoder = new SisoAlgorithm(ReadFile.getIntValues(PATH_TO_in_512));
        decoder.executeAlgorithm();

        for (int llr : decoder.getLlr()) {
            System.out.println(llr);
        }

    }
}
